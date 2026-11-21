# Kaffee-Begleiter (Flutter) – Spezifikation COF-44

App-Ordner: `coffee/flutter/claude`. Ziel: Android und iOS; lokal getestet auf dem Android-Emulator und in Chrome.

## 1 Ziel und Scope

**Ziel:** Eine App, die einen Kaffeeliebhaber beim Kaffeegenuss führt: Brühungen mit Maschine, Mühle, Einstellungen und Shot-Timer erfassen; Bohnenbestand und Ruhezeit führen; Wasserwerte prüfen; Reinigungsintervalle aus der Nutzung ableiten; nach Geschmacksrückmeldung genau eine Verbesserung empfehlen (Espresso und Filter); Filterkaffee Schritt für Schritt mit Gramm-Zwischensummen und Timer anleiten.

**In Scope:** mehrere Mühlen (Beispiel: 4 Typen) und Maschinen; Bohnen mehrerer Röster, dieselbe Bohne mehrfach (Packungen); Bestell- und Lückenwarnung; Wasserprofile; Espresso und Filter (V60, Chemex, Kalita, AeroPress, Batch); lokale Speicherung; JSON-Export/-Import; Deutsch und Englisch.

**Out of Scope:** Login, mehrere Nutzer, Cloud-Sync (späteres Epic; das Datenmodell ist dafür vorbereitet), Bestell-Abwicklung bei Röstern, Web-Release als Produkt (Chrome dient nur zum Testen).

## 2 Nutzer und Use Cases

Ein Nutzer, kein Login, offline.

- UC1 Mühle anlegen (Skala, Totraum) und Maschine anlegen (Einstellungen, Standard-Wasserprofil).
- UC2 Bohne mit Röster, Röstdatum, Röstgrad, Packungsgrösse erfassen; mehrere Packungen derselben Bohne.
- UC3 Espresso-Brühung erfassen (Maschine, Mühle, Mahlgrad, Dosis, Ausbeute, Shot-Timer, Wasser) und Geschmack bewerten.
- UC4 Empfehlung zur Verbesserung erhalten (genau eine Variable, mit Grund und Quelle; Espresso nach R9, Filter nach R11).
- UC5 Filterkaffee geführt brühen (Methode, Verhältnis, Bloom, Aufgüsse, Timer).
- UC6 Wasserprofil erfassen und gegen den SCA-Bereich prüfen.
- UC7 Reinigungs- und Entkalkungsfälligkeit sehen und quittieren.
- UC8 Bestandsstatus, Bestellhinweis und Lückenwarnung sehen.
- UC9 Daten als JSON exportieren/importieren.

## 3 Domänenmodell

Jeder Datensatz: `id` (UUIDv4, String, stabil), `createdAt`, `updatedAt` (UTC ISO-8601, ms), `deletedAt` (nullable). Gespeichert mit drift/SQLite. Datumsfelder `roastDate`, `readyDate`, `doneAt`-Tag sind reine Datumswerte (`YYYY-MM-DD`, ohne Zeitzone). „Heute“ ist immer das lokale Kalenderdatum des Geräts.

**Löschen:** Mühle, Maschine, Bohne, Packung, Wasserprofil werden nie hart gelöscht: `deletedAt` wird gesetzt und `updatedAt = deletedAt`. Der Datensatz verschwindet aus Listen und Auswahlfeldern, bleibt aber für Brühungen und Historie auflösbar. Brühungen und Pflegeereignisse dürfen ebenfalls so gelöscht werden.

| Entität | Felder (Typ, Einheit) |
|---|---|
| Grinder (Mühle) | name; `scaleMin`, `scaleMax`, `scaleStep` (Dezimalzahl, Rasterstufe wie das Gerät wirklich rastet, z. B. 0.5); `finerDirection` (`down`\|`up`); `deadSpaceG` (g, Totraum/Retention) |
| Machine | name; `brewTempC` (°C); `preinfusionS` (s); `pressureProfile` (Text); `defaultWaterProfileId` |
| WaterProfile | name; `hardnessPpm` (ppm als CaCO₃, Pflicht, gespeichert); optional (nullable): `alkalinityPpm`, `tdsPpm`, `ph`, `sodiumMgL`, `chlorineMgL` |
| Bean | name; roaster; `roastLevel` (`light`\|`medium`\|`mediumDark`\|`dark`); `kind` (`espressoBlend`\|`filter`\|`allround`); `minStockG` (nullable = Standard); `leadTimeDays` (Lieferzeit, Standard 3, auf Bohnenebene) |
| Pack (Packung) | beanId; `roastDate`; `sizeG` (g); `remainingG` (g); `openedAt` (nullable) |
| Brew | `method` (`espresso`\|`v60`\|`chemex`\|`kalita`\|`aeropress`\|`batch`); `machineId` (Pflicht bei `espresso`, sonst null); grinderId; packId; `grindSetting`; `doseG`; `purgeG` (g, Standard 0, verworfener Totraum); `yieldG` (nur Espresso); `shotTimeS` (s, nur Espresso); `waterTempC`; waterProfileId; Filter: `waterTotalG`, `bloomG`, `pours` (Liste `{atS, cumulativeG}`), `drawdownS` (s); `taste` (`sour`\|`bitter`\|`weak`\|`balanced`); `rating` 1–5; note; `startedAt` |
| CareEvent | machineId oder grinderId; `kind` (`backflush`\|`descale`\|`grinderClean`); `doneAt` |
| Setting | `hardnessUnit` (`fH`\|`dH`\|`ppm`, Standard `fH`) |

Einheiten: g, ml, s, °C; Härte intern ppm. Wasser: 1 g = 1 ml. Welche Ruhezeit-Methode für eine Bohne gilt (`restMethod`): `espressoBlend` und `allround` → Espresso (die längere Ruhezeit), `filter` → Filter.

