## 4 Regeln und Formeln

### Verbindliche Präzisierungen nach Review

Diese Definitionen ersetzen die entsprechenden Kurzfassungen in R4, R6–R8, R10 und R11 unten.
Die dortigen Beispiele gelten mit diesen Voraussetzungen.

- **R4 Verbrauch und keine Historie:** `consumptionPerDay` ist die Summe der bestätigten
  `Brew.doseG + Brew.purgeG` sowie `ConsumptionEvent.wasteG`, jeweils über `packId` der Bohne
  zugeordnet, im Fenster der 28 vollständigen lokalen Kalendertage vor heute, geteilt durch 28.
  Jeder Verbrauch wird genau einmal gezählt. Ein Waste-only-Ereignis ist Verbrauchshistorie.
  „Ohne Historie“ bedeutet weder eine berücksichtigte Brühung noch ein berücksichtigtes
  `ConsumptionEvent`. Bei leerem Fenster ist der Verbrauch 0. Beispiel: nur 56 g Waste in
  28 Tagen ergeben 2 g/Tag und den Standard-Mindestbestand 4 g, nicht 100 g.
- **R6 Autoritative Lückenberechnung:** Ausschliesslich die tageweise Simulation aus
  `contracts.md` entscheidet über Lücken. Zu jedem Tagesbeginn werden Bereitschaft und
  Alter jeder Packung geprüft; danach wird die volle Tagesnachfrage abgezogen. Nur an diesem
  Tag bereite, nicht alte Restbestände decken den Tag. Zwischenpackungen können Lücken
  schliessen, auslaufende Packungen sie eröffnen. `runOutDate = heute + floor(B / Verbrauch) − 1`
  ist nur eine vereinfachte Berechnung, wenn während des betrachteten Zeitraums keine Packung
  bereit oder zu alt wird. Sie ersetzt nie die Simulation. Beispiel: 90 g bei 18 g/Tag
  ab 16.11., weitere 36 g ab 21.11., nächste Packung ab 25.11. → Lücke nur 23.–24.11.
- **R7 Tatsächlicher Purge:** `deadSpaceG` ist nur ein Vorschlag. Gespeichert und abgezogen
  wird ausschliesslich `purgeG`, die vom Nutzer bestätigte tatsächliche Spülmenge.
  Ein Hinweis, vorausgefülltes Feld oder unbestätigter Entwurf bucht nichts.
  Beispiel: Vorschlag 2.5 g, tatsächlich bestätigt 1 g, Dosis 17 g → Abzug 18 g.
- **R8 Sekundenlimit:** `Machine.brewSecondsLimit` gehört ausschliesslich zur Aufgabe
  `backflush`, nicht zu `descale` oder `grinderClean`. Die Summe `brewSeconds` enthält die
  gespeicherten Espresso-Shotzeiten dieser Maschine seit ihrem letzten Backflush-Ereignis.
  Backflush-Abschluss setzt nur deren Tage-, Shot- und Sekundenzähler zurück. Entkalken setzt
  nur den Tagezähler der Entkalkungsaufgabe zurück, Mühlenreinigung nur deren eigenen
  Tagezähler. Ohne Ereignis gilt `createdOn`. Beispiel: 2970 + 30 s bei Limit 3000 s →
  Backflush fällig; Entkalken ändert diese 3000 s nicht, Backflush-Abschluss setzt sie auf 0.
- **R10 Grammauflösung:** Alle Wasserziele sind ganze Gramm. Vor Berechnung der Schritte:
  `waterTotalG = roundHalfUp(doseG × ratio)` und `bloomG = roundHalfUp(2 × doseG)`.
  Dann `pour1G = roundHalfUp(0.375 × waterTotalG)`,
  `pour2G = roundHalfUp(0.6875 × waterTotalG)`, letztes Ziel exakt `waterTotalG`.
  `roundHalfUp` rundet nichtnegative Werte bei .5 auf. Keine vorgelagerte Dosisrundung.
  Inkremente sind Differenzen der gerundeten Ziele, nicht separat gerundete Mengen.
  Beispiel: 15.25 g × 15 = 228.75 → 229 g; Bloom 30.5 → 31 g;
  erstes Ziel 85.875 → 86 g, zweites 157.4375 → 157 g, letztes 229 g.
  Inkremente 31, 55, 71, 72 g ergeben zusammen 229 g.
