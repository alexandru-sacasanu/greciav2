/* Fotografii ilustrative generate; înlocuiește cu imagini reale sau URL-uri Supabase. */
window.HG_VILLAGE_PLACES = Object.fromEntries([
 ['lefkada','Lefkada','Satele de pe coastă'],
 ['halkidiki','Halkidiki','Satele de pe coastă'],
 ['thasos','Thasos','Portul insulei']
].map(([slug,name,title]) => [slug,{
 id:slug+'-villages',title,destination_name:name,
 description:'Străduțe albe, obloane albastre și seri care se prelungesc la o tavernă. Descoperă farmecul vieții de pe coastă.',
 photos:[
  {url:'village-assets/village-main.png',alt:'Ilustrație: străduță grecească, flori și vedere spre mare'},
  {url:'village-assets/village-gallery.png',alt:'Ilustrație: terasă grecească lângă mare'}
 ],
 tags:[{label:'Plimbări',icon:'walk'},{label:'Taverne',icon:'food'},{label:'Tradiții',icon:'church'}],
 explore_label:slug==='thasos'?'Explorează portul':'Descoperă satele'
}]));