## 4 Regeln und Formeln

**R1 Härte-Umrechnung.** 1 °fH = 10 ppm; 1 °dH = 17.848 ppm. Anzeige auf 1 Dezimale gerundet (kaufmännisch).
Beispiel: Eingabe 15 °fH → 150.0 ppm. Eingabe 8.4 °dH → 8.4 × 17.848 = 149.9 ppm. 150 ppm → 15.0 °fH und 150 / 17.848 = 8.4 °dH.

**R2 Wasserprüfung (Daten in `assets/water_rules.json`).** Bereiche: TDS 75–250 mg/L (Ziel 150); Gesamthärte 50–175 ppm; Alkalinität 40–75 ppm (Ziel 40); pH 6.5–7.5; Natrium ≤ 10 mg/L; Chlor 0. Ein Parameter mit Wert `null` wird nicht geprüft und zeigt „nicht gemessen“/„not measured“; er verhindert den Status „Im SCA-Bereich“ nicht. Der Status lautet „Im SCA-Bereich“, wenn alle gemessenen Parameter im Bereich liegen, sonst „Ausserhalb SCA“; diese Empfehlung steht dann vor jeder anderen.
Beispiel: Leitungswasser 30 °fH = 300 ppm → 300 − 175 = 125 ppm über Maximum → „Wasser zuerst prüfen: Härte 300 ppm, SCA 50–175 ppm“. 15 °fH = 150 ppm, übrige Werte null → „Im SCA-Bereich“ (1 von 6 gemessen).

**R3 Ruhezeit.** `readyDate = roastDate + restDays(Methode, Röstgrad)`; erst ab `readyDate` trinkbereit. Mindest-Ruhetage (untere Grenze des Bereichs, `assets/rest_rules.json`): Filter: light 7, medium 5, mediumDark 4, dark 3; Espresso: light 14, medium 10, mediumDark 7, dark 5. Eine Packung ist „zu alt“, wenn heute ≥ `roastDate + 45` Tage. Zu alte Packungen zählen nicht als trinkbereit (nicht in `B`, nie als Vorschlag).
Beispiel: Röstdatum 2026-11-01, medium: Filter bereit 2026-11-06, Espresso bereit 2026-11-11, zu alt ab 2026-12-16 (1. Nov + 45 Tage).
Für Filter werden nur Packungen vorgeschlagen, die nach Filter-Ruhezeit bereit sind; Espresso-Blends (`kind = espressoBlend`) werden für Filter nicht zuerst vorgeschlagen (nur nachrangig, wenn nichts anderes bereit ist). Sortierschlüssel einer Bohne in Listen: das früheste `readyDate` ihrer Packungen (nach `restMethod`).

**R4 Verbrauch.** `consumptionPerDay = Summe(doseG + purgeG aller Brühungen der Bohne in den letzten 28 Tagen) / 28`, ohne Rundung innerhalb der Formel (Anzeige auf 1 Dezimale). Ohne Brühung in 28 Tagen: `consumptionPerDay = 0`.
Beispiel: 504 g in 28 Tagen → 504 / 28 = 18 g/Tag.

**R5 Mindestbestand und Bestellhinweis.** `minStockG = Bean.minStockG ?? 2 × consumptionPerDay`; bei `consumptionPerDay = 0` und ohne Bean-Wert: 100 g. `restDays` gemäss `restMethod` der Bohne (R3), `leadTimeDays` der Bohne. `orderPoint = consumptionPerDay × (leadTimeDays + restDays) + minStockG`. Bestellhinweis, wenn Gesamtbestand der Bohne (alle nicht zu alten Packungen, auch ruhende) ≤ orderPoint.
Beispiel: 18 g/Tag, Lieferzeit 3, Ruhetage 10 (Espresso medium): Mindestbestand 36 g; orderPoint = 18 × (3 + 10) + 36 = 270 g. Bestand 250 g → Hinweis „jetzt bestellen“ (250 / 18 = 13.9 Tage Reichweite). Bestand 300 g → kein Hinweis. Ohne Verbrauch: orderPoint = 0 × 13 + 100 = 100 g.

**R6 Lückenwarnung.** Nur wenn `consumptionPerDay > 0` (sonst keine Berechnung, keine Warnung). Trinkbereiter Bestand `B` = Summe `remainingG` der Packungen mit `readyDate ≤ heute` und nicht zu alt (R3). `runOutDate = heute + floor(B / consumptionPerDay) − 1` (letzter gedeckter Tag; floor nur hier). `nextReady` = früheste `readyDate` einer noch ruhenden Packung; gibt es keine, `heute + leadTimeDays + restDays` (Bestellung heute). Lücke von `runOutDate + 1` bis `nextReady − 1`, wenn `nextReady > runOutDate + 1`. Warnung mit Datum von–bis. Aktion:
- trinkbereite, ungeöffnete Packung X vorhanden und keine geöffnete trinkbereite Packung mit Rest > 0 → „Packung X öffnen“ (X = früheste Röstung);
- geöffnete trinkbereite Packung vorhanden → „Jetzt bestellen“;
- keine trinkbereite Packung (B = 0) → „Jetzt bestellen“.
Beispiel 1 (ungeöffnete Packung X): heute 2026-11-16, B = 90 g, 18 g/Tag → floor(90/18) = 5 → runOutDate 2026-11-20; ruhende Packung bereit 2026-11-25 → Lücke 2026-11-21 bis 2026-11-24 (4 Tage); Aktion „Packung X öffnen“.
Beispiel 2 (geöffnete Packung, keine ruhende): B = 90 g, nextReady = 16. Nov + 3 + 10 = 2026-11-29 → Lücke 2026-11-21 bis 2026-11-28; Aktion „Jetzt bestellen“.
Beispiel 3 (B = 0): runOutDate = 2026-11-15, Lücke 2026-11-16 bis 2026-11-28; Aktion „Jetzt bestellen“.

