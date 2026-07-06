// Service worker for MVS Market Watch.
// Works on desktop AND mobile (Android Chrome / iOS Safari).
// No caching — all requests go straight to the network for live data.
//
// Mobile fixes vs the original:
//  1. fetch() wrapped in .catch() — bare respondWith(fetch()) crashes the SW on
//     Android/iOS when any request fails, leaving a blank page. Desktop ignores it.
//  2. Only GET requests are intercepted — Android WebView silently breaks when
//     a SW wraps non-GET requests (POST, preflight OPTIONS, etc.).
//  3. Non-http(s) schemes (chrome-extension, blob, data) are skipped.
//  4. Handles SKIP_WAITING message from the dashboard so updates activate immediately.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

// Handle SKIP_WAITING posted by the dashboard when a new SW version is found
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Only handle GET — let all other methods bypass the SW entirely
  if (req.method !== 'GET') return;

  // Only handle http / https — skip chrome-extension://, blob:, data: etc.
  if (!req.url.startsWith('http://') && !req.url.startsWith('https://')) return;

  // Network-first with a safe fallback.
  // The .catch() is critical on mobile: without it, any network error (CORS,
  // offline, timeout) throws an unhandled rejection that crashes the SW response
  // and produces a blank white screen on Android Chrome and iOS Safari.
  event.respondWith(
    fetch(req).catch(() =>
      new Response(
        JSON.stringify({ error: 'offline', message: 'Network unavailable' }),
        {
          status: 503,
          statusText: 'Service Unavailable',
          headers: { 'Content-Type': 'application/json' }
        }
      )
    )
  );
});
