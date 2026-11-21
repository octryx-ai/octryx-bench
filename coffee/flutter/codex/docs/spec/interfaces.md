## 5 Defaults, Grenzen, Reihenfolge, leere Daten, Fehler

### Autoritative Sortierung und Exportstruktur

Die nachfolgenden Kurzfassungen zu Sortierung und JSON-Export werden hiermit vervollständigt.

- Bohnen erhalten zuerst eine Bereitschaftsgruppe für `restMethod`: 0 = mindestens eine
  bereite, nicht alte Packung mit `remainingG > 0`; 1 = keine bereite, aber mindestens eine
  ruhende, nicht leere Packung; 2 = nur alte nicht leere Packungen; 3 = keine nicht leere
  Packung. Archivierte Packungen werden ignoriert. Gruppe ist der erste Sortierschlüssel.
  Innerhalb Gruppe 0/1 zählt das früheste `readyDate` nur ihrer qualifizierenden Packungen.
  Bei Gruppe 2/3 wird das Datum als unendlich behandelt. Weitere Schlüssel: Name aufsteigend
  nach Unicode-Kleinbuchstaben, dann `createdAt`, dann `id`, jeweils aufsteigend.
  Beispiel: A mit leerer Packung bereit 01.11. und ruhender Packung bereit 25.11. ist Gruppe 1;
  B mit 50 g bereit 11.11. ist Gruppe 0 und steht vor A, unabhängig von A's leerer Packung.
- Kanonischer Export ist ein UTF-8-JSON-Objekt mit genau diesen erforderlichen Schlüsseln:
  `schemaVersion` Integer 1; `exportedAt` UTC-RFC3339-String mit Millisekunden;
  `grinders`, `machines`, `waterProfiles`, `beans`, `packs`, `brews`, `careEvents` und
  `consumptionEvents` jeweils Arrays von Objekten nach dem Domänenmodell; `settings` ein Objekt.
  Leere Arrays sind gültig. `settings.hardnessUnit` ist erforderlich und genau
  `fH`, `dH` oder `ppm`; es gibt keine weiteren Einstellungsfelder in Schema 1.
  Beispieldatei ohne Datensätze:

  ```json
  {
    "schemaVersion": 1,
    "exportedAt": "2026-11-18T08:30:00.000Z",
    "grinders": [], "machines": [], "waterProfiles": [],
    "beans": [], "packs": [], "brews": [], "careEvents": [],
    "consumptionEvents": [], "settings": {"hardnessUnit": "fH"}
  }
  ```

- Fehlender Schlüssel, zusätzlicher Top-Level-Schlüssel, null statt Array/Objekt, falscher
  Typ, unbekannte Einheit oder fehlerhafter Zeitstempel: gesamte Datei ablehnen, nichts ändern.
  Einstellungen sind ein lokales Singleton, kein synchronisierter Datensatz; nach erfolgreicher
  Validierung ersetzt das importierte `settings` das lokale Objekt in derselben Transaktion.
  Es trägt keine Datensatz-ID oder `updatedAt`. Datensatz-Konflikte der Arrays folgen weiter
  dem neueren `updatedAt`; der Einstellungs-Sonderfall wird beim Export nicht verschleiert.

- Defaults: Härteeinheit °fH; Lieferzeit 3 Tage; Verhältnis 1:16; Mindestbestand 2 Tage Verbrauch, ohne Historie 100 g; Backflush 7 Tage/200 Shots.
- Grenzen: Dosis 5–40 g; Filter-Verhältnis 14–18; Espresso-Ausbeute 1–4 × Dosis; **Espresso-Shot-Timer `shotTimeS` 1–120 s; Filter-Timer `drawdownS`
  und Gesamtzeit 1–600 s** (R10 Ziel 180–210 s ist zulässig); Bewertung 1–5; Name 1–60 Zeichen; Packungsgrösse `sizeG` 50–5000 g; `remainingG`
  0..`sizeG`; Ruhetage nie negativ.
