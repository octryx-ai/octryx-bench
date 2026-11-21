### Verbindliche Ergänzungen der Verträge

#### Persistierte Pause, Pflege und Import: verbindliche Präzisierungen

- Der aktive Timerentwurf speichert `startedAt` (UTC-RFC3339 mit Millisekunden),
  `accumulatedPausedMs` (nichtnegative ganze Millisekunden, Standard 0), `pausedAt` (nullable
  UTC-Zeitstempel), `status` (`running` oder `paused`) und `stoppedElapsedS` (nullable Integer).
  Pause setzt atomar `pausedAt=now`, `status=paused`; sie ändert `accumulatedPausedMs` noch nicht.
  Bei Pause ist `effectiveNow=pausedAt`, sonst `effectiveNow=now`.
  `elapsedS=floor(max(0,effectiveNow−startedAt−accumulatedPausedMs)/1000)`.
  Backgrounding und Neustart verändern den Status nicht; während aktiver Pause bleibt die
  Anzeige konstant, auch nach Neustart. Resume addiert `now−pausedAt` zu `accumulatedPausedMs`,
  leert `pausedAt` und setzt `status=running` in einer Transaktion. Ein laufender Timer
  rechnet beim Wiederöffnen die Hintergrundzeit mit; ein pausierter wartet auf Resume.
  Stop speichert den so berechneten Wert und beendet den Entwurf. Beispiel: Start 10:00:00,
  Pause 10:00:10, Neustart 10:00:20 → 10 s; Resume 10:00:25 → 15000 ms Pause;
  Stop 10:00:35 → 20 s. Ohne Pause wären 35 s verstrichen.
- Das Sekundenlimit gehört nur zu Backflush, mit getrennten Zählerbasen je `CareEvent.kind`.
  Die präzisen persistierten Pflegefelder und Standardwerte stehen in `domain.md`.
- Import erfordert sämtliche Top-Level-Felder und Typen des kanonischen Schemas aus
  `interfaces.md`, insbesondere das Objekt `settings` mit `hardnessUnit` und das Array
  `consumptionEvents`. Fehlende, zusätzliche oder falsch typisierte Top-Level-Felder,
  null statt Objekt/Array, unbekannte Einheit und fehlerhafte Zeitstempel führen vor jeder
  Änderung zum vollständigen Abbruch mit „Ungültige Importdatei“ / „Invalid import file“.
  Unbekannte `schemaVersion` behält den spezifischen Versionsfehler. Keine stillschweigenden
  Defaults für fehlende Importfelder; leere Arrays sind ausdrücklich zulässig.
  `settings` ersetzt nach vollständiger Validierung das lokale Singleton atomar;
  Datensätze der Arrays behalten die bestehenden `updatedAt`-/Tombstone-Konfliktregeln.

**Persistenz und Buchung (§3/6):** `drift` mit nativer SQLite auf Android/iOS; Chrome-Test über drift-Wasm/OPFS. Migrationen über `schemaVersion` .
Jeder Save ist eine Transaktion, Schaltfläche währenddessen gesperrt; `operationId` UUID verhindert doppelten Bestandsabzug. Brew speichert Snapshots
der Namen/Parameter/Mühle/Quelle, damit spätere Geräteänderungen historische Werte nicht verändern. Ein Brew lässt sich nach Abschluss nicht
überschreiben; „Nächster Versuch“ erzeugt einen neuen Entwurf. Archivieren erstattet keinen bereits verbrauchten Kaffee. `purgeG` ist tatsächlicher,
bestätigter Verbrauch; Hinweis allein bucht nichts. Abbruch nach Mahlen fragt „{g} g als Verbrauch speichern?“ / „Save {g} g as consumption?“;
Bestätigung speichert einen `ConsumptionEvent` (id, packId, grinderId, doseG=0, purgeG=0, wasteG, occurredAt, updatedAt, operationId), zählt in
Verbrauch/Mühlennutzung, nicht als Shot. Export ergänzt `consumptionEvents:[]` ; R4 berücksichtigt auch `wasteG` . Beispiel 250−17−2.5=230.5 g;
gleicher operationId erneut → 230.5 g. Für 4 Mühlen bleiben Historie und Totraumzustand unabhängig. Typ beeinflusst keine erfundene Skala. Min < Max,
Schritt > 0 und (Max−Min)/Schritt ganzzahlig; stufenlose Geräte erhalten ausdrücklich manuell definierte reproduzierbare Markierungsauflösung, kein
behauptetes Raster des Herstellers.

**Timer (§4):** `elapsedS=floor((now−startedAt−pausedMs)/1000)` , Start Espresso bei Pumpenstart inkl. Preinfusion, Filter beim ersten Wasser.
Hintergrund-Rückkehr berechnet aus Zeitstempeln; App-Neustart zeigt erhaltenen Entwurf mit „Fortsetzen“ / „Resume“ oder „Abbrechen“ / „Cancel“. Keine
automatische physische Maschinensteuerung. Beispiel Start 10:00:00, Pause 10:00:10–10:00:15, Stop 10:00:35 → 30 s. Geplante Filterzeiten sind absolute
Offsets; nie Schritte überspringen. Anzeige zusätzlich Differenz seit letzter bestätigter Summe (40→120 bedeutet 80 g hinzufügen). `pours` speichert
geplante und bestätigte Zeit/Summe. Manueller Timerwert überschreibt nur nach Bestätigung und erhält Originalwert im Snapshot. Über 120/600 s läuft
Anzeige weiter, Speichern verlangt zulässigen korrigierten Wert oder Abbruch.

