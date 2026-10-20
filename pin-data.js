// Copy the coast-assets directory beside your index.html.
// Replace these paths with Supabase public image URLs whenever needed.
window.HG_PIN_PLACES = {
  lefkada: [
    {
      id: 'lefkada-porto-katsiki', title: 'Porto Katsiki',
      description: 'Faleze albe. Apă turcoaz.\nUn loc în care uiți să te uiți la ceas.',
      sea_label: 'IONIAN SEA',
      photos: [
        {url:'coast-assets/porto-katsiki.png', alt:'Imagine de prezentare a coastei Porto Katsiki'},
        {url:'coast-assets/lefkada-scene.png', alt:'Dioramă ilustrată Lefkada'}
      ],
      tags:[{label:'Plajă',icon:'beach'},{label:'Lefkada',icon:'pin'},{label:'Peisaje',icon:'landscape'}]
    },
    {
      id:'lefkada-village',title:'Satul de pe coastă',
      description:'Străduțe, terase și o priveliște către mare. Descoperă farmecul unei vacanțe în Lefkada.',
      sea_label:'IONIAN SEA',photos:[{url:'coast-assets/lefkada-scene.png',alt:'Sat de coastă în diorama ilustrată Lefkada'}],
      tags:[{label:'Sat de coastă',icon:'pin'},{label:'Lefkada',icon:'pin'},{label:'Peisaje',icon:'landscape'}]
    },
    {
      id:'lefkada-views',title:'Drumuri cu panoramă',
      description:'Urmărește coasta și lasă priveliștea să aleagă următoarea oprire.',
      sea_label:'IONIAN SEA',photos:[{url:'coast-assets/lefkada-scene.png',alt:'Drumuri panoramice într-o ilustrație Lefkada'}],
      tags:[{label:'Panoramă',icon:'landscape'},{label:'Lefkada',icon:'pin'},{label:'Coastă',icon:'beach'}]
    }
  ],
  halkidiki: [
    {id:'halkidiki-coves',title:'Golfuri din Sithonia',description:'Pădurea întâlnește marea într-un peisaj de pus pe lista vacanței tale.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/halkidiki-scene.png',alt:'Dioramă ilustrată Halkidiki'}]},
    {id:'halkidiki-villages',title:'Sate de pe coastă',description:'Descoperă plimbări la malul mării și inspirație pentru următoarea escapadă.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/halkidiki-scene.png',alt:'Sate de coastă într-o ilustrație Halkidiki'}],tags:[{label:'Sate',icon:'pin'},{label:'Halkidiki',icon:'pin'},{label:'Peisaje',icon:'landscape'}]},
    {id:'halkidiki-peninsulas',title:'Peninsulele Halkidiki',description:'O nouă perspectivă asupra golfurilor și țărmurilor din Halkidiki.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/halkidiki-scene.png',alt:'Panoramă ilustrată a peninsulelor Halkidiki'}],tags:[{label:'Coastă',icon:'beach'},{label:'Halkidiki',icon:'pin'},{label:'Explorare',icon:'landscape'}]}
  ],
  thasos: [
    {id:'thasos-coves',title:'Golfuri de marmură',description:'Verde de pădure, alb de coastă și nuanțe de turcoaz pentru vacanța ta.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/thasos-scene.png',alt:'Golfuri într-o dioramă ilustrată Thasos'}]},
    {id:'thasos-harbor',title:'Portul insulei',description:'Bărci, terase și ritmul liniștit al unei zile la malul mării.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/thasos-scene.png',alt:'Port într-o dioramă ilustrată Thasos'}],tags:[{label:'Port',icon:'pin'},{label:'Thasos',icon:'pin'},{label:'Coastă',icon:'beach'}]},
    {id:'thasos-views',title:'Păduri și panorame',description:'Descoperă o altă față a insulei, între dealuri verzi și priveliști spre mare.',sea_label:'AEGEAN SEA',photos:[{url:'coast-assets/thasos-scene.png',alt:'Dealuri verzi într-o ilustrație Thasos'}],tags:[{label:'Natură',icon:'landscape'},{label:'Thasos',icon:'pin'},{label:'Panoramă',icon:'landscape'}]}
  ]
};
