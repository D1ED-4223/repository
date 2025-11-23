// Service Worker for Enhanced Amharic Dictionary PWA
const CACHE_NAME = 'amharic-dictionary-v2.0.0';
const urlsToCache = [
    '/enhanced-dictionary.html',
    '/manifest.json',
    // External resources
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css',
    'https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic:wght@300;400;500;600;700&family=Amiri:wght@400;700&display=swap',
    'https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js'
];

// Install event - cache resources
self.addEventListener('install', event => {
    console.log('Service Worker: Installing...');
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Service Worker: Caching files');
                return cache.addAll(urlsToCache);
            })
            .then(() => {
                console.log('Service Worker: Installation complete');
                return self.skipWaiting();
            })
            .catch(error => {
                console.error('Service Worker: Installation failed', error);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
    console.log('Service Worker: Activating...');
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Service Worker: Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        }).then(() => {
            console.log('Service Worker: Activation complete');
            return self.clients.claim();
        })
    );
});

// Fetch event - serve cached content when offline
self.addEventListener('fetch', event => {
    // Skip non-GET requests
    if (event.request.method !== 'GET') {
        return;
    }

    // Skip chrome-extension requests
    if (event.request.url.startsWith('chrome-extension://')) {
        return;
    }

    event.respondWith(
        caches.match(event.request)
            .then(response => {
                // Return cached version or fetch from network
                if (response) {
                    console.log('Service Worker: Serving from cache:', event.request.url);
                    return response;
                }

                console.log('Service Worker: Fetching from network:', event.request.url);
                return fetch(event.request)
                    .then(response => {
                        // Don't cache non-successful responses
                        if (!response || response.status !== 200 || response.type !== 'basic') {
                            return response;
                        }

                        // Clone the response
                        const responseToCache = response.clone();

                        // Add to cache for future offline use
                        caches.open(CACHE_NAME)
                            .then(cache => {
                                cache.put(event.request, responseToCache);
                            });

                        return response;
                    })
                    .catch(error => {
                        console.error('Service Worker: Fetch failed', error);
                        
                        // Return offline page for navigation requests
                        if (event.request.destination === 'document') {
                            return caches.match('/enhanced-dictionary.html');
                        }
                        
                        // For other requests, return a custom offline response
                        return new Response(
                            JSON.stringify({
                                error: 'Offline',
                                message: 'هذا المحتوى غير متوفر بدون اتصال بالإنترنت'
                            }),
                            {
                                status: 503,
                                statusText: 'Service Unavailable',
                                headers: {
                                    'Content-Type': 'application/json'
                                }
                            }
                        );
                    });
            })
    );
});

// Background sync for offline contributions
self.addEventListener('sync', event => {
    if (event.tag === 'background-sync-contributions') {
        console.log('Service Worker: Background sync for contributions');
        event.waitUntil(syncContributions());
    }
});

// Push notifications for updates
self.addEventListener('push', event => {
    console.log('Service Worker: Push received');
    
    const options = {
        body: event.data ? event.data.text() : 'تحديث جديد في القاموس الأمهرية',
        icon: '/icon-192x192.png',
        badge: '/badge-72x72.png',
        vibrate: [100, 50, 100],
        data: {
            dateOfArrival: Date.now(),
            primaryKey: '1'
        },
        actions: [
            {
                action: 'explore',
                title: 'استكشاف',
                icon: '/explore-icon.png'
            },
            {
                action: 'close',
                title: 'إغلاق',
                icon: '/close-icon.png'
            }
        ]
    };

    event.waitUntil(
        self.registration.showNotification('القاموس الأمهرية', options)
    );
});

// Handle notification clicks
self.addEventListener('notificationclick', event => {
    console.log('Service Worker: Notification clicked');
    
    event.notification.close();

    if (event.action === 'explore') {
        // Open the app
        event.waitUntil(
            clients.openWindow('/enhanced-dictionary.html')
        );
    } else if (event.action === 'close') {
        // Just close the notification (already done above)
    } else {
        // Default action - open the app
        event.waitUntil(
            clients.openWindow('/enhanced-dictionary.html')
        );
    }
});

// Message handling for communication with main thread
self.addEventListener('message', event => {
    console.log('Service Worker: Message received:', event.data);
    
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
    
    if (event.data && event.data.type === 'GET_VERSION') {
        event.ports[0].postMessage({version: CACHE_NAME});
    }
});

// Periodic background sync (if supported)
self.addEventListener('periodicsync', event => {
    if (event.tag === 'content-sync') {
        event.waitUntil(syncContent());
    }
});

// Helper function to sync contributions when back online
async function syncContributions() {
    try {
        const cache = await caches.open(CACHE_NAME);
        const contributions = await cache.match('/offline-contributions');
        
        if (contributions) {
            const contributionData = await contributions.json();
            // Process queued contributions here
            console.log('Service Worker: Syncing contributions:', contributionData);
            
            // Clear the queue after successful sync
            await cache.delete('/offline-contributions');
        }
    } catch (error) {
        console.error('Service Worker: Error syncing contributions', error);
    }
}

// Helper function to sync content updates
async function syncContent() {
    try {
        // Check for content updates and notify the main app
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
            client.postMessage({
                type: 'CONTENT_UPDATE',
                timestamp: Date.now()
            });
        });
    } catch (error) {
        console.error('Service Worker: Error syncing content', error);
    }
}

// Cache management utilities
self.addEventListener('message', event => {
    if (event.data && event.data.type === 'CLEAR_CACHE') {
        event.waitUntil(
            caches.delete(CACHE_NAME).then(() => {
                console.log('Service Worker: Cache cleared');
                event.ports[0].postMessage({success: true});
            })
        );
    }
});

// Error handling
self.addEventListener('error', event => {
    console.error('Service Worker: Global error', event.error);
});

self.addEventListener('unhandledrejection', event => {
    console.error('Service Worker: Unhandled promise rejection', event.reason);
});

// Performance monitoring
self.addEventListener('fetch', event => {
    const startTime = performance.now();
    
    event.respondWith(
        handleRequest(event.request).then(response => {
            const endTime = performance.now();
            console.log(`Service Worker: Request took ${endTime - startTime}ms`);
            return response;
        })
    );
});

async function handleRequest(request) {
    try {
        const response = await fetch(request);
        return response;
    } catch (error) {
        // Fallback to cache for offline scenarios
        const cachedResponse = await caches.match(request);
        if (cachedResponse) {
            return cachedResponse;
        }
        throw error;
    }
}