**Pflege (§4):** Ohne Pflegeereignis ist `createdOn` der Basis-Tag, Nutzung ab Anlage; keine stillschweigende historische Reinigung. Alter, Shots,
Sekunden je Aufgabe/Gerät getrennt. Fehlendes Wasser → „Härte erfassen“ / „Enter hardness“, kein erfundenes Entkalkungsdatum. Gerät ohne
Eignungsbestätigung bleibt bei Handbuchhinweis. Feldwerte für Maschine: Temperatur 20–100 °C, Preinfusion 0–60 s, Totraum 0–50 g; Pflegegrenzen
positive Integer. Regel-Asset Eintrag ergänzt `kind: researched|productDefault` und `appliesTo` ; R8-Defaults tragen source none. Empfehlung zeigt bei
Heuristik Quellenlink UND „Produktheuristik“ / „Product heuristic“. Unbekannte Messwerte bleiben unbekannt, kein Härtewert aus TDS abgeleitet.

**Bestand (§4):** `remainingG>0` erforderlich für Vorschläge. Ruhe- und Altersgrenze verwenden lokale Kalendertage auch an Sommerzeitwechseln. Bereits
geöffnete bereite Packungen vor ungeöffneten, dann roastDate, createdAt, id aufsteigend; Filter-Blends nach anderen bereiten Packungen. R6 simuliert
tageweise mit allen zukünftigen readyDate/Alterstagen, sodass Zwischenlieferungen die Warnung schliessen können; die Formel des
Einzelpackungsbeispiels ist der Spezialfall. Je Tag volle `consumptionPerDay` decken, Teilrest allein deckt keinen Tag. Warnung zeigt jede
zusammenhängende Lücke; nicht bei Verbrauch 0. „Packung X öffnen“ ist nur dann Handlungsoption, wenn heute bereite ungeöffnete Packung tatsächlich
verfügbar ist, sonst „Jetzt bestellen“; Öffnen ist kein Bestellvorgang. Nach nächstem readyDate erneut bis zum spätesten vorhandenen readyDate prüfen;
ohne zukünftige Packung bis zum hypothetischen Liefer-/Bereitdatum. Beispiel heute 16.11., 90 g/18 g pro Tag deckt 16.–20.11.; weitere 36 g ab 21.11.
decken 21.–22.11.; nächste 250 g ab 25.11. → Lücke 23.–24.11.

**Import (§6):** UTF-8, höchstens 10 MiB, JSON-Objekt mit allen Arrays (leere erlaubt), RFC3339 UTC-Zeitstempel, gültige UUIDs, endliche Zahlen in
Feldgrenzen. Ungültiges JSON/Typ, doppelte ID in derselben Entität, unbekannte Version oder Übergrösse → vollständiger Abbruch, unveränderte DB,
Fehler „Ungültige Importdatei“ / „Invalid import file“ (Version hat den eigenen Text). Gleiche updatedAt → lokal gewinnt. Referenzen gegen den
vollständigen vorgeschlagenen Endbestand auflösen, unabhängig von Array-Reihenfolge; verweiste Records samt davon abhängigen Records überspringen und
zählen. Tombstones bleiben referenzierbar für Historie. Transaktion erst nach vollständiger Validierung. Ergebnis zeigt createdCount, replacedCount,
skippedCount. Beispiel lokale Mühle t=12:00, Import t=13:00 ersetzt; t=12:00 überspringt. Kein eigener HTTP-Server oder Cloud-API.

**Schrift und Tokens (UI):** Fraunces, Inter und JetBrains Mono für Timer/Ziffern werden lokal als Assets ausgeliefert, keine Font-CDN-Anfrage. Alle
geometrischen und Farbwerte sind intent; einzig Kontrast ≥4.5:1 für Text, ≥3:1 für Icons/Fokus, Fokus 2 dp mit 2 dp Abstand, Zielgrösse ≥48 dp sind
exact. `muted` : hell #6B584B / dunkel #C5B4A6; `primary` dunkel #DFA77D; onPrimary hell #FFFFFF / dunkel #1F1814. Timer verwendet tabellarische
Ziffern. Water-Balken: 8-dp-Spur in muted bei 15 %, Referenzfenster success bei 20 %, zwei 2-dp-Grenzstriche, Wertpunkt 12 dp in success/error; Dunkel
identische Geometrie mit Themenfarben. Brühkarten übernehmen Bohnenverlauf mit Tassen-Icon; Pflegekarte verwendet 48-dp-Schwamm auf surfaceVariant;
Wasserkarte 48-dp-Tropfen neben Mini-Härtebalken. Kein Foto erforderlich; kein undekorierter Platzhalter. Bei Farbhash-Kollision darf Nachbarkarte
identisch sein, Unterscheidung zusätzlich über Name/Röstpunkte; LF2 verlangt unterschiedliche Farbtöne nur bei unterschiedlichen Hashes.

**Komponentenzustände (UI):** Jede Komponente: hover nur mit Zeiger, Fokus/selected mit Rand und Semantics, disabled ohne Handler, loading mit
Skeleton/Spinner und Beschriftung „Lädt“ / „Loading“, error mit Inline-Grund und „Erneut versuchen“ / „Retry“, empty als gezeichneter Zustand oder
ausdrücklich nicht anwendbar. Felder zusätzlich busy gesperrt, selected=Textauswahl; Chips hover/focus/selected/disabled mit Rand/Häkchen, keine
leeren Chips; Banner leer nicht gerendert, loading Skeleton, error mit Aktion; Timer keine hover/selected/empty-Zustände im Lauf, disabled bei Pause,
Fehler erhält verstrichene Zeit. Theme-Overrides gelten auch für hover/pressed, kein heller Kupfertext auf dunklem Kupferbutton. Screen-Fehler erhält
Eingaben und lokale Daten.
