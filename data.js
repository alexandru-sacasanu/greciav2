/* Shared browser data layer; SDK loaded only when configuration exists. */
window.HG = (() => {
 const cfg=window.HELLO_GRECIA_CONFIG||{};let promise;
 const configured=Boolean(cfg.supabaseUrl&&cfg.supabaseKey);
 async function client(){
  if(!configured)return null;
  if(!promise)promise=(async()=>{
   const url=new URL(cfg.supabaseUrl);if(url.protocol!=='https:'&&url.hostname!=='localhost'&&url.hostname!=='127.0.0.1')throw Error('Supabase URL invalid.');
   if(cfg.supabaseKey.startsWith('sb_secret_'))throw Error('Folosește cheia publică, nu secretă.');
   try{const payload=JSON.parse(atob(cfg.supabaseKey.split('.')[1]));if(payload.role==='service_role')throw Error('Cheia service_role nu este permisă în browser.')}catch(e){if(e.message.includes('service_role'))throw e;}
   if(!window.supabase)await new Promise((resolve,reject)=>{const s=document.createElement('script');s.src='https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';s.onload=resolve;s.onerror=()=>reject(Error('Biblioteca Supabase nu s-a încărcat.'));document.head.append(s)});
   const admin=document.body.dataset.admin==='true';return window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseKey,{auth:{persistSession:admin,autoRefreshToken:admin,detectSessionInUrl:false,storageKey:admin?'hg-admin':'hg-public'}});
  })();return promise;
 }
 function unwrap(result){if(result.error)throw result.error;return result.data;}
 function escape(value){return String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
 function mediaUrl(media){if(!media?.storage_path)return '';return cfg.supabaseUrl.replace(/\/$/,'')+'/storage/v1/object/public/site-media/'+media.storage_path.split('/').map(encodeURIComponent).join('/');}
 const typeLabels={accommodation:'Cazări',excursion:'Excursii',cruise:'Croaziere',rental:'Închirieri'};
 const units={night:'noapte',person:'persoană',day:'zi',trip:'excursie'};
 return {configured,client,unwrap,escape,mediaUrl,typeLabels,units};
})();
