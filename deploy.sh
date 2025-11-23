#!/bin/bash

# Enhanced Amharic Dictionary - Deployment Script
# This script handles the deployment of the application to various environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_NAME="enhanced-amharic-dictionary"
DEPLOY_ENV=${1:-"production"}
BUILD_DIR="dist"
SOURCE_DIR="."

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "التحقق من المتطلبات..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git غير مثبت. يرجى تثبيته أولاً."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "npm غير مثبت. يرجى تثبيته أولاً."
        exit 1
    fi
    
    log_success "تم التحقق من المتطلبات"
}

# Build the application
build_application() {
    log_info "بناء التطبيق للبيئة: $DEPLOY_ENV"
    
    # Clean previous build
    rm -rf $BUILD_DIR
    mkdir -p $BUILD_DIR
    
    # Copy main files
    cp enhanced-dictionary.html $BUILD_DIR/index.html
    cp manifest.json $BUILD_DIR/
    cp sw.js $BUILD_DIR/
    cp github-integration.js $BUILD_DIR/
    cp github-integration.css $BUILD_DIR/
    cp config.js $BUILD_DIR/
    
    # Create assets directory
    mkdir -p $BUILD_DIR/assets/{css,js,icons,audio,images}
    
    # Generate optimized CSS
    if command -v cleancss &> /dev/null; then
        log_info "ضغط ملفات CSS..."
        cleancss -o $BUILD_DIR/assets/css/main.min.css enhanced-dictionary.html
    fi
    
    # Copy and optimize JavaScript
    if command -v uglifyjs &> /dev/null; then
        log_info "ضغط ملفات JavaScript..."
        uglifyjs github-integration.js -o $BUILD_DIR/assets/js/github-integration.min.js
    fi
    
    # Generate PWA icons (requires icon generation tools)
    generate_pwa_icons
    
    # Update manifest for deployment
    update_manifest_for_deployment
    
    # Create deployment files
    create_deployment_files
    
    log_success "تم بناء التطبيق بنجاح"
}

# Generate PWA icons
generate_pwa_icons() {
    log_info "إنشاء أيقونات PWA..."
    
    # Check if ImageMagick is available
    if command -v convert &> /dev/null; then
        # Create icons from a base image (requires icon-512.png to exist)
        if [ -f "assets/icons/icon-512.png" ]; then
            convert assets/icons/icon-512.png -resize 192x192 $BUILD_DIR/assets/icons/icon-192x192.png
            convert assets/icons/icon-512.png -resize 144x144 $BUILD_DIR/assets/icons/icon-144x144.png
            convert assets/icons/icon-512.png -resize 96x96 $BUILD_DIR/assets/icons/icon-96x96.png
            convert assets/icons/icon-512.png -resize 72x72 $BUILD_DIR/assets/icons/icon-72x72.png
            log_success "تم إنشاء أيقونات PWA"
        else
            log_warning "ملف icon-512.png غير موجود، سيتم تخطي إنشاء الأيقونات"
        fi
    else
        log_warning "ImageMagick غير متوفر، سيتم تخطي إنشاء الأيقونات"
    fi
}

# Update manifest for deployment
update_manifest_for_deployment() {
    if [ "$DEPLOY_ENV" = "production" ]; then
        # Update manifest for production
        sed -i.bak 's|"start_url": "/|"start_url": "/index.html"|g' $BUILD_DIR/manifest.json
        sed -i.bak 's|"background_color": "#F5F5DC"|"background_color": "#ffffff"|g' $BUILD_DIR/manifest.json
        rm -f $BUILD_DIR/manifest.json.bak
    fi
}

