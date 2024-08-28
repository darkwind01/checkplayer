## [1.1.2] - 29/08/2024

### Fixed
- Corectata logica de extragere a numelui clanului pentru a gestiona corect diferite formate, inclusiv nume care incep cu . sau [].
- Numele clanului este acum afisat corect in toate cazurile.
- Numele jucatorilor prea lungi care nu incapeau sub skin apar acum corect.
- Numele jucatorilor prea lungi sunt afisate corect acum in paragraful "Faction History", evitand afisarea eronata a informatiilor in acea categorie.

## [1.1.1] - 23/08/2024

### Added
- Acum daca player ul este pe sleep apare si in /check (pana acum aparea doar daca e online/offline).
- Adaugat Faction Warns daca jucatorul are factiune.
- Adaugat Faction Punish daca jucatorul are factiune.1
- Adaugat un mesaj in cazul in care nu este gasit jucatorul sau panel ul este picat si nu se pot lua informatii.

### Fixed
- Acum apare corect factiunea TTC in paragraful 'Faction', pana acum aparea tot text ul ce facea sa nu se incadreze in paragraf.
- Scoase mai multe functii inutile ce ingreuna cod-ul.

## [1.1.0] - 20/08/2024

### Added
- Acum factiunea este afisata corect in meniu.
- Acum apare doar initiala factiunii in meniu (pentru ca era prea mare numele).
- Adaugat Faction History (deoarece au intrat jucatorii in factiuni).
- Adaugata iconita la timestamp-ul factiunii.

### Fixed
- Rezolvate un bug ce facea sa nu afiseze corect clan-ul.
- Rezolvat un modul ce nu se incarca corect si facea ca modul sa nu functioneze uneori.
- Acum se actualizeaza mod-ul corect, pana acum daca modul avea o versiune mai mare ca cea actuala spama update-ul.