**R7 Totraum.** Bohnenwechsel = Wechsel der Bohnen-`id` an einer Mühle (nicht: neue Packung derselben Bohne oder anderer Röstgrad). Bei einem Bohnenwechsel oder wenn die Mühle ≥ 24 h ungenutzt war (Standardwert ohne Quelle, in `assets/care_rules.json` änderbar) empfiehlt die App, `deadSpaceG` vorab zu mahlen und zu verwerfen. Die Menge wird als `purgeG` der Brühung gespeichert. Bestandsabzug der Packung = `doseG + purgeG`.
Beispiel: Dosis 17 g, Totraum 2.5 g → 2.5 g verwerfen, dann 17 g; Abzug 19.5 g.

**R8 Reinigung (Daten `assets/care_rules.json`).** Pro Maschine werden die Espresso-Shots seit dem letzten Ereignis gezählt (Anzahl Brühungen mit dieser `machineId`). Backflush fällig bei ≥ 200 Shots oder ≥ 7 Tagen seit letztem Backflush (was zuerst eintritt). Entkalken nach Härte des Standard-Wasserprofils: > 150 ppm alle 30 Tage; 100–150 ppm alle 60 Tage; < 100 ppm alle 90 Tage. Das Maschinenhandbuch hat Vorrang (Hinweistext). Die Mühlenreinigung ist nach 28 Tagen fällig (Standardwert ohne Quelle). Der Shot-Timer fliesst über die Shot-Anzahl und die Brühdaten ein; eine Summe der Shot-Zeiten wird nicht geführt.
Beispiel: Letzter Backflush 2026-11-10, bis 2026-11-16 insgesamt 90 Shots → 6 Tage, nicht fällig; am 2026-11-17 fällig (7 Tage). Wasser 120 ppm, letztes Entkalken 2026-10-01 → fällig 2026-11-30 (1. Okt + 60 Tage).

**R9 Espresso-Empfehlung (genau eine Variable).** Ein einziges Band für Ziel und „keine Änderung“: Shot-Zeit 25–30 s (Standardverhältnis 1:2, 18 g → 36 g). Prüfreihenfolge, die erste zutreffende gewinnt, und nur sie wird genannt: (1) Wasser ausserhalb R2 → Wasser; (2) Packung vor Espresso-Ruhezeit (R3) → „noch ruhen lassen“; (3) Mahlgrad. Mahlgrad: **die Shot-Zeit hat Vorrang vor dem Geschmack** (Quelle: erst Zeitfenster per Mahlgrad, dann Geschmack):
- Zeit < 25 s → feiner; Zeit > 30 s → gröber (unabhängig vom Geschmack); Schrittweite 2 Rasterstufen bei Zeit < 20 s oder > 35 s, sonst 1;
- Zeit 25–30 s: `sour` oder `weak` → feiner, `bitter` → gröber, je 1 Rasterstufe; `balanced` → keine Änderung.
„Feiner“ bedeutet Skalenrichtung `finerDirection`. Ergebnis wird auf `scaleMin..scaleMax` begrenzt. Jede Empfehlung hat `reason` und `source` (URL).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 12.0, sauer, 27 s, Wasser im Bereich, Packung bereit → 11.5 (1 Stufe feiner). Bitter, 17 s → Zeit gewinnt: feiner, 2 Stufen → 11.0. Weak, 40 s → gröber, 2 Stufen → 13.0. Sauer, 38 s → gröber, 2 Stufen → 13.0. Ausgewogen, 22 s → feiner, 1 Stufe → 11.5. Ausgewogen, 27 s → keine Änderung. Einstellung 1.0 und feiner → bleibt 1.0 mit Hinweis „Skalenende“.

**R10 Filter-Rezept.** Wasser `W = dose × ratio` (Standard 1:16, erlaubt 1:14–1:18, Schritt 0.5, Auflösung 1 g). Bloom = 2 × Dosis bei 0:00 für 45 s; Zwischensummen (kumulatives Wasser) nach 0:45: round(0.375 × W); nach 1:15: round(0.6875 × W); nach 2:00: W. Ziel-Gesamtzeit 3:00–3:30 (180–210 s); Wassertemperatur 92–96 °C. Abfluss > 4:00 → gröber, < 2:45 → feiner.
Beispiel: 20 g, 1:16 → W = 320; Bloom 40 g; Summen 120 g (0:45), 220 g (1:15), 320 g (2:00). 15 g, 1:15 → W = 225; Bloom 30; 0.375 × 225 = 84.4 → 84; 0.6875 × 225 = 154.7 → 155; 225.

**R11 Filter-Empfehlung (genau eine Variable: Mahlgrad).** Prüfreihenfolge wie R9: (1) Wasser (R2); (2) Packung vor Filter-Ruhezeit (R3); (3) Mahlgrad nach `drawdownS` (Zeit hat Vorrang vor Geschmack): `drawdownS` > 240 s → gröber, < 165 s → feiner (je 1 Stufe; 2 Stufen bei > 270 s oder < 150 s; Schwellen 270/150 sind Standardwerte ohne Quelle); im Fenster 165–240 s: `sour`/`weak` → feiner, `bitter` → gröber (1 Stufe), `balanced` → keine Änderung. Das Verhältnis wird nie automatisch empfohlen. Quelle der 240/165-s-Grenzen: Coffee Hero (Abfluss > 4:00 bzw. < 2:45).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 20.0, Abfluss 255 s, bitter → gröber 1 Stufe → 20.5. Abfluss 150 s → 150 ist nicht < 150, also 1 Stufe feiner: 19.5; Abfluss 140 s → 2 Stufen feiner: 19.0. Abfluss 200 s, sauer → 19.5.

## 5 Defaults, Grenzen, Reihenfolge, leere Daten, Fehler

