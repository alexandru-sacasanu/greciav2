/* Încarcă după toate fișierele *-data.js și înainte de loader.js.
   Lista include asseturile pachetelor precedente. Elimină folderele pe care NU le-ai instalat.
   Adaugă aici URL-uri Supabase pentru background-uri sau asseturi care nu sunt în DOM/date. */
window.HG_LOADER_CONFIG = {
  mode: 'all', // 'all' = toate resursele declarate; 'current' = destinația afișată, restul în fundal
  minWaitMs: 4000,
  maxWaitMs: 15000,
  dataWaitMs: 7000,
  imageTimeoutMs: 8000,
  concurrency: 4,
  warmBackground: true
};
window.HG_LOADER_ASSETS = {
  critical: ['loader-assets/loader-island.webp','loader-assets/loader-boat.webp'],
  all: [
    "assets/halkidiki-animated-base.png",
    "assets/lefkada-animated-base.png",
    "assets/thasos-animated-base.png",
    "assets/yacht.png",
    "coast-assets/foam-retreat.png",
    "coast-assets/halkidiki-scene.png",
    "coast-assets/lefkada-scene.png",
    "coast-assets/porto-katsiki.png",
    "coast-assets/sand-dry.png",
    "coast-assets/sand-wet.png",
    "coast-assets/thasos-scene.png",
    "coast-assets/wave-break.png",
    "coast-assets/wave-front.png",
    "coast-assets/wave-wash.png",
    "forest-assets/forest-gallery.png",
    "forest-assets/forest-main.png",
    "forest-assets/pine-branch.png",
    "forest-assets/pine-shadow.png",
    "forest-assets/stone-panel-lit-desktop.png",
    "forest-assets/stone-panel-lit-mobile.png",
    "harbor-assets/harbor-gallery.png",
    "harbor-assets/harbor-main.png",
    "harbor-assets/olive-branch.png",
    "harbor-assets/sail-desktop.png",
    "harbor-assets/sail-mobile.png",
    "peninsula-assets/atlas-desktop.png",
    "peninsula-assets/atlas-mobile.png",
    "peninsula-assets/olive-branch.png",
    "peninsula-assets/olive-shadow.png",
    "peninsula-assets/peninsula-gallery.png",
    "peninsula-assets/peninsula-main.png",
    "peninsula-assets/peninsula-mark.png",
    "road-assets/olive-branch.png",
    "road-assets/olive-shadow.png",
    "road-assets/road-gallery.png",
    "road-assets/road-main.png",
    "road-assets/route-desktop.png",
    "road-assets/route-mobile.png",
    "village-assets/olive-branch-v2.png",
    "village-assets/olive-shadow-v2.png",
    "village-assets/plaster.png",
    "village-assets/village-gallery.png",
    "village-assets/village-main.png"
],
  background: []
};
