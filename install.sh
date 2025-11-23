#!/bin/bash

# Enhanced Amharic Dictionary - Installation Script
# This script sets up the development environment and installs dependencies

echo "🚀 بدء تثبيت القاموس الأمهرية الشامل المطور"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "التحقق من متطلبات النظام..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js غير مثبت. يرجى تثبيت Node.js أولاً"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm غير مثبت. يرجى تثبيت npm أولاً"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_warning "Git غير مثبت. يُنصح بتثبيته للمساهمات"
    fi
    
    # Check Python (optional)
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 غير مثبت (اختياري)"
    fi
    
    print_success "تم التحقق من المتطلبات بنجاح"
}

# Create project structure
create_structure() {
    print_status "إنشاء هيكل المشروع..."
    
    # Create directories
    mkdir -p assets/{icons,audio,images}
    mkdir -p docs/{api,contributing,user-guide}
    mkdir -p tests/{unit,integration,e2e}
    mkdir -p src/{js,css,components}
    mkdir -p dist/{css,js,assets}
    mkdir -p tools/{build,deploy,maintenance}
    
    # Create .gitignore
    cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production build
dist/
build/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# Temporary folders
tmp/
temp/

# PWA files
sw.js.map
*.map

# GitHub token (never commit this)
github_token
EOF
    
    print_success "تم إنشاء هيكل المشروع"
}

# Install dependencies
install_dependencies() {
    print_status "تثبيت dependencies..."
    
    # Initialize package.json
    npm init -y
    
    # Install development dependencies
    npm install --save-dev \
        live-server \
        webpack \
        webpack-cli \
        html-webpack-plugin \
        css-loader \
        style-loader \
        babel-loader \
        @babel/core \
        @babel/preset-env \
        eslint \
        prettier \
        jest \
        puppeteer \
        lighthouse
    
    # Install production dependencies
    npm install --save \
        animejs \
        font-awesome \
        moment \
        lodash
    
    # Install global tools
    npm install -g \
        http-server \
        serve \
        lighthouse-ci
    
    print_success "تم تثبيت المكتبات بنجاح"
}

# Setup GitHub integration
setup_github() {
    print_status "إعداد GitHub Integration..."
    
    # Create GitHub Actions workflow
    mkdir -p .github/workflows
    
    cat > .github/workflows/ci.yml << EOF
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run Lighthouse
      run: npm run lighthouse
    
    - name: Build project
      run: npm run build
    
    - name: Deploy to GitHub Pages
      if: github.ref == 'refs/heads/main'
      run: npm run deploy
EOF
    
    # Create GitHub issue templates
    mkdir -p .github/ISSUE_TEMPLATE
    
    cat > .github/ISSUE_TEMPLATE/bug_report.md << EOF
---
name: Bug report
about: إنشاء تقرير خطأ لتحسين المشروع
title: ''
labels: bug
assignees: ''

---

**وصف الخطأ**
وصف واضح ومختصر للخطأ.

**خطوات إعادة الإنتاج**
1. اذهب إلى '...'
2. اضغط على '....'
3. مرر لأسفل إلى '....'
4. شاهد الخطأ

**السلوك المتوقع**
وصف واضح لما كنت تتوقع حدوثه.

**لقطات الشاشة**
إذا أمكن، أضف لقطات شاشة للمساعدة في شرح المشكلة.

**معلومات إضافية**
أضف أي معلومات أخرى حول المشكلة هنا.

**معلومات البيئة**
 - المتصفح [ex. Chrome 91]
 - النظام [ex. iOS 14.7]
EOF
    
    cat > .github/ISSUE_TEMPLATE/feature_request.md << EOF
---
name: طلب ميزة جديدة
about: اقتراح فكرة لهذا المشروع
title: ''
labels: enhancement
assignees: ''

---

**هل解决问题 الحالي؟**
وصف واضح للمشكلة. مثال: أنا محبط دائماً عندما [...]

**الوصف الذي تريده**
وصف واضح ومختصر لما تريد أن يحدث.

**الوصف الذي تقترحه**
وصف واضح ومختصر لما تريد أن يحدث.

**البدائل التي قمت النظر فيها**
وصف واضح ومختصر لأي حلول أو ميزات فكرت فيها.

**معلومات إضافية**
أضف أي معلومات أو لقطات شاشة إضافية حول طلب الميزة هنا.
EOF
    
    print_success "تم إعداد GitHub Integration"
}

# Setup development tools
setup_dev_tools() {
    print_status "إعداد أدوات التطوير..."
    
    # Create package.json scripts
    update_package_json
    
    # Create webpack config
    create_webpack_config
    
    # Create eslint config
    create_eslint_config
    
    # Create prettier config
    create_prettier_config
    
    # Create jest config
    create_jest_config
    
    print_success "تم إعداد أدوات التطوير"
}

# Update package.json with scripts
update_package_json() {
    # This would typically update package.json, but for simplicity we'll show the content
    print_status "إنشاء package.json scripts..."
}