- Defaults: Härteeinheit °fH; Lieferzeit 3 Tage; Verhältnis 1:16; Mindestbestand 2 Tage Verbrauch, ohne Historie 100 g; Backflush 7 Tage/200 Shots.
- Grenzen: Dosis 5–40 g; Filter-Verhältnis 14–18; Espresso-Ausbeute 1–4 × Dosis; **Espresso-Shot-Timer `shotTimeS` 1–120 s; Filter-Timer `drawdownS` und Gesamtzeit 1–600 s** (R10 Ziel 180–210 s ist zulässig); Bewertung 1–5; Name 1–60 Zeichen; Packungsgrösse `sizeG` 50–5000 g; `remainingG` 0..`sizeG`; Ruhetage nie negativ.
- Bestandsabzug: eine Brühung mit `doseG + purgeG` > `remainingG` der Packung wird abgelehnt („Nicht genug Bohnen in der Packung (Rest {n} g)“ / „Not enough beans in the pack ({n} g left)“); `remainingG` wird nie negativ.
- Mahlgrad-Eingabe muss in `scaleMin..scaleMax` liegen und ein Vielfaches von `scaleStep` ab `scaleMin` sein; sonst Fehler (DE „Wert liegt nicht auf der Skala der Mühle (Schritt {step})“, EN „Value is not on the grinder's scale (step {step})“).
- Reihenfolge: Bohnenlisten nach frühestem `readyDate` ihrer Packungen aufsteigend (trinkbereite zuerst); Brühungen nach `startedAt` absteigend; Pflege nach Fälligkeit.
- Leere Daten: keine Verbrauchshistorie → `consumptionPerDay = 0`, Mindestbestand 100 g, keine Lückenwarnung; keine Packung → R6 Beispiel 3 nur bei Verbrauch > 0; kein Wasserprofil → Empfehlung „Wasserwerte erfassen“; keine Mühle → Brühung nicht speicherbar, Hinweis „Zuerst eine Mühle anlegen“; Espresso ohne Maschine → nicht speicherbar, Hinweis „Zuerst eine Maschine anlegen“.
- Regelwerte stehen als Daten in `assets/*.json`; jeder Regel-Eintrag hat `source` (URL) und `retrieved` (Datum). Einträge ohne recherchierte Quelle tragen `source: "none"`; die UI zeigt sie als „Standardwert ohne Quelle“.
- Für Chemex, Kalita, AeroPress und Batch gilt vorerst das V60-Schema (R10) mit Quelle „none“; nur das V60-Schema ist recherchiert.

## 6 Schnittstellen und Formate

**JSON-Export** (Datei `coffee-export-YYYY-MM-DD.json`, UTF-8):
`{"schemaVersion":1,"exportedAt":"<ISO>","grinders":[],"machines":[],"waterProfiles":[],"beans":[],"packs":[],"brews":[],"careEvents":[],"settings":{}}`; jedes Element enthält die Felder aus Abschnitt 3 (inkl. `deletedAt`).
**Auslieferung:** Android und iOS: System-Share-Sheet mit der Datei `coffee-export-YYYY-MM-DD.json`; Chrome: Browser-Download mit demselben Dateinamen. Import: Dateiauswahl (File Picker) auf allen Plattformen.
**Import:** Datensätze mit gleicher `id` werden übernommen, wenn `updatedAt` neuer ist als der lokale Wert, sonst übersprungen; da Löschen `updatedAt = deletedAt` setzt, gewinnt ein neueres `deletedAt` (Datensatz wird gelöscht) und ein älteres verliert. Verweist ein Datensatz auf eine `id`, die weder in der Datei noch lokal existiert, wird er übersprungen und im Ergebnis gezählt („{n} Datensätze übersprungen“ / „{n} records skipped“). Unbekannte `schemaVersion` → Fehler „Dateiversion nicht unterstützt“ / „File version not supported“, nichts wird geändert. Der Import läuft in einer Transaktion.
**Regel-Assets:** `assets/water_rules.json`, `rest_rules.json`, `care_rules.json`, `brew_rules.json`; Format `{"version":1,"rules":[{"key":"...","value":...,"source":"<URL>","retrieved":"2026-11-16"}]}` (`retrieved` pro Eintrag).
**Lokalisierung:** `lib/l10n/app_de.arb`, `app_en.arb`; Sprache = Systemsprache, Fallback Englisch. Alle deutschen Varianten verwenden das Format von de-CH (Dezimalpunkt `15.5`, Datum `16.11.2026`); Englisch: Dezimalpunkt, Datum `16 Nov 2026`.

## 7 Nicht-funktionale Anforderungen

- Offline first: alle Funktionen ohne Netz; keine Netzwerkzugriffe zur Laufzeit.
- Performance: Mit 1000 Brühungen in der Liste wird jeder Frame beim Scrollen auf dem Emulator in höchstens 16 ms gebaut; die Empfehlung (R9/R11) wird in unter 50 ms berechnet.
- Barrierefreiheit: Kontrast Text/Hintergrund ≥ 4.5:1, Fokusring 2 dp, Touch-Ziele ≥ 48 × 48 dp, Semantics-Labels für alle Icon-Buttons.
- Code Style (Team-Konvention): max. 300 Zeilen pro Quelldatei, Tests max. 500, generierte Dateien ausgenommen; Struktur `lib/app`, `lib/core`, `lib/features/<feature>/{data,domain,presentation}`; eine Klasse bzw. ein Widget pro Datei; `test/` spiegelt `lib/`; `///`-Doc-Kommentare für öffentliche APIs; Inline-Kommentare nur für das Warum; kein auskommentierter Code; TODO nur mit Ticket; Gate in `environment.json`: `dart format --set-exit-if-changed`, `flutter analyze` (flutter_lints, strikt) und Zeilenprüfung `tool/check_lines.dart`.
- `tool/check_lines.dart` wird in der ersten Story (Projekt-Grundgerüst) angelegt. Abnahme: Exit 0, wenn alle Dateien in `lib/` ≤ 300 und in `test/` ≤ 500 Zeilen haben; Exit 1 mit Ausgabe `<Pfad>: <Zeilen>` für jede Datei darüber (Test: eine Datei mit 301 Zeilen in `lib/` → Exit 1). Ausgenommen: `*.g.dart`, `*.freezed.dart`, `lib/l10n/app_localizations*.dart`.
- Tests: Unit-Tests für R1–R11 mit den Zahlen aus Abschnitt 4. Playwright-Systemtests in Chrome (Flutter-Web-Build), ein Szenario pro UC mit erwartetem Wert:
  - UC1: Mühle „M1“ (Skala 1–30, Schritt 0.5, Totraum 2.5 g) anlegen → Karte „M1“ zeigt „2.5 g“.
  - UC2: Bohne medium, Röstdatum heute − 12 Tage, anlegen → Chip „Bereit“.
  - UC3: Espresso 18 g → 36 g in 27 s speichern → Liste zeigt „27 s“.
  - UC4: Brühung sauer, 27 s, Mahlgrad 12.0 → Karte „Empfehlung“ zeigt „Mahlgrad auf 11.5“.
  - UC5: 20 g, 1:16 → Fokus-Modus zeigt „Giesse bis 40 g“, dann „120 g“, „220 g“, „320 g“.
  - UC6: Wasser 30 °fH → Status „Ausserhalb SCA“ und Anzeige „300 ppm“ nach Wechsel auf ppm.
  - UC7: Backflush 7 Tage her → Pflege zeigt „Fällig“; nach „Erledigt“ „In 7 Tagen“.
  - UC8: 90 g, Verbrauch 18 g/Tag, nächste Packung in 9 Tagen bereit → Banner „Kein trinkbereiter Kaffee vom 21.11.2026 bis 24.11.2026“ (bei heute 2026-11-16).
  - UC9: Export, Daten löschen, Import → Bohnenliste enthält wieder „Bohne 1“.
- Jede Story aktualisiert `README.md` und `CHANGELOG.md`.
- Datenschutz: Daten verlassen das Gerät nur durch den ausdrücklichen JSON-Export.

## UI und Design

**Richtung:** „Warme Rösterei“ – ruhig, warm, lesbar; Karten in Papier-Anmutung = Fläche `surfaceVariant`, 1 dp Rand `onSurface` mit Alpha 12 %, Kartenschatten gemäss Tokens; ein Akzent in Kupfer. **Looks like:**
- *Liste* (Bohnen, Brühungen, Maschinen): vertikale Karten, 88 dp hoch, 12 dp Abstand; links ein 56 × 56-dp-Bildbereich als visueller Anker.
- *Detail*: Kopfband mit grossem Bildbereich (160 dp hoch), darunter Kennzahlen-Kacheln in 2 Spalten, darunter Verlauf/Empfehlung.
- *Formular*: einspaltig, Felder mit Label oben, Einheit als Suffix im Feld, primäre Schaltfläche unten fixiert.
- *Fokus-Modus* (Filter geführt): Vollbild, riesiger Timer (Ziffern 72 sp) und darunter die Ziel-Zwischensumme in g (48 sp), keine Navigation, ein Schritt pro Ansicht.

**Tokens** (intent = Richtwert, exact = verbindlich):
| Token | Wert | Art |
|---|---|---|
| `primary` | #8A4B2A Kupfer (Hauptaktion, aktive Navigation); hover #7F4527 (Schwarz-Overlay 8 %), pressed #743F23 (Overlay 16 %); disabled: Alpha 38 % | intent |
| `surface` | #FBF6EF hell / #1F1814 dunkel | intent |
| `surfaceVariant` | #F0E6D8 hell / #2B211B dunkel (Karten, Seitenleiste) | intent |
| `onSurface` | #2A1E17 hell / #F3E9DD dunkel | intent |
| `success` | #36703F hell (Kontrast etwa 4.8:1 auf `surfaceVariant`, 5.5:1 auf `surface`, relative Luminanz ≤ 0.139) / #7CC28E dunkel (Bereit) | exact (Kontrast) |
| `warning` | #8A5A00 hell (Text, Icon und Rand; Kontrast zu `surface` etwa 5.5:1, relative Luminanz 0.127 ≤ 0.167) / #E0B050 dunkel | exact (Kontrast) |
| `error` | #B3261E hell / #F2B8B5 dunkel (Warnung) | intent |
| Kontrast Text | ≥ 4.5:1, Grosstext ≥ 3:1; gilt für jede Text-/Hintergrund-Paarung inkl. `warning`, `success`, `error` auf `surface` und `surfaceVariant` | exact |
| Fokusring | 2 dp in `primary`, 2 dp Abstand | exact |
| Schrift | Überschriften „Fraunces“ (Serif), Text „Inter“; Fallback System-Serif/-Sans | intent |
| Typ-Skala (sp) | 12, 14, 16, 20, 24, 32, 48, 72 | intent |
| Abstand (dp) | 4, 8, 12, 16, 24, 32, 48 | intent |
| Radius (dp) | Karten 16, Felder 12, Chips 999 | intent |
| Schatten | Karte: y 2 dp, Blur 8 dp, Alpha 8 % `onSurface`; Hover y 4 dp; im Dunkel kein Schatten, stattdessen 1 dp Rand | intent |
| Breakpoints (dp) | Phone < 600, Tablet 600–1023, Desktop ≥ 1024 | intent |

**Gezeichnete Elemente:**
- *Bohnenkarte, Bildbereich (56 × 56 dp, Radius 12):* linearer Verlauf 135° im HSL-Farbmodell von `HSL(H, 55 %, 62 %)` zu `HSL((H + 340) mod 360, 55 %, 42 %)`. `H = 15 + (fnv1a32(lowercase(name) als UTF-8) mod 36)` Grad, also 15°–50° (Braun/Orange); Hash-Funktion FNV-1a 32 Bit (Offset 2166136261, Primzahl 16777619), nicht `String.hashCode`. Mittig ein Bohnen-Icon 32 dp in `surface` (Alpha 90 %). Dunkel: Helligkeit beider Stops −12 Prozentpunkte. Rechts unten Röstgrad-Punkte (6 dp, Abstand 2 dp): light 1, medium 2, mediumDark 3, dark 4 gefüllte Punkte von 4.
- *Mühlenkarte (Bildbereich):* Drehknopf-Icon 40 dp, darum ein Bogen (Durchmesser 56 dp, Strichstärke 4 dp, Sweep 270°, Start 135° im Uhrzeigersinn, Ende 45°); Spur `onSurface` Alpha 15 %, Wert `primary`; Wert-Anteil = (Einstellung − `scaleMin`) / (`scaleMax` − `scaleMin`). `scaleMin` und `scaleMax` als 12-sp-Labels unter dem Start- bzw. Endpunkt des Bogens.
- *Maschinenkarte:* Siebträger-Icon 24 dp in der Mitte eines Rings (Durchmesser 56 dp, Strichstärke 4 dp). Voller Ring = 7 Tage bis zum Backflush; Füllung = verbleibende Tage / 7 (mind. 0). Farbe: > 2 verbleibende Tage `success`, 1–2 `warning`, ≤ 0 `error`.
- *Platzhalter-Bild:* gestrichelter Kreis 64 dp mit Kamera-Icon, Text „Kein Bild“/„No image“.
- *Leere Zustände:* Icon 64 dp in `primary` Alpha 40 %, Titel (20 sp), Erklärsatz (14 sp), eine Aktion (Button).
- *Bestands-Balken:* 8 dp hoch, Radius 4 dp, volle Breite = 2 × `orderPoint` (Gesamtbestand der Bohne); Füllbreite = min(1, Gesamtbestand / (2 × orderPoint)) × Breite; Markierung (2-dp-Strich) bei 50 % = `orderPoint`. Füllung: Bestand > orderPoint `success`; 0 < Bestand ≤ orderPoint `warning`; Bestand 0 leer mit Rand `error`.

**Komponenten (Zustände):**
- *Button:* default (`primary` gefüllt), hover (#7F4527), pressed (#743F23), disabled (Alpha 38 %), loading (20-dp-Spinner statt Text).
- *Karte:* default, hover (Schatten y 4 dp), selected (2 dp `primary` Rand), disabled (Alpha 60 %), empty (Empty-State), loading (Skeleton in `surfaceVariant`), error (Rand `error` mit Text und „Erneut versuchen“).
- *Feld:* default, focus (Fokusring), error (rote Zeile mit Text), disabled.
- *Chip:* „Bereit“ (success), „Ruht noch X Tage“ (warning), „Zu alt“ (error).
- *Banner:* Info/Warnung/Fehler mit Icon, Text und optionaler Aktion.
- *Themes:* hell und dunkel als Token-Overrides (`surface`, `surfaceVariant`, `onSurface`, `success`, `warning`, `error`, Schatten); Wahl nach System.

**App-Shell und Navigation:** Phone: Bottom-Bar mit 5 Zielen (Heute, Bohnen, Brühen, Ausrüstung, Mehr). Tablet: Navigation-Rail mit denselben 5 Zielen. Desktop (≥ 1024 dp): feste Seitenleiste 240 dp mit 7 Einträgen: Heute, Bohnen, Brühen, Ausrüstung, Wasser, Pflege, Einstellungen (Mehr entfällt). Oben Titel und Aktionen. Seitenleiste und Inhalt füllen die Seite bis zum Viewport-Ende.

| Screen | Erreichbar |
|---|---|
| Heute (Home) | Ziel „Heute“ |
| Bohnen (Liste) / Bohnendetail / Bohnenformular | „Bohnen“; Karte; Button „+“ |
| Brühungen (Liste) / Brühungsformular / Brühungsdetail mit Empfehlung | „Brühen“; „+“; Karte |
| Filter geführt (Fokus-Modus) | „Brühen“ → „Filter starten“; Phone ohne Navigation |
| Ausrüstung (Mühlen, Maschinen) / Formulare | „Ausrüstung“, Tabs |
| Wasser (Liste, Formular) | Phone/Tablet: „Mehr“ → Wasser; Desktop: Seitenleiste „Wasser“ |
| Pflege (Reinigung) | „Heute“-Kachel; Phone/Tablet „Mehr“ → Pflege; Desktop Seitenleiste „Pflege“ |
| Einstellungen (Einheit, Export/Import) | Phone/Tablet „Mehr“ → Einstellungen; Desktop Seitenleiste |

**Screens (Komposition):**
- *Heute:* Region 1 Warnbanner (Lückenwarnung, Bestellhinweise, Pflege fällig, Wasser-Check), Region 2 „Jetzt trinkbereit“ (Karten), Region 3 letzte Brühung. Primäre Aktion: „Neue Brühung“ (FAB). Dichte: mittel. Leer: Icon Kaffeebohne, „Noch nichts da“ / „Nothing here yet“, „Lege deine erste Bohne an.“ / „Add your first bean.“, Aktion „Bohne hinzufügen“ / „Add bean“.
- *Bohnen-Liste:* Karten sortiert nach R3; Chip Bereit/Ruht/Zu alt; Bestands-Balken; primär „Bohne hinzufügen“. Leer: Icon Bohne, „Noch keine Bohnen“ / „No beans yet“, „Lege deine erste Bohne an.“ / „Add your first bean.“, Aktion „Bohne hinzufügen“ / „Add bean“.
- *Bohnendetail:* Kopfband, Kacheln (Restgramm, Reichweite in Tagen, Bereit-Datum, Mindestbestand), Packungsliste, Bestellhinweis, Aktion „Packung hinzufügen“ (primär), „Öffnen“ (sekundär).
- *Bohnen-/Packungsformular:* Name, Röster, Röstgrad, Art, Lieferzeit (Tage), Mindestbestand (g, optional); Packung: Röstdatum, Gewicht (g); primär „Speichern“/„Save“; Fehler pro Feld.
- *Brühungs-Liste:* nach Datum; Zeile zeigt Methode, Bohne, Zeit in s, Bewertung. Leer: Icon Tasse, „Noch keine Brühungen“ / „No brews yet“, „Erfasse deinen ersten Shot.“ / „Log your first shot.“, Aktion „Brühung erfassen“ / „Log a brew“.
- *Brühungsformular:* Methode, Maschine (nur Espresso), Mühle (Mahlgrad-Eingabe als Stepper in der Rasterstufe), Packung, Dosis, Spülmenge (g), Ausbeute, Shot-Timer (Start/Stopp, manuell änderbar), Wasserprofil, Geschmack (Chips), Bewertung; primär „Speichern“; sekundär „Timer starten“. Mühle-Spülhinweis (R7) als Banner oben.
- *Brühungsdetail:* Werte, darunter Karte „Empfehlung“ mit einem Satz, Grund und Quelle (Link-Text); Aktion „Nächster Versuch“ (übernimmt die Werte).
- *Filter geführt:* Setup (Methode, Dosis, Verhältnis-Slider 1:14–1:18 in 0.5-Schritten, Anzeige „Wasser gesamt: 320 g“), dann pro Schritt Timer plus Ziel-Zwischensumme („Giesse bis 120 g“). Rückmeldung am Schrittende: Android/iOS `HapticFeedback.mediumImpact` und `SystemSound.alert`; Chrome: nur visuell (Hintergrund 300 ms in `primary` Alpha 20 %), keine Haptik. Primär „Weiter“/„Next“, sekundär „Abbrechen“; am Ende Abfluss-Zeit und Geschmack erfassen.
- *Ausrüstung:* zwei Tabs Mühlen/Maschinen; Karten; Formulare für Skala (Min, Max, Schritt, Richtung), Totraum (g), Maschine (Temperatur °C, Preinfusion s, Druckprofil, Standard-Wasser). Leer Mühlen: Icon Mühle, „Noch keine Mühle“ / „No grinder yet“, „Lege deine Mühle mit Skala und Totraum an.“ / „Add your grinder with scale and dead space.“, Aktion „Mühle hinzufügen“ / „Add grinder“. Leer Maschinen: Icon Espressomaschine, „Noch keine Maschine“ / „No machine yet“, „Lege deine Maschine mit Einstellungen an.“ / „Add your machine with its settings.“, Aktion „Maschine hinzufügen“ / „Add machine“.
- *Wasser:* Profil-Liste; Detail mit Messwert-Balken je Parameter gegen den SCA-Bereich; Härte in gewählter Einheit; Status-Chip „Im SCA-Bereich“ / „Ausserhalb SCA“. Leer: Icon Tropfen, „Noch kein Wasserprofil“ / „No water profile yet“, „Erfasse die Härte deines Wassers.“ / „Enter your water's hardness.“, Aktion „Wasserprofil hinzufügen“ / „Add water profile“.
- *Wasser-Formular:* Name (1–60 Zeichen); Härte (Pflicht, Einheit-Umschalter °fH/°dH/ppm, Bereich 0–1000 ppm); Alkalinität (ppm, 0–500); TDS (mg/L, 0–1000); pH (0–14); Natrium (mg/L, 0–500); Chlor (mg/L, 0–10); optionale Felder dürfen leer bleiben („nicht gemessen“). Fehler: DE „Wert zwischen {min} und {max} eingeben“, EN „Enter a value between {min} and {max}“; Name leer: „Name eingeben“ / „Enter a name“. Primär „Speichern“.
- *Pflege:* Maschinenweise Aufgaben Backflush/Entkalken/Mühle mit Fälligkeit, Shots seit letztem Mal; primär „Erledigt“. Leer (keine Maschine/Mühle): Icon Schwamm, „Nichts zu pflegen“ / „Nothing to maintain“, „Lege zuerst eine Maschine an.“ / „Add a machine first.“, Aktion „Maschine hinzufügen“ / „Add machine“.
- *Einstellungen:* Härteeinheit (°fH/°dH/ppm), Export, Import, Über/Quellen-Liste.

**Texte (DE / EN, Beispiele verbindlich):** Heute/Today, Bohnen/Beans, Brühen/Brew, Ausrüstung/Equipment, Mehr/More, Speichern/Save, Abbrechen/Cancel, Bereit/Ready, „Ruht noch {n} Tage“/„Resting, {n} days left“, „Jetzt bestellen“/„Order now“, „Packung {x} öffnen“/„Open pack {x}“, „Kein trinkbereiter Kaffee vom {von} bis {bis}“/„No ready coffee from {from} to {to}“.

**Look and feel**
- LF1 Alle Screens: Hintergrund, Seitenleiste und Panels füllen die Seite bis zum unteren Viewport-Rand, auch bei kurzem Inhalt.
- LF2 Bohnen, Heute: Der Bildbereich jeder Bohnenkarte ist ein Verlauf mit Bohnen-Icon; Nachbarkarten unterscheiden sich im Farbton; Röstgrad-Punkte sichtbar.
- LF3 Alle Listen (Bohnen, Brühungen, Mühlen, Maschinen, Wasser, Pflege, Heute): Kein Titel steht über einer leeren Fläche; der Empty-State mit Icon, Titel, Satz und Aktion ist sichtbar.
- LF4 Alle Screens: Jeder Text und jede Einheit ist in der Sprache des Screens (DE: „g“, „s“, „°C“, „°fH“; Datum 16.11.2026, Dezimalpunkt; EN: Datum 16 Nov 2026).
- LF5 Filter geführt: Timer-Ziffern ≥ 72 sp, Ziel-Zwischensumme ≥ 48 sp, genau eine primäre Schaltfläche, keine Navigationsleiste.
- LF6 Heute, Bohnendetail: Lücken- und Bestellwarnungen stehen als Banner in `warning`/`error` mit Datum von–bis und einer Aktion.
- LF7 Phone (390 dp): Bottom-Bar mit 5 Zielen, kein horizontales Scrollen; ab 1024 dp feste Seitenleiste 240 dp mit 7 Einträgen.
- LF8 Dunkel: Karten haben 1-dp-Rand statt Schatten, Text-Kontrast ≥ 4.5:1.
- LF9 Wasser: Jeder Parameter zeigt einen Balken mit markiertem SCA-Bereich; ausserhalb ist der Balken `error`.
- LF10 Formulare: Einheit steht als Suffix im Feld, Fehler stehen als rote Zeile unter dem Feld, die primäre Schaltfläche ist die einzige gefüllte.
- LF11 Bohnen: Der Bestands-Balken zeigt die Markierung bei 50 % und die Füllfarbe gemäss Bestand (success/warning).
- LF12 Ausrüstung: Mühlenkarten zeigen den Bogen mit Min-/Max-Label, Maschinenkarten den Ring mit Tage-Anzeige.

## 8 Entscheidungen

1. Team-Code-Style gilt wie in Abschnitt 7 (PO-Antwort 1).
2. Lokale Speicherung mit drift/SQLite, offline first, JSON-Export/-Import; stabile IDs und `updatedAt`; Cloud-Sync später (Abschnitt 3, 6).
3. Ein Nutzer, kein Login (Abschnitt 1).
4. Deutsch und Englisch nach Systemsprache (Abschnitt 6).
5. Schweizer Einheiten: Härte-Eingabe °fH (Standard), °dH, ppm, Speicherung ppm; g, ml, s, °C (R1).
6. Websuche beim Spec-Schreiben, Quellen zitiert; Regelwerte als Daten mit Quelle und Datum (Abschnitt 5, 6).
7. Mühlen: eigene Skala (Min, Max, Schritt) und Totraum pro Mühle (Abschnitt 3, R7, R9).
8. Maschinen: Brühtemperatur, Preinfusion, Druckprofil, Standard-Wasserprofil (Abschnitt 3).
9. Bestand: Mindestbestand 2 Tage Verbrauch, ohne Historie 100 g; Bestellhinweis nach R5; Lückenwarnung nach R6.
10. Alle weiteren Vorschläge übernommen (Defaults aus Abschnitt 5, 4).
11. Empfehlungen: eine Variable, in Rasterstufen der Mühle (1–2), Wasser zuerst, mit Grund und Quelle (R9, R11).
12. Filter: Methoden V60/Chemex/Kalita/AeroPress/Batch, Verhältnis Standard 1:16 (1:14–1:18), Bloom und Aufgüsse mit Zwischensummen und Timer, nur ruhezeit-fertige Packungen, Espresso-Blends nicht zuerst (R3, R10); README.md und CHANGELOG.md in jeder Story (Abschnitt 7).
13. Wasserbereich: Gesamthärte 50–175 ppm und Alkalinität 40–75 ppm (SCA-Handbuch „Core Zone“); Quellen nennen daneben Calcium-Härte 17–85 mg/L – nur Daten-Asset, änderbar (R2).
14. Ruhetage = untere Grenze der Bereichs-Tabelle (R3).
15. Annahmen aus der Review-Revision (einfachste passende Option): Zeit vor Geschmack bei Espresso und Filter (R9, R11); ein Band 25–30 s (R9); Filter-Empfehlung nur Mahlgrad (R11); Lieferzeit auf Bohnenebene (Abschnitt 3); `restMethod` espresso für `espressoBlend`/`allround` (Abschnitt 3); Soft-Delete statt hartem Löschen (Abschnitt 3); fehlende Referenzen beim Import werden übersprungen (Abschnitt 6); alle deutschen Locales im Format de-CH (Abschnitt 6); zu alte Packungen zählen nicht als trinkbereit (R3); Shot-Zeiten-Summe entfällt (R8); Warnfarbe #8A5A00 wegen Kontrast (Tokens).

## 9 Offene Fragen

Keine vom PO ausdrücklich offen gelassenen Fragen.

## Sources

- https://www.percolateapp.com/articles/how-long-to-rest-coffee-after-roasting (Ruhezeiten, Staleness; geöffnet)
- https://seelaz.com/blogs/barista-academy/water-for-coffee-sca (SCA-Wasserwerte; geöffnet)
- https://www.merakitech.com/blogs/machine-guides/a-home-barista-cleaning-schedule-daily-weekly-monthly (Reinigungsrhythmus; geöffnet)
- https://coffeehero.com.au/blogs/news/v60-golden-ratio-the-1-16-pour-over-recipe (V60 1:16, Bloom, Zwischensummen, Abfluss-Grenzen; geöffnet)
- https://coffeestudies.com/barista-skills/dialing-in-espresso (Dial-in: 1:2, 25–30 s, eine Variable; aus Suchergebnis)
- https://clivecoffee.com/blogs/learn/dialing-in-espresso-by-taste (Sauer/bitter-Korrektur; aus Suchergebnis)
- https://www.thehomebaristasquill.com/p/how-to-backflush-and-descale-your (Backflush alle 200 Shots/wöchentlich, Entkalken nach Härte; aus Suchergebnis)