- **R11 Ergebnistypen:** Priorität Wasserhinweis (`water`), dann Ruhehinweis (`rest`),
  danach Mahlgradänderung (`grind`) oder keine Änderung (`none`). Die Bezeichnung
  „eine Variable: Mahlgrad“ gilt nur für den numerischen Brühparameter-Vorschlag nach den
  Vorrangprüfungen; sie schliesst Wasser-/Ruhehinweise und keine Änderung nicht aus.
  Beispiel: ausgewogen, 200 s, Wasser im Bereich, Packung bereit → `none`;
  gleiche Brühung mit Härte 300 ppm → `water`, ohne zusätzlichen Mahlgradvorschlag.

**R1 Härte-Umrechnung.** 1 °fH = 10 ppm; 1 °dH = 17.848 ppm. Anzeige auf 1 Dezimale gerundet (kaufmännisch).
Beispiel: Eingabe 15 °fH → 150.0 ppm. Eingabe 8.4 °dH → 8.4 × 17.848 = 149.9 ppm. 150 ppm → 15.0 °fH und 150 / 17.848 = 8.4 °dH.

**R2 Wasserprüfung (Daten in `assets/water_rules.json` ).** Bereiche: TDS 75–250 mg/L (Ziel 150); Gesamthärte 50–175 ppm; Alkalinität 40–75 ppm (Ziel
40); pH 6.5–7.5; Natrium ≤ 10 mg/L; Chlor 0. Die Grenzen Gesamthärte 50–175 und Alkalinität 40–75 sind Produkt-Referenzbereiche, nicht die
Calciumhärte 17–85 des historischen SCAA-Standards. Ein Parameter mit Wert `null` wird nicht geprüft und zeigt „nicht gemessen“/„not measured“; er
verhindert den Status „Gemessene Werte im Referenzbereich“ nicht. Der Status lautet „Gemessene Werte im Referenzbereich“, wenn alle gemessenen
Parameter im Bereich liegen, sonst „Ausserhalb Referenzbereich“; zusätzlich immer „{n} von 6 gemessen“. Die Kurzbezeichnung SCA meint hier das
gespeicherte Literaturprofil, keine Zertifizierung und keine Freigabe der Maschine; diese Empfehlung steht dann vor jeder anderen.
Beispiel: Leitungswasser 30 °fH = 300 ppm → 300 − 175 = 125 ppm über Maximum → „Wasser zuerst prüfen: Härte 300 ppm, SCA 50–175 ppm“. 15 °fH = 150
ppm, übrige Werte null → „Gemessene Werte im Referenzbereich“ (1 von 6 gemessen).

**R3 Ruhezeit.** `readyDate = roastDate + restDays(Methode, Röstgrad)` ; erst ab `readyDate` trinkbereit. Mindest-Ruhetage (untere Grenze des
Bereichs, `assets/rest_rules.json` ): Filter: light 7, medium 5, mediumDark 4, dark 3; Espresso: light 14, medium 10, mediumDark 7, dark 5. Eine
Packung ist „zu alt“, wenn heute ≥ `roastDate + 45` Tage. Zu alte Packungen zählen nicht als trinkbereit (nicht in `B` , nie als Vorschlag).
Beispiel: Röstdatum 2026-11-01, medium: Filter bereit 2026-11-06, Espresso bereit 2026-11-11, zu alt ab 2026-12-16 (1. Nov + 45 Tage).
Für Filter werden nur Packungen vorgeschlagen, die nach Filter-Ruhezeit bereit sind; Espresso-Blends (`kind = espressoBlend`) werden für Filter nicht
zuerst vorgeschlagen (nur nachrangig, wenn nichts anderes bereit ist). Sortierschlüssel einer Bohne in Listen: das früheste `readyDate` ihrer
Packungen (nach `restMethod` ).

**R4 Verbrauch.** Das Fenster sind die 28 vollständigen lokalen Kalendertage vor heute, Anfang inklusive, heute exklusive; zukünftige und gelöschte
Brühungen ausgeschlossen. `consumptionPerDay = Summe(doseG + purgeG aller Brühungen der Bohne in den letzten 28 Tagen) / 28` , ohne Rundung innerhalb
der Formel (Anzeige auf 1 Dezimale). Ohne Brühung in 28 Tagen: `consumptionPerDay = 0` .
Beispiel: 504 g in 28 Tagen → 504 / 28 = 18 g/Tag.