# Create deployment files
create_deployment_files() {
    log_info "إنشاء ملفات النشر..."
    
    # Create robots.txt
    cat > $BUILD_DIR/robots.txt << EOF
User-agent: *
Allow: /
Sitemap: https://${PROJECT_NAME}.github.io/sitemap.xml
EOF
    
    # Create sitemap.xml
    cat > $BUILD_DIR/sitemap.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://${PROJECT_NAME}.github.io/</loc>
        <lastmod>$(date -u +%Y-%m-%dT%H:%M:%SZ)</lastmod>
        <changefreq>weekly</changefreq>
        <priority>1.0</priority>
    </url>
</urlset>
EOF
    
    # Create .nojekyll (for GitHub Pages)
    touch $BUILD_DIR/.nojekyll
    
    # Create 404.html
    cat > $BUILD_DIR/404.html << EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>صفحة غير موجودة - القاموس الأمهرية</title>
    <style>
        body { font-family: 'Noto Sans Arabic', sans-serif; text-align: center; padding: 2rem; }
        .error { font-size: 4rem; color: #8B4513; margin-bottom: 1rem; }
        .message { font-size: 1.2rem; color: #666; margin-bottom: 2rem; }
        .btn { background: #8B4513; color: white; padding: 1rem 2rem; text-decoration: none; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="error">404</div>
    <div class="message">عذراً، الصفحة التي تبحث عنها غير موجودة</div>
    <a href="/" class="btn">العودة للرئيسية</a>
</body>
</html>
EOF
    
    log_success "تم إنشاء ملفات النشر"
}

# Deploy to GitHub Pages
deploy_github_pages() {
    log_info "النشر على GitHub Pages..."
    
    # Check if git repository exists
    if [ ! -d ".git" ]; then
        log_error "مجلد Git غير موجود. يرجى تشغيل git init أولاً."
        exit 1
    fi
    
    # Create gh-pages branch if it doesn't exist
    if ! git rev-parse --verify gh-pages > /dev/null 2>&1; then
        git checkout --orphan gh-pages
        rm -rf *
        cp -r $BUILD_DIR/* .
        git add .
        git commit -m "Initial deployment to GitHub Pages"
        git push origin gh-pages --force
        git checkout main 2>/dev/null || git checkout master
    else
        # Update existing gh-pages branch
        git checkout gh-pages
        rm -rf *
        cp -r $BUILD_DIR/* .
        git add .
        git commit -m "Deploy to GitHub Pages - $(date)"
        git push origin gh-pages
        git checkout main 2>/dev/null || git checkout master
    fi
    
    log_success "تم النشر على GitHub Pages"
    log_info "الموقع متاح على: https://${PROJECT_NAME}.github.io/"
}

# Deploy to Netlify
deploy_netlify() {
    log_info "النشر على Netlify..."
    
    if ! command -v netlify &> /dev/null; then
        log_warning "Netlify CLI غير مثبت. يرجى تثبيته باستخدام: npm install -g netlify-cli"
        log_info "أو قم برفع مجلد $BUILD_DIR يدوياً إلى Netlify"
        return
    fi
    
    # Deploy using Netlify CLI
    cd $BUILD_DIR
    netlify deploy --prod --dir .
    cd ..
    
    log_success "تم النشر على Netlify"
}

# Deploy to Vercel
deploy_vercel() {
    log_info "النشر على Vercel..."
    
    if ! command -v vercel &> /dev/null; then
        log_warning "Vercel CLI غير مثبت. يرجى تثبيته باستخدام: npm install -g vercel"
        log_info "أو قم برفع مجلد $BUILD_DIR يدوياً إلى Vercel"
        return
    fi
    
    # Deploy using Vercel CLI
    cd $BUILD_DIR
    vercel --prod
    cd ..
    
    log_success "تم النشر على Vercel"
}

# Deploy to Firebase
deploy_firebase() {
    log_info "النشر على Firebase..."
    
    if ! command -v firebase &> /dev/null; then
        log_warning "Firebase CLI غير مثبت. يرجى تثبيته باستخدام: npm install -g firebase-tools"
        log_info "أو قم برفع مجلد $BUILD_DIR يدوياً إلى Firebase"
        return
    fi
    
    # Deploy using Firebase CLI
    firebase deploy --only hosting
    
    log_success "تم النشر على Firebase"
}

# Deploy to AWS S3
deploy_aws_s3() {
    log_info "النشر على AWS S3..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI غير مثبت. يرجى تثبيته أولاً."
        return
    fi
    
    # Get S3 bucket name from environment or user input
    BUCKET_NAME=${AWS_S3_BUCKET:-$1}
    
    if [ -z "$BUCKET_NAME" ]; then
        read -p "أدخل اسم bucket S3: " BUCKET_NAME
    fi
    
    # Sync files to S3
    aws s3 sync $BUILD_DIR s3://$BUCKET_NAME --delete
    
    # Set proper caching headers
    aws s3 cp s3://$BUCKET_NAME s3://$BUCKET_NAME --recursive --metadata-directive REPLACE --cache-control "max-age=31536000" --content-type "text/html" --exclude "*" --include "*.html"
    
    # Invalidate CloudFront distribution if configured
    if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
    fi
    
    log_success "تم النشر على AWS S3"
    log_info "الموقع متاح على: http://$BUCKET_NAME.s3-website-${AWS_REGION:-us-east-1}.amazonaws.com/"
}

# Run tests before deployment
run_tests() {
    log_info "تشغيل الاختبارات قبل النشر..."
    
    if [ -f "package.json" ]; then
        if npm test --silent; then
            log_success "جميع الاختبارات نجحت"
        else
            log_error "بعض الاختبارات فشلت. يرجى إصلاح الأخطاء قبل النشر."
            exit 1
        fi
    else
        log_warning "ملف package.json غير موجود، سيتم تخطي الاختبارات"
    fi
}

# Performance checks
performance_check() {
    log_info "فحص الأداء..."
    
    if command -v lighthouse &> /dev/null; then
        lighthouse http://localhost:8080 --output html --output-path $BUILD_DIR/lighthouse-report.html --chrome-flags="--headless"
        log_success "تم إنشاء تقرير Lighthouse"
    else
        log_warning "Lighthouse CLI غير مثبت. يُنصح بتثبيته لتحليل الأداء."
    fi
}

# Security scan
security_scan() {
    log_info "فحص الأمان..."
    
    if command -v npm-audit &> /dev/null; then
        npm audit
        log_success "تم فحص الأمان"
    else
        log_warning "npm audit غير متوفر"
    fi
}

# Main deployment function
deploy() {
    log_info "بدء عملية النشر للبيئة: $DEPLOY_ENV"
    
    # Run pre-deployment checks
    check_prerequisites
    run_tests
    security_scan
    
    # Build application
    build_application
    
    # Performance check
    performance_check
    
    # Deploy based on environment
    case $DEPLOY_ENV in
        "github")
            deploy_github_pages
            ;;
        "netlify")
            deploy_netlify
            ;;
        "vercel")
            deploy_vercel
            ;;
        "firebase")
            deploy_firebase
            ;;
        "aws")
            deploy_aws_s3 $2
            ;;
        "all")
            deploy_github_pages
            deploy_netlify
            deploy_vercel
            deploy_firebase
            ;;
        *)
            log_error "بيئة نشر غير مدعومة: $DEPLOY_ENV"
            log_info "البيئات المدعومة: github, netlify, vercel, firebase, aws, all"
            exit 1
            ;;
    esac
    
    # Cleanup
    cleanup
    
    log_success "🎉 تم النشر بنجاح!"
    log_info "البيئة: $DEPLOY_ENV"
    log_info "التاريخ: $(date)"
    log_info "المجلد المبني: $BUILD_DIR"
}

# Cleanup temporary files
cleanup() {
    log_info "تنظيف الملفات المؤقتة..."
    
    # Remove backup files
    find $BUILD_DIR -name "*.bak" -delete
    
    # Remove development files
    find $BUILD_DIR -name "*.map" -delete
    find $BUILD_DIR -name "*.log" -delete
    
    log_success "تم التنظيف"
}

# Show usage
show_usage() {
    echo "الاستخدام: $0 [البيئة] [المعلمات الإضافية]"
    echo ""
    echo "البيئات المدعومة:"
    echo "  github    - النشر على GitHub Pages"
    echo "  netlify   - النشر على Netlify"
    echo "  vercel    - النشر على Vercel"
    echo "  firebase  - النشر على Firebase"
    echo "  aws       - النشر على AWS S3"
    echo "  all       - النشر على جميع المنصات"
    echo ""
    echo "أمثلة:"
    echo "  $0 github"
    echo "  $0 netlify"
    echo "  $0 aws my-bucket-name"
    echo "  $0 all"
    echo ""
    echo "متغيرات البيئة:"
    echo "  AWS_S3_BUCKET         - اسم bucket S3"
    echo "  AWS_REGION            - منطقة AWS (افتراضي: us-east-1)"
    echo "  CLOUDFRONT_DISTRIBUTION_ID - معرف CloudFront"
}

# Handle script interruption
trap 'echo -e "\n${RED}تم إيقاف عملية النشر${NC}"; exit 1' INT

# Main script execution
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

# Run main function
deploy "$@"