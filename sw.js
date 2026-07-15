const CACHE = 'reef-v1';
const ASSETS = [
  './reef.html',
  './icon-192.png',
  './icon-512.png',
  './icon-180.png',
  './manifest.webmanifest'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  // 只處理同源 GET；雲端同步(PAT fetch GitHub)交給網路，不攔截
  if (e.request.method !== 'GET') return;
  if (url.origin !== self.location.origin) return;

  // 導航（打開頁面）：network-first，離線時回快取的 reef.html
  if (e.request.mode === 'navigate') {
    e.respondWith(fetch(e.request).catch(() => caches.match('./reef.html')));
    return;
  }
  // 靜態資源：cache-first
  e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request)));
});