**R5 Mindestbestand und Bestellhinweis.** `minStockG = Bean.minStockG ?? 2 × consumptionPerDay` ; bei `consumptionPerDay = 0` und ohne Bean-Wert: 100
g. `restDays` gemäss `restMethod` der Bohne (R3), `leadTimeDays` der Bohne. `orderPoint = consumptionPerDay × (leadTimeDays + restDays) + minStockG` .
Bestellhinweis, wenn Gesamtbestand der Bohne (alle nicht zu alten Packungen, auch ruhende) ≤ orderPoint.
Beispiel: 18 g/Tag, Lieferzeit 3, Ruhetage 10 (Espresso medium): Mindestbestand 36 g; orderPoint = 18 × (3 + 10) + 36 = 270 g. Bestand 250 g → Hinweis
„jetzt bestellen“ (250 / 18 = 13.9 Tage Reichweite). Bestand 300 g → kein Hinweis. Ohne Verbrauch: orderPoint = 0 × 13 + 100 = 100 g.

**R6 Lückenwarnung.** Nur wenn `consumptionPerDay > 0` (sonst keine Berechnung, keine Warnung). Trinkbereiter Bestand `B` = Summe `remainingG` der
Packungen mit `readyDate ≤ heute` und nicht zu alt (R3). `runOutDate = heute + floor(B / consumptionPerDay) − 1` (letzter gedeckter Tag; floor nur
hier). `nextReady` = früheste `readyDate` einer noch ruhenden Packung; gibt es keine, `heute + leadTimeDays + restDays` (Bestellung heute). Lücke von
`runOutDate + 1` bis `nextReady − 1` , wenn `nextReady > runOutDate + 1` . Warnung mit Datum von–bis. Aktion:
- trinkbereite, ungeöffnete Packung X vorhanden und keine geöffnete trinkbereite Packung mit Rest > 0 → „Packung X öffnen“ (X = früheste Röstung);
- geöffnete trinkbereite Packung vorhanden → „Jetzt bestellen“;
- keine trinkbereite Packung (B = 0) → „Jetzt bestellen“.
Beispiel 1 (ungeöffnete Packung X): heute 2026-11-16, B = 90 g, 18 g/Tag → floor(90/18) = 5 → runOutDate 2026-11-20; ruhende Packung bereit 2026-11-25
→ Lücke 2026-11-21 bis 2026-11-24 (4 Tage); Aktion „Packung X öffnen“.
Beispiel 2 (geöffnete Packung, keine ruhende): B = 90 g, nextReady = 16. Nov + 3 + 10 = 2026-11-29 → Lücke 2026-11-21 bis 2026-11-28; Aktion „Jetzt
bestellen“.
Beispiel 3 (B = 0): runOutDate = 2026-11-15, Lücke 2026-11-16 bis 2026-11-28; Aktion „Jetzt bestellen“.

**R7 Totraum.** Bohnenwechsel = Wechsel der Bohnen-`id` an einer Mühle (nicht: neue Packung derselben Bohne oder anderer Röstgrad). Bei einem
Bohnenwechsel oder wenn die Mühle ≥ 24 h ungenutzt war (Standardwert ohne Quelle, in `assets/care_rules.json` änderbar) empfiehlt die App,
`deadSpaceG` vorab zu mahlen und zu verwerfen. Die Menge wird als `purgeG` der Brühung gespeichert. Bestandsabzug der Packung = `doseG + purgeG` .
Beispiel: Dosis 17 g, Totraum 2.5 g → 2.5 g verwerfen, dann 17 g; Abzug 19.5 g.

**R8 Reinigung (Daten `assets/care_rules.json` ).** Pro Maschine werden die Espresso-Shots seit dem letzten Ereignis gezählt (Anzahl Brühungen mit
dieser `machineId` ). Backflush-Erinnerung bei ≥ 200 Shots oder ≥ 7 Tagen seit letztem Backflush (was zuerst eintritt); beide sind editierbare
Produktdefaults, keine universellen Herstellerwerte. Entkalken nach Härte des Standard-Wasserprofils: > 150 ppm alle 30 Tage; 100–150 ppm alle 60
Tage; < 100 ppm alle 90 Tage. Das Maschinenhandbuch hat Vorrang. `backflushSupported` ist standardmässig false; ohne Bestätigung der Geräte-Eignung
erscheint nur „Handbuch prüfen“ / „Check manual“, keine Backflush-Anleitung. Entkalkungswerte sind editierbare Erinnerungsdefaults, keine automatische
Handlungsanweisung. Die Mühlenreinigung ist nach 28 Tagen fällig (Standardwert ohne Quelle). Der Shot-Timer wird zusätzlich als `brewSeconds` pro
Maschine seit dem Pflegeereignis summiert; eine optionale maschinenspezifische `brewSecondsLimit` löst Pflege aus, sobald die Summe das Limit
erreicht. Ohne manuelles Limit gilt nur Tage/Shot-Anzahl. Kein universelles Sekundenlimit wird erfunden. Beispiel: Limit 3000 s, bisher 2970 s, neuer
Shot 30 s → 3000 s, fällig.
Beispiel: Letzter Backflush 2026-11-10, bis 2026-11-16 insgesamt 90 Shots → 6 Tage, nicht fällig; am 2026-11-17 fällig (7 Tage). Wasser 120 ppm,
letztes Entkalken 2026-10-01 → fällig 2026-11-30 (1. Okt + 60 Tage).

