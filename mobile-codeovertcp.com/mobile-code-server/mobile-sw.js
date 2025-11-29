const CACHE_NAME = 'mobile-code-server-v1';
const ASSETS_TO_CACHE = [
    '/mobile-assets/css/mobile-style.css',
    '/mobile-assets/js/mobile-ui-improvements.js',
    '/manifest.json',
    '/_static/src/browser/media/pwa-icon-192.png',
    '/_static/src/browser/media/pwa-icon-512.png'
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('[Mobile SW] Caching mobile assets');
            return cache.addAll(ASSETS_TO_CACHE);
        })
    );
});

self.addEventListener('fetch', (event) => {
    // Only handle requests for our mobile assets
    if (event.request.url.includes('/mobile-assets/') || event.request.url.includes('manifest.json')) {
        event.respondWith(
            caches.match(event.request).then((response) => {
                // Return cached response if found, otherwise fetch from network
                return response || fetch(event.request).then((networkResponse) => {
                    // Optional: Cache new versions dynamically
                    return networkResponse;
                });
            })
        );
    }
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('[Mobile SW] Removing old cache', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});
