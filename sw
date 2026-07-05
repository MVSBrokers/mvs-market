// Minimal service worker for MVS Market Watch.
// Its only job is to satisfy browser installability requirements (Chrome/Edge/Android)
// so the site can be installed as an app on desktop and mobile.
// It does not cache anything — the dashboard always needs fresh live data,
// so we deliberately let every request pass straight through to the network.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Pass-through: always fetch fresh from the network, never serve from a cache.
  event.respondWith(fetch(event.request));
});
