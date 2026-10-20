# Hello Grecia — site + Supabase CMS

Site panoramic animat fără video, cu Lefkada, Halkidiki și Thasos. Include cazări, excursii, croaziere și închirieri auto/ATV, plus panou admin pentru conținut, fotografii, publicare și aspect.

**Începe cu SUPABASE_SETUP.md.** Migrarea este supabase/migrations/001_cms.sql. Diagrama și tabelele sunt în supabase/SCHEMA.md.

Site: index.html. Admin: admin/index.html. Completează config.js doar cu URL-ul Supabase și cheia publică. Fără configurare, site-ul funcționează ca demonstrație locală. Pentru admin și importul imaginilor folosește un server HTTP.

Nu include rezervări, disponibilitate în timp real sau plăți. Proiectul Supabase nu a fost conectat/aplicat automat. Testele de DB/DOM sunt în tests; pentru rulare: npm install și npm test. Nu este necesar npm pentru servirea site-ului.
