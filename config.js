# Enhanced Amharic Dictionary - Configuration
# This file contains all configuration settings for the application

# Application Configuration
APP_NAME="القاموس الأمهرية الشامل المطور"
APP_VERSION="2.0.0"
APP_DESCRIPTION="Enhanced Amharic Dictionary with GitHub Integration"
APP_AUTHOR="MiniMax Agent"

# GitHub Integration Configuration
GITHUB_OWNER="amharic-dictionary"
GITHUB_REPO="enhanced-dictionary"
GITHUB_API_BASE="https://api.github.com"
GITHUB_WEBHOOK_SECRET="your-webhook-secret-here"

# Database Configuration (Local Storage)
DB_NAME="amharic_dictionary_db"
DB_VERSION="2.0.0"
DB_SIZE=50 * 1024 * 1024  # 50MB

# Cache Configuration
CACHE_NAME="amharic-dictionary-v2.0.0"
CACHE_VERSION="2.0.0"
OFFLINE_CACHE_DURATION=7 * 24 * 60 * 60 * 1000  # 7 days in milliseconds

# API Configuration
API_BASE_URL="https://api.github.com"
API_RATE_LIMIT=5000  # requests per hour
API_TIMEOUT=30000  # 30 seconds

# Word Database Configuration
TOTAL_WORDS=50000
WORDS_PER_PAGE=20
MAX_SEARCH_RESULTS=1000
CATEGORIES_COUNT=10
LEVELS_COUNT=3

# User Interface Configuration
THEME_COLORS = {
    primary: "#8B4513",
    secondary: "#D2B48C", 
    accent: "#9ACD32",
    background: "#F5F5DC",
    text: "#2F4F4F",
    success: "#28a745",
    warning: "#ffc107",
    danger: "#dc3545"
}

DARK_THEME_COLORS = {
    primary: "#CD853F",
    secondary: "#8B4513",
    accent: "#9ACD32",
    background: "#1a1a1a", 
    text: "#e0e0e0",
    success: "#28a745",
    warning: "#ffc107",
    danger: "#dc3545"
}

# Audio Configuration
AUDIO_ENABLED=true
AUDIO_FORMAT="mp3"
AUDIO_QUALITY="high"
MAX_AUDIO_FILE_SIZE=5 * 1024 * 1024  # 5MB

# Search Configuration
SEARCH_DEBOUNCE_DELAY=300  # milliseconds
SEARCH_MIN_LENGTH=2
SEARCH_MAX_LENGTH=100
FUZZY_SEARCH_THRESHOLD=0.6

# Quiz Configuration  
QUIZ_QUESTIONS_COUNT=10
QUIZ_TIME_LIMIT=300  # 5 minutes in seconds
QUIZ_PASSING_SCORE=70  # percentage
QUIZ_MAX_ATTEMPTS=3

# Progress Tracking
PROGRESS_SAVE_INTERVAL=60000  # 1 minute in milliseconds
PROGRESS_RETENTION_DAYS=365
MAX_LEARNED_WORDS=10000
MAX_QUIZ_POINTS=5000

# Export Configuration
EXPORT_FORMATS=["pdf", "json", "csv", "txt"]
PDF_EXPORT_ENABLED=true
JSON_EXPORT_ENABLED=true
CSV_EXPORT_ENABLED=true
TXT_EXPORT_ENABLED=true

# Social Sharing
SHARING_ENABLED=true
SHARING_PLATFORMS=["facebook", "twitter", "whatsapp", "telegram"]
SHARING_DEFAULT_MESSAGE="اكتشفت كلمات جديدة في القاموس الأمهرية"

# Notification Configuration
NOTIFICATION_ENABLED=true
NOTIFICATION_DURATION=3000  # milliseconds
NOTIFICATION_POSITION="top-right"
NOTIFICATION_TYPES=["success", "error", "warning", "info"]

# Analytics Configuration
ANALYTICS_ENABLED=true
ANALYTICS_EVENTS=["search", "word_view", "quiz_start", "quiz_complete", "favorite_add", "export"]
ANALYTICS_BATCH_SIZE=10
ANALYTICS_FLUSH_INTERVAL=30000  # 30 seconds

# Security Configuration
SECURITY_ENABLED=true
CSRF_PROTECTION=true
RATE_LIMITING=true
MAX_REQUESTS_PER_MINUTE=60
BLOCKED_USER_AGENTS=["bot", "spider", "crawler"]

