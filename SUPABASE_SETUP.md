# Hello Grecia — configurare Supabase și admin

Acest pachet include site-ul panoramic animat, schema SQL, panoul admin și integrarea catalogului. Nu este conectat încă la un proiect Supabase real și nu modifică proiectul tău până nu rulezi pașii de mai jos.

## 1. Creează baza de date

Într-un proiect Supabase nou, deschide SQL Editor și rulează integral:

`supabase/migrations/001_cms.sql`

Migrarea rulează într-o tranzacție, creează tabelele, regulile de acces, bucketul Storage și cele trei destinații. Nu este un script de resetare. Rulează o singură dată; nu îl aplica peste tabele cu aceleași nume fără o migrare adaptată. Nu include oferte fictive publicate.

Tabelele și funcțiile din schema public trebuie să fie accesibile prin Data API în setările proiectului. Schema private NU se expune prin Data API.

## 2. Creează primul administrator

În Authentication → Users, creează un utilizator cu email și parolă. Configurează confirmarea emailului conform fluxului ales în Supabase. Adminul din acest pachet folosește email/parolă; nu oferă înscriere publică.

Deschide `supabase/bootstrap-admin.sql`, înlocuiește `CHANGE_ME@example.com` cu emailul acelui utilizator și rulează scriptul în SQL Editor. Acesta acordă rolul admin prin UUID-ul din Auth, într-un tabel privat. Simpla creare a unui cont NU acordă acces admin.

Pentru alți administratori, repetă acest pas. Conturile admin și parolele se gestionează în Supabase Authentication; panoul nu poate acorda singur roluri.

## 3. Conectează site-ul

Completează `config.js`:

```js
window.HELLO_GRECIA_CONFIG = {
  supabaseUrl: 'https://PROIECTUL-TAU.supabase.co',
  supabaseKey: 'sb_publishable_...'
};
```

URL-ul și cheia publishable se iau din proiectul Supabase, din setările API/Connect. O cheie legacy anon este acceptată. Aceste valori pot fi publice: politicile RLS controlează accesul la date. Nu folosi service_role, sb_secret sau parola bazei de date în frontend. Parola adminului se introduce numai în formularul de login.

## 4. Deschide adminul

Servește folderul prin HTTP:

```sh
cd hello-grecia
python3 -m http.server 8000
```

Site: http://localhost:8000/
Admin: http://localhost:8000/admin/

Pentru Netlify, publică folderul hello-grecia fără build command. Adminul este /admin/ pe același domeniu. Loginul folosește Supabase Auth, iar RLS validează toate modificările în DB. Mutarea/ascunderea URL-ului adminului nu este mecanismul de autorizare.

## 5. Mută imaginile în Supabase

În admin → Destinații, apasă **Importă panoramele și iahtul în Supabase**. Imaginile incluse sunt încărcate în Storage și legate de destinații/setări. Importul omite panoramele deja configurate și iahtul deja ales. După import, sursele acestor imagini sunt Supabase; fallbackurile locale sunt păstrate pentru pornirea inițială.

În Bibliotecă foto poți încărca JPG/PNG/WebP/AVIF de maximum 10 MB fiecare, edita textul alternativ și șterge fotografii nefolosite. Panoramele se aleg în Destinații; logo-ul și PNG-ul transparent al iahtului în Aspect și texte.

Imaginile sunt într-un bucket PUBLIC pentru marketing. Chiar dacă oferta este ciornă, un URL cunoscut al imaginii rămâne accesibil. Nu încărca documente private sau date personale în acest bucket. Schimbarea stării ofertei nu revocă accesul la un URL public deja cunoscut.

## 6. Adaugă conținut

Oferte → Ofertă nouă:
- Alege destinația și tipul: cazare, excursie, croazieră sau închiriere.
- La închirieri alege mașină sau ATV.
- Adaugă titlu, slug, localitate, texte, preț orientativ, monedă și unitate.
- Opțional: capacitate, dormitoare pentru cazări, durată pentru excursii/croaziere, facilități și ce include.
- Adaugă fotografii din bibliotecă. Prima din galerie este coperta; săgețile schimbă ordinea.
- Păstrează Ciornă pentru conținut nepublicat sau alege Publicată.
- Salvează oferta. Oferta și galeria se salvează atomic prin funcția save_offer.

Numărul de ordine mai mic apare primul. Ofertele Recomandate au un badge; ordinea este controlată separat. Destinația inactivă ascunde și ofertele sale. Publicul vede numai oferte Publicate în destinații active. Site-ul public nu reutilizează sesiunea adminului.

Ștergerea unei oferte elimină legăturile galeriei, dar păstrează fișierele în bibliotecă. Ștergerea unei fotografii folosite este blocată de foreign keys. Scoate-o din oferte, panorame, logo sau iaht și salvează înainte să o ștergi. Dacă eliminarea fișierului Storage eșuează după ștergerea înregistrării, adminul arată calea pentru curățare manuală în Storage.

## 7. Aspectul site-ului

Aspect și texte controlează numele, logo-ul, titlul/subtitlul principal, butonul de căutare, titlul catalogului, meniul, denumirile categoriilor, cele trei avantaje, emailul de contact, subsolul, culorile principale și animația. Destinații controlează numele, descrierea, panorama, vizibilitatea, ordinea, pinii ilustrativi și poziția/afișarea iahtului.

Modificările apar la reîncărcarea paginii publice; nu este necesar un deploy pentru schimbările de conținut. Structura HTML, breakpointurile, tipurile de ofertă și animațiile CSS rămân în cod — acesta este un CMS, nu un editor vizual de layout.

## Ce NU include

Nu există încă rezervări, stoc de camere/vehicule, calendare de disponibilitate, tarife sezoniere, plăți sau gestionare de clienți. Datele formularului nu verifică disponibilitatea reală. Butonul Solicită detalii deschide emailul configurat. Prețurile sunt orientative. Favoritele sunt locale sesiunii paginii.

Fără config.js completat, site-ul arată exemplele locale. După configurare, nu afișează exemple drept fallback dacă baza de date e goală sau conexiunea eșuează.

## Verificări

Testele incluse rulează cu `npm install` și `npm test` (dependențele sunt numai pentru QA). PGlite verifică migrarea și RLS pe un PostgreSQL încorporat, cu scheme Auth/Storage simulate; DOM-ul simulat verifică catalogul și adminul. Au fost verificate autorizarea, ascunderea ciornelor/destinațiilor inactive, regulile Storage, relațiile, salvarea atomică a galeriei, filtrarea și escaparea textului.

Nu s-a făcut testare pe un proiect Supabase live, upload real prin Storage, login real sau verificare vizuală în browser. După configurare verifică loginul admin, un upload, publicarea unei oferte și vizibilitatea ei într-o fereastră incognito.

Surse oficiale folosite:
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/storage/security/access-control
- https://supabase.com/docs/reference/javascript/installing
- https://supabase.com/docs/reference/javascript/auth-signinwithpassword
