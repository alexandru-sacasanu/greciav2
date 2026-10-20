/* Router unic: coastă, sate, păduri, port, drumuri și peninsule. Înlocuiește toate adaptoarele de pini anterioare. */
(() => {
 const savedPlaces=new Set();
 document.querySelectorAll('[data-place]').forEach((pin,index)=>{
  pin.onclick=()=>{
   const destination=currentDestination();if(!destination)return;
   const kind=pin.dataset.placeKind || (destination.slug==='halkidiki'&&index===2?'peninsula':destination.slug==='lefkada'&&index===2?'road':destination.slug==='thasos'?(index===2?'forest':index===1?'harbor':'coast'):index===1?'village':'coast');
   const data={coast:window.HG_PIN_PLACES,village:window.HG_VILLAGE_PLACES,forest:window.HG_FOREST_PLACES,harbor:window.HG_HARBOR_PLACES,road:window.HG_ROAD_PLACES,peninsula:window.HG_PENINSULA_PLACES};
   const modals={coast:window.HGCoastalPin,village:window.HGVillagePin,forest:window.HGForestPin,harbor:window.HGHarborPin,road:window.HGRoadPin,peninsula:window.HGPeninsulaPin};
   const place=kind==='coast'?data.coast?.[destination.slug]?.[index]:data[kind]?.[destination.slug];
   const modal=modals[kind];
   if(!place||!modal){console.warn('Lipsesc datele sau componenta pentru pin.',destination.slug,index);return;}
   modal.open({...place,destination_id:destination.id,destination_name:destination.name},{
    isFavorite:id=>savedPlaces.has(id),
    onFavorite:id=>savedPlaces.has(id)?savedPlaces.delete(id):savedPlaces.add(id),
    onExplore:()=>showCategory(destination.id,'excursion'),
    onStays:()=>showCategory(destination.id,'accommodation')
   });
  };
 });
 function showCategory(id,type){
  category=type;onlyFavorites=false;guestFilter=null;select(id);
  document.getElementById('stays')?.scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});
 }
})();