# PWA Configuration
PWA_ENABLED=true
PWA_INSTALL_PROMPT_ENABLED=true
PWA_UPDATE_AVAILABLE_NOTIFICATION=true
PWA_OFFLINE_FALLBACK_ENABLED=true

# Localization
DEFAULT_LANGUAGE="ar"
SUPPORTED_LANGUAGES=["ar", "en", "am"]
RTL_LANGUAGES=["ar", "fa", "he"]
FONT_FALLBACK="Noto Sans Arabic, Arial, sans-serif"

# Performance Configuration
PERFORMANCE_MONITORING=true
LAZY_LOADING_ENABLED=true
IMAGE_OPTIMIZATION_ENABLED=true
CODE_SPLITTING_ENABLED=true
MINIFICATION_ENABLED=true

# Error Handling
ERROR_LOGGING_ENABLED=true
ERROR_REPORTING_ENDPOINT=null  # Set to your error reporting service
ERROR_RETRY_ATTEMPTS=3
ERROR_RETRY_DELAY=1000  # milliseconds

# Development Configuration (for development environment)
DEVELOPMENT_MODE=false
DEBUG_MODE=false
MOCK_API_ENABLED=false
CONSOLE_LOGS_ENABLED=true
HOT_RELOAD_ENABLED=true

# Production Configuration
PRODUCTION_MODE=true
CDN_ENABLED=false
CDN_BASE_URL="https://cdn.example.com"
COMPRESSION_ENABLED=true
GZIP_ENABLED=true
BROTLI_ENABLED=false

# Feature Flags
FEATURES = {
    github_integration: true,
    offline_mode: true,
    audio_pronunciation: true,
    quiz_system: true,
    progress_tracking: true,
    social_sharing: true,
    export_import: true,
    dark_mode: true,
    notifications: true,
    analytics: true,
    pwa: true,
    voice_search: false,  # Future feature
    ai_translation: false,  # Future feature
    augmented_reality: false  # Future feature
}

# External Dependencies
DEPENDENCIES = {
    font_awesome: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css",
    google_fonts: "https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic:wght@300;400;500;600;700&family=Amiri:wght@400;700&display=swap",
    anime_js: "https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js",
    moment_js: "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js",
    lodash: "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.21/lodash.min.js"
}

# Service Worker Configuration
SW_CONFIG = {
    version: "2.0.0",
    skipWaiting: true,
    clientsClaim: true,
    runtimeCaching: [
        {
            urlPattern: /^https:\/\/api\.github\.com\//,
            handler: "CacheFirst",
            options: {
                cacheName: "github-api-cache",
                expiration: {
                    maxEntries: 50,
                    maxAgeSeconds: 300  # 5 minutes
                }
            }
        },
        {
            urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/,
            handler: "CacheFirst",
            options: {
                cacheName: "images-cache",
                expiration: {
                    maxEntries: 100,
                    maxAgeSeconds: 2592000  # 30 days
                }
            }
        }
    ]
}

# Testing Configuration
TEST_CONFIG = {
    unit_test_framework: "jest",
    e2e_test_framework: "puppeteer",
    test_coverage_threshold: 80,
    test_timeout: 30000,
    parallel_testing: true
}

# CI/CD Configuration
CI_CONFIG = {
    github_actions_enabled: true,
    auto_deploy_enabled: true,
    staging_environment: true,
    production_deployment: true,
    automated_testing: true,
    security_scanning: true
}

# SEO Configuration
SEO_CONFIG = {
    meta_description: "قاموس شامل للغة الأمهرية مع 50,000 كلمة وتعريفات مفصلة ونطق صحيح",
    meta_keywords: "قاموس, أمهرية, إثيوبيا, تعلم, لغة, كلمات, ترجمة",
    structured_data_enabled: true,
    sitemap_enabled: true,
    robots_txt_enabled: true
}

# Accessibility Configuration
ACCESSIBILITY_CONFIG = {
    aria_labels_enabled: true,
    keyboard_navigation_enabled: true,
    screen_reader_support: true,
    high_contrast_mode: true,
    focus_indicators: true,
    skip_links: true
}

# Performance Monitoring
PERFORMANCE_CONFIG = {
    core_web_vitals_tracking: true,
    lighthouse_monitoring: true,
    bundle_analysis: true,
    memory_usage_tracking: true,
    load_time_monitoring: true
}

# Environment Variables (for production)
ENV_VARS = {
    NODE_ENV: "production",
    GITHUB_TOKEN: null,  # Set in environment
    CDN_URL: null,       # Set in environment
    ANALYTICS_ID: null,  # Set in environment
    ERROR_REPORTING_DSN: null  # Set in environment
}