**R9 Espresso-Empfehlung (genau eine Variable).** Ein einziges Band für Ziel und „keine Änderung“: Shot-Zeit 25–30 s (Standardverhältnis 1:2, 18 g →
36 g). Prüfreihenfolge, die erste zutreffende gewinnt, und nur sie wird genannt: (1) Wasser ausserhalb R2 → Wasser; (2) Packung vor Espresso-Ruhezeit
(R3) → „noch ruhen lassen“; (3) Mahlgrad. Mahlgrad: **die Shot-Zeit hat Vorrang vor dem Geschmack** (Quelle: erst Zeitfenster per Mahlgrad, dann
Geschmack):
- Zeit < 25 s → feiner; Zeit > 30 s → gröber (unabhängig vom Geschmack); Schrittweite 2 Rasterstufen bei Zeit < 20 s oder > 35 s, sonst 1;
- Zeit 25–30 s: `sour` oder `weak` → feiner, `bitter` → gröber, je 1 Rasterstufe; `balanced` → keine Änderung.
„Feiner“ bedeutet Skalenrichtung `finerDirection` . Ergebnis wird auf `scaleMin..scaleMax` begrenzt. Jede Empfehlung hat `reason` und `source` (URL).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 12.0, sauer, 27 s, Wasser im Bereich, Packung bereit → 11.5 (1 Stufe feiner).
Bitter, 17 s → Zeit gewinnt: feiner, 2 Stufen → 11.0. Weak, 40 s → gröber, 2 Stufen → 13.0. Sauer, 38 s → gröber, 2 Stufen → 13.0. Ausgewogen, 22 s →
feiner, 1 Stufe → 11.5. Ausgewogen, 27 s → keine Änderung. Einstellung 1.0 und feiner → bleibt 1.0 mit Hinweis „Skalenende“.

**R10 Filter-Rezept.** Wasser `W = dose × ratio` (Standard 1:16, erlaubt 1:14–1:18, Schritt 0.5, Auflösung 1 g). Bloom = 2 × Dosis bei 0:00 für 45 s;
Zwischensummen (kumulatives Wasser) nach 0:45: round(0.375 × W); nach 1:15: round(0.6875 × W); nach 2:00: W. Ziel-Gesamtzeit 3:00–3:30 (180–210 s);
Wassertemperatur 92–96 °C. Abfluss > 4:00 → gröber, < 2:45 → feiner.
Beispiel: 20 g, 1:16 → W = 320; Bloom 40 g; Summen 120 g (0:45), 220 g (1:15), 320 g (2:00). 15 g, 1:15 → W = 225; Bloom 30; 0.375 × 225 = 84.4 → 84;
0.6875 × 225 = 154.7 → 155; 225.

**R11 Filter-Empfehlung (genau eine Variable: Mahlgrad).** Prüfreihenfolge wie R9: (1) Wasser (R2); (2) Packung vor Filter-Ruhezeit (R3); (3) Mahlgrad
nach `drawdownS` (Zeit hat Vorrang vor Geschmack): `drawdownS` > 240 s → gröber, < 165 s → feiner (je 1 Stufe; 2 Stufen bei > 270 s oder < 150 s;
Schwellen 270/150 sind Standardwerte ohne Quelle); im Fenster 165–240 s: `sour` /`weak` → feiner, `bitter` → gröber (1 Stufe), `balanced` → keine
Änderung. Das Verhältnis wird nie automatisch empfohlen. Quelle der 240/165-s-Grenzen: Coffee Hero (Abfluss > 4:00 bzw. < 2:45).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 20.0, Abfluss 255 s, bitter → gröber 1 Stufe → 20.5. Abfluss 150 s → 150 ist
nicht < 150, also 1 Stufe feiner: 19.5; Abfluss 140 s → 2 Stufen feiner: 19.0. Abfluss 200 s, sauer → 19.5.