- Bestandsabzug: eine Brühung mit `doseG + purgeG` > `remainingG` der Packung wird abgelehnt („Nicht genug Bohnen in der Packung (Rest {n} g)“ / „Not
  enough beans in the pack ({n} g left)“); `remainingG` wird nie negativ.
- Mahlgrad-Eingabe muss in `scaleMin..scaleMax` liegen und ein Vielfaches von `scaleStep` ab `scaleMin` sein; sonst Fehler (DE „Wert liegt nicht auf
  der Skala der Mühle (Schritt {step})“, EN „Value is not on the grinder's scale (step {step})“).
- Reihenfolge: Bohnenlisten nach frühestem `readyDate` ihrer Packungen aufsteigend (trinkbereite zuerst); Brühungen nach `startedAt` absteigend;
  Pflege nach Fälligkeit.
- Leere Daten: keine Verbrauchshistorie → `consumptionPerDay = 0` , Mindestbestand 100 g, keine Lückenwarnung; keine Packung → R6 Beispiel 3 nur bei
  Verbrauch > 0; kein Wasserprofil → Empfehlung „Wasserwerte erfassen“; keine Mühle → Brühung nicht speicherbar, Hinweis „Zuerst eine Mühle anlegen“;
  Espresso ohne Maschine → nicht speicherbar, Hinweis „Zuerst eine Maschine anlegen“.
- Regelwerte stehen als Daten in `assets/*.json` ; jeder Regel-Eintrag hat `source` (URL) und `retrieved` (Datum). Einträge ohne recherchierte Quelle
  tragen `source: "none"` ; die UI zeigt sie als „Standardwert ohne Quelle“.
- Für Chemex, Kalita, AeroPress und Batch gilt vorerst das V60-Schema (R10) mit Quelle „none“; nur das V60-Schema ist recherchiert.

## 6 Schnittstellen und Formate

**JSON-Export** (Datei `coffee-export-YYYY-MM-DD.json` , UTF-8):
`{"schemaVersion":1,"exportedAt":"<ISO>","grinders":[],"machines":[],"waterProfiles":[],"beans":[],"packs":[],"brews":[],"careEvents":[],"settings":{}}`
; jedes Element enthält die Felder aus Abschnitt 3 (inkl. `deletedAt` ).
**Auslieferung:** Android und iOS: System-Share-Sheet mit der Datei `coffee-export-YYYY-MM-DD.json` ; Chrome: Browser-Download mit demselben
Dateinamen. Import: Dateiauswahl (File Picker) auf allen Plattformen.
**Import:** Datensätze mit gleicher `id` werden übernommen, wenn `updatedAt` neuer ist als der lokale Wert, sonst übersprungen; da Löschen
`updatedAt = deletedAt` setzt, gewinnt ein neueres `deletedAt` (Datensatz wird gelöscht) und ein älteres verliert. Verweist ein Datensatz auf eine
`id` , die weder in der Datei noch lokal existiert, wird er übersprungen und im Ergebnis gezählt („{n} Datensätze übersprungen“ / „{n} records
skipped“). Unbekannte `schemaVersion` → Fehler „Dateiversion nicht unterstützt“ / „File version not supported“, nichts wird geändert. Der Import läuft
in einer Transaktion.
**Regel-Assets:** `assets/water_rules.json` , `rest_rules.json` , `care_rules.json` , `brew_rules.json` ; Format
`{"version":1,"rules":[{"key":"...","value":...,"source":"<URL>","retrieved":"2026-11-16"}]}` (`retrieved` pro Eintrag).
**Lokalisierung:** Quellen je Feature `lib/features/<feature>/l10n/de.arb` und `en.arb` ; Zusammenführung mit
`octryx-claude l10n-merge arb 'lib/features/*/l10n/<lang>.arb' lib/l10n/app_<lang>.arb` , dann `flutter gen-l10n` ; generierte und zusammengeführte
Dateien nicht manuell bearbeiten. Feature-Präfixe, Schlüssel `^[a-z][a-zA-Z0-9]*$` , gleiche Schlüssel/ICU-Platzhalter, höchstens 400 Schlüssel pro
Katalog. Sprache = Systemsprache, Fallback Englisch. Alle deutschen Varianten verwenden das Format von de-CH (Dezimalpunkt `15.5` , Datum `16.11.2026`
); Englisch: Dezimalpunkt, Datum `16 Nov 2026` .

## Glossar und Bedingungswörter

- Bohne / coffee / bean; vermeiden: Packung als Synonym für Sorte.
- Röster / roaster.
- Packung / pack; vermeiden: Bohne als Synonym für Packung.
- Röstgrad / roast level.
- Ruhezeit / rest time; vermeiden: Trinkfreigabe.
- Bereit-Datum / ready date; vermeiden: Verfallsdatum.
- Mühle / grinder.
- Mahlgrad / grind setting; vermeiden: universeller Mahlgrad.
- Rasterstufe / scale step; vermeiden: erfundener Geräteklick.
- Totraum / dead space / confirmed purge amount; vermeiden: automatische Retentionsmessung.
- Spülmenge / purge amount; vermeiden: Wasserspülung.
- Maschine / machine.
- Preinfusion / preinfusion.
- Druckprofil / pressure profile.
- Brühung / brew; vermeiden: Shot für Filter.
- Dosis / dose.
- Ausbeute / beverage yield; vermeiden: Filter-Eingangswasser.
- Shot-Timer / shot timer.
- Bloom / bloom.
- Aufguss / pour.
- Zwischensumme / cumulative water; vermeiden: zusätzliche Menge.
- Abfluss-Zeit / drawdown time.
- Verhältnis / ratio.
- Wasserprofil / water profile; vermeiden: Trinkbarkeitsfreigabe.
- Härte / hardness; vermeiden: TDS als Härte.
- Alkalinität / alkalinity; vermeiden: pH als Alkalinität.
- Bestand / stock.
- Mindestbestand / minimum stock.
- Bestellpunkt / reorder point; vermeiden: automatische Bestellung.
- Lücke / readiness gap.
- Pflege / care.
- Backflush / backflush; vermeiden: für jede Maschine geeignet.
- Entkalken / descale.
- Geschmack / taste.
- Empfehlung / recommendation; vermeiden: Garantie.

- **bereit**: remainingG>0, readyDate≤heute und heute<roastDate+45, jeweils für die gewählte Methode.
- **ruht**: heute<readyDate; Resttage=readyDate−heute in lokalen Kalendertagen.
- **zu alt**: heute≥roastDate+45 Kalendertage; aus bereitem Bestand und Vorschlägen ausgeschlossen.
- **leer**: remainingG=0 für Packung; keine nicht archivierten Datensätze für Listen.
- **ausserhalb Referenzbereich**: mindestens ein gemessener Wert verletzt eine inklusive Grenze aus R2.
- **gemessene Werte im Referenzbereich**: alle nicht-null Messwerte liegen in R2; Anzahl gemessen immer n von 6.
- **nicht gemessen**: entsprechendes Wasserfeld=null, niemals als 0 interpretiert.
- **niedriger Bestand**: nicht alter Gesamtbestand≤consumptionPerDay×(leadTimeDays+restDays)+minStockG.
- **ohne Historie**: keine Verbrauchseinträge im vollständigen 28-Tage-Fenster; consumptionPerDay=0.
- **Lücke**: volle Tagesnachfrage nicht durch an diesem Tag bereite Packungen deckbar; zusammenhängende Tage von–bis.
- **fällig**: mindestens ein konfiguriertes Tage-/Shot-/Sekundenlimit je Gerät und Aufgabe erreicht.
- **Skalenende**: berechneter Mahlgrad ausserhalb scaleMin..scaleMax; R9/R11 begrenzen auf Ende.
- **Bohnenwechsel**: beanId der letzten bestätigten Mahlung dieser grinderId unterscheidet sich.
- **ungenutzt**: seit letzter bestätigter Mahlung derselben grinderId mindestens 24 Stunden.
- **archiviert**: deletedAt!=null; in Historie referenzierbar, in Auswahlfeldern ausgeschlossen.

