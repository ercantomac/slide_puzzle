'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "0a4a3ca41bf47f085aa03c7578d945bc",
"assets/assets/1/1.jpg": "b809e0acac6a43235d2eebc3a2c0b3c8",
"assets/assets/1/10.jpg": "49efdad241fbb603c79192c7f427b304",
"assets/assets/1/11.jpg": "65240971314799ab6bc9b40efb26fe28",
"assets/assets/1/12.jpg": "6a71278f52f9470d49dc93f2f109c873",
"assets/assets/1/13.jpg": "fa89a1e9cd39b75ed2d187ca8229d1a0",
"assets/assets/1/14.jpg": "1ac7a184f4d49a4f55d94b301c831ade",
"assets/assets/1/15.jpg": "921c225033dc512a9df73dc5214260a1",
"assets/assets/1/16.jpg": "85a96b00a9ee0ebc4bfd5b256262922d",
"assets/assets/1/2.jpg": "6c07e45a06a2849f7f79dd5e75fff8a4",
"assets/assets/1/3.jpg": "f59e0ef670c076688e8c18d8b8c1e37a",
"assets/assets/1/4.jpg": "96b18c4613a7e50c31402a4be2e25ddd",
"assets/assets/1/5.jpg": "1a328b2efe1e1c4379c081fb1eb9833b",
"assets/assets/1/6.jpg": "0d8f088a8957c0652345bdc23e6502ce",
"assets/assets/1/7.jpg": "a29dae419f9bb13125d1f32056d2cd6f",
"assets/assets/1/8.jpg": "2a42e7c7d24dd89944b61620700ee88e",
"assets/assets/1/9.jpg": "9a6a92d99b5016d20640ee562878a183",
"assets/assets/1/original.jpg": "b51b02421d491f68a6f18d3f364d5d19",
"assets/assets/2/1.jpg": "73fa8da32591bd12157f3599b1bd5d73",
"assets/assets/2/10.jpg": "55faa8f25de3b430d6ef4c45afa2f89d",
"assets/assets/2/11.jpg": "a2219759d6f8fe7b2cee61132d8f773d",
"assets/assets/2/12.jpg": "44cf3cde2cdc93ee4a8119dccdd2a486",
"assets/assets/2/13.jpg": "7c5b4c7d174f025baca31cb51c85089d",
"assets/assets/2/14.jpg": "61cb93ac9267844d4a2271e835daf531",
"assets/assets/2/15.jpg": "69bc1c0fa46f402cd4c4ed11e25a9b5a",
"assets/assets/2/16.jpg": "1f4d7567f4cc3acddc777ecb3bc62958",
"assets/assets/2/2.jpg": "d5f456c56158b6272d617220617a2c20",
"assets/assets/2/3.jpg": "1497b30fe1f4dac709890cc6b35e80c1",
"assets/assets/2/4.jpg": "d48fbbc307df9f54c280a787f1e18ae8",
"assets/assets/2/5.jpg": "7e10335050989f77ed8430c1c04701bd",
"assets/assets/2/6.jpg": "81b8f25618ae4ca842b98dd7ca1a8080",
"assets/assets/2/7.jpg": "065b7498eeb5bc65de8ad90e3daea534",
"assets/assets/2/8.jpg": "cb54f0e2d39098eefa2fcfd556c68b75",
"assets/assets/2/9.jpg": "a5ef0c7d913694b83deba1161ab1cd56",
"assets/assets/2/original.jpg": "c27305de61802e21d33ef97122735585",
"assets/assets/3/1.jpg": "9987c980a2f7590e220f9dadbe138c2c",
"assets/assets/3/10.jpg": "620270c5c68b553777104efb7141c565",
"assets/assets/3/11.jpg": "49a4d1120d44205fa27b5b93d68c38ef",
"assets/assets/3/12.jpg": "9b8e15626f3333434b5ff43853773a58",
"assets/assets/3/13.jpg": "8f79ac45960b29638523fa759e2df764",
"assets/assets/3/14.jpg": "b708b0f14e61a36b69034aaca95a6fb2",
"assets/assets/3/15.jpg": "5facdb8596a052b274628e14f3c7c29d",
"assets/assets/3/16.jpg": "7cfe72d5eeb65d7ba67f4264f718c646",
"assets/assets/3/2.jpg": "327f512e3d008610d2378f088298c44c",
"assets/assets/3/3.jpg": "9bd4b762fcf98219230159fb9eba6b32",
"assets/assets/3/4.jpg": "ef7450088932750360376501941b5a02",
"assets/assets/3/5.jpg": "cce9e17d50cb30bb4951a04cbf909f94",
"assets/assets/3/6.jpg": "490952330c7571357538163b2c86f323",
"assets/assets/3/7.jpg": "c29f1825fec3f627f38e9c11bfea9c2f",
"assets/assets/3/8.jpg": "8ed458ef25e5e6befc9ffd7fb41114f6",
"assets/assets/3/9.jpg": "2413c7c5b09522d7799bff7b7cfc5f5b",
"assets/assets/3/original.jpg": "3217c7b8a86f687b467d6ac38431d4d7",
"assets/assets/4/1.jpg": "96e450dd174870652a072b08c4637cf7",
"assets/assets/4/10.jpg": "2c88d2376af5a10acdcfe363c5bde187",
"assets/assets/4/11.jpg": "2e8596b7d887cc2ecfb27c0d56c24d48",
"assets/assets/4/12.jpg": "bd030abfd04a6a8a81ef08c5cc024c5f",
"assets/assets/4/13.jpg": "59dd656ab71bedd11132c2188b2181c1",
"assets/assets/4/14.jpg": "abf080fc1e4c8c5075724bfe18ee2070",
"assets/assets/4/15.jpg": "e8f67e334602c1c0351bf246cc39cfe8",
"assets/assets/4/16.jpg": "5c522f838d21ecc5145e1efa2acef7f6",
"assets/assets/4/2.jpg": "627cf7365e24649ac9d0f215c26ead89",
"assets/assets/4/3.jpg": "51195affce878b36ad646d435b4dd261",
"assets/assets/4/4.jpg": "c29c2973f0f3a9e5cde7042d38dc22a5",
"assets/assets/4/5.jpg": "2b6edeeda1b4bd6b4580b1a6fbf7e080",
"assets/assets/4/6.jpg": "09545d9da22b99c7f0bb8c1bc5d8f036",
"assets/assets/4/7.jpg": "5f09d02ef3c4fdad84a476a05abc9cd9",
"assets/assets/4/8.jpg": "cf063cf06010e70c29f9e4608f995b12",
"assets/assets/4/9.jpg": "15e10e1499d1f469202a7c525bd38ccd",
"assets/assets/4/original.jpg": "e5308a5885339c733852a16fd90de8f1",
"assets/assets/Choir%2520Harp%2520Bless.wav": "c8306f98b9d782ccff4b0e082b57417d",
"assets/assets/Color%2520Change.mp3": "24617ed00d64b1a3975ee18be4149609",
"assets/assets/Manrope-Light.ttf": "55aaaa1366df7c6544c2204b032a6e31",
"assets/assets/Not%2520Movable.wav": "97831eb8a8292c504de2832c7aa78200",
"assets/assets/Shuffle-Reset.wav": "373639729356e0bc67dc541646ac0fb9",
"assets/assets/Theme%2520Change.wav": "372c9cbc244b648821ba689afba1171b",
"assets/assets/Tile%2520Move.wav": "0d9e9c0a8b66b41442218e83d109f7b3",
"assets/FontManifest.json": "2a90b2bb182ec9e4b87ba58af198dcc7",
"assets/fonts/MaterialIcons-Regular.otf": "7e7a6cccddf6d7b20012a548461d5d81",
"assets/NOTICES": "ab591ae73eabf19e4f6f2bc98ab5a336",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "f20085ba08fc9c939337a2cfbf829bba",
"/": "f20085ba08fc9c939337a2cfbf829bba",
"main.dart.js": "2bc773a054fa8852670e58f3ed8db5a3",
"manifest.json": "d395b3891be5f7c314373c59b424641b",
"version.json": "8b661fa22f2592e1a550cfc4108dc5fa"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