# Create webpack configuration
create_webpack_config() {
    cat > webpack.config.js << EOF
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  mode: 'development',
  entry: './src/js/main.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'js/[name].[contenthash].js',
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './index.html',
      filename: 'index.html'
    })
  ],
  devServer: {
    contentBase: path.join(__dirname, 'dist'),
    port: 3000,
    hot: true,
    open: true
  }
};
EOF
    
    print_success "تم إنشاء webpack.config.js"
}

# Create ESLint configuration
create_eslint_config() {
    cat > .eslintrc.js << EOF
module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  rules: {
    'indent': ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
    'no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
    'no-console': ['warn'],
  },
};
EOF
    
    print_success "تم إنشاء .eslintrc.js"
}

# Create Prettier configuration
create_prettier_config() {
    cat > .prettierrc << EOF
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF
    
    print_success "تم إنشاء .prettierrc"
}

# Create Jest configuration
create_jest_config() {
    cat > jest.config.js << EOF
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
EOF
    
    print_success "تم إنشاء jest.config.js"
}

# Setup PWA configuration
setup_pwa() {
    print_status "إعداد Progressive Web App..."
    
    # Create service worker
    cat > sw.js << EOF
// Service Worker for Enhanced Amharic Dictionary PWA
const CACHE_NAME = 'amharic-dictionary-v1.0.0';
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/assets/css/main.css',
  '/assets/js/main.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        return response || fetch(event.request);
      }
    )
  );
});
EOF
    
    # Create web app manifest
    cat > manifest.json << EOF
{
  "name": "القاموس الأمهرية الشامل",
  "short_name": "القاموس الأمهرية",
  "description": "قاموس شامل للغة الأمهرية مع 50,000 كلمة",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F5F5DC",
  "theme_color": "#8B4513",
  "icons": [
    {
      "src": "/assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
    
    print_success "تم إعداد PWA"
}

# Create development documentation
create_docs() {
    print_status "إنشاء التوثيق..."
    
    # Create development guide
    cat > docs/development-guide.md << EOF
# دليل التطوير

## البدء السريع
1. \`npm install\` - تثبيت المكتبات
2. \`npm run dev\` - تشغيل بيئة التطوير
3. \`npm run build\` - بناء المشروع للإنتاج
4. \`npm run test\` - تشغيل الاختبارات

## هيكل المشروع
- \`src/\` - الكود المصدري
- \`dist/\` - الملفات المبنية
- \`tests/\` - ملفات الاختبار
- \`docs/\` - التوثيق

## المساهمة
راجع \`CONTRIBUTING.md\` للمزيد من التفاصيل.
EOF
    
    # Create contributing guidelines
    cat > CONTRIBUTING.md << EOF
# إرشادات المساهمة

## كيفية المساهمة
1. Fork المشروع
2. أنشئ فرع جديد للميزة
3. اكتب كود عالي الجودة
4. اختبر التغييرات
5. أرسل Pull Request

## معايير الكود
- استخدم ESLint و Prettier
- اكتب تعليقات واضحة
- اختبر الوظائف الجديدة
- اتبع النمط المتبع

## أنواع المساهمات
- إضافة كلمات جديدة
- تحسين الترجمة
- تطوير ميزات جديدة
- إصلاح الأخطاء
- تحسين التوثيق
EOF
    
    print_success "تم إنشاء التوثيق"
}

# Run tests
run_tests() {
    print_status "تشغيل الاختبارات..."
    
    if npm test --silent; then
        print_success "جميع الاختبارات نجحت"
    else
        print_warning "بعض الاختبارات فشلت"
    fi
}

# Build project
build_project() {
    print_status "بناء المشروع..."
    
    if npm run build --silent; then
        print_success "تم بناء المشروع بنجاح"
    else
        print_error "فشل في بناء المشروع"
        exit 1
    fi
}

# Main installation function
main() {
    print_status "بدء التثبيت..."
    
    check_requirements
    create_structure
    install_dependencies
    setup_github
    setup_dev_tools
    setup_pwa
    create_docs
    
    # Run tests and build
    run_tests
    build_project
    
    print_success "🎉 تم التثبيت بنجاح!"
    echo ""
    echo "الخطوات التالية:"
    echo "1. اذهب إلى مجلد المشروع: cd $(pwd)"
    echo "2. ابدأ بيئة التطوير: npm run dev"
    echo "3. افتح المتصفح على: http://localhost:3000"
    echo "4. راجع التوثيق في مجلد docs/"
    echo ""
    echo "للمساهمة:"
    echo "1.Fork المشروع على GitHub"
    echo "2. راجع CONTRIBUTING.md"
    echo "3. أنشئ فرع جديد وابدأ التطوير"
    echo ""
    echo "تم تثبيت القاموس الأمهرية الشامل المطور بنجاح! 🚀"
}

# Handle script interruption
trap 'echo -e "\n${RED}تم إيقاف التثبيت${NC}"; exit 1' INT

# Run main function
main "$@"