## UI und Design

### Präzisierungen mit Vorrang vor den Kurzfassungen unten

- Für sämtlichen Text, auch Timer und Grosstext, gilt exakt Kontrast mindestens 4.5:1.
  Die bisher genannte 3:1-Ausnahme für Grosstext entfällt; 3:1 gilt nur für Nicht-Text-Grafik.
- Bestandsbalken bei `orderPoint > 0` wie unten. Bei `orderPoint = 0` erfolgt keine Division:
  Bestand >0 → volle Breite in `success`, Bestand 0 → leerer Balken mit `error`-Rand.
  Die 50-%-Markierung entfällt, stattdessen Beschriftung „Kein Mindestbestand“ /
  „No minimum stock“. Beispiel: manueller Mindestbestand 0, Verbrauch 0, Bestand 250 g
  → voller grüner Balken ohne Schwellenstrich; Bestand 0 → leerer roter Rand.
- LF9 ist auf gemessene Wasserparameter begrenzt: sie zeigen Wertbalken und Referenzgrenzen.
  Ein ungemessener Parameter zeigt ausschliesslich Label und „nicht gemessen“ /
  „not measured“, ohne Wertpunkt oder Messwertbalken; null wird nie als Nullmessung gezeichnet.

**Richtung:** „Warme Rösterei“ – ruhig, warm, lesbar; Karten in Papier-Anmutung = Fläche `surfaceVariant` , 1 dp Rand `onSurface` mit Alpha 12 %,
Kartenschatten gemäss Tokens; ein Akzent in Kupfer. **Looks like:**
- *Liste* (Bohnen, Brühungen, Maschinen): vertikale Karten, 88 dp hoch, 12 dp Abstand; links ein 56 × 56-dp-Bildbereich als visueller Anker.
- *Detail*: Kopfband mit grossem Bildbereich (160 dp hoch), darunter Kennzahlen-Kacheln in 2 Spalten, darunter Verlauf/Empfehlung.
- *Formular*: einspaltig, Felder mit Label oben, Einheit als Suffix im Feld, primäre Schaltfläche unten fixiert.
- *Fokus-Modus* (Filter geführt): Vollbild, riesiger Timer (Ziffern 72 sp) und darunter die Ziel-Zwischensumme in g (48 sp), keine Navigation, ein
  Schritt pro Ansicht.

**Tokens** (intent = Richtwert, exact = verbindlich):
- **Token**: Wert | Art

- **`primary`**: #8A4B2A hell / #DFA77D dunkel (Kupfer); heller Button: Text #FFFFFF, dunkler Button: Text #1F1814; (Hauptaktion, aktive Navigation);
  hover hell #7F4527 / dunkel #E5B591 (Schwarz-Overlay 8 %), pressed #743F23 (Overlay 16 %); disabled: Alpha 38 % | intent
- **`surface`**: #FBF6EF hell / #1F1814 dunkel | intent
- **`surfaceVariant`**: #F0E6D8 hell / #2B211B dunkel (Karten, Seitenleiste) | intent
- **`onSurface`**: #2A1E17 hell / #F3E9DD dunkel | intent
- **`success`**: #36703F hell (Kontrast etwa 4.8:1 auf `surfaceVariant` , 5.5:1 auf `surface` , relative Luminanz ≤ 0.139) / #7CC28E dunkel (Bereit) |
  exact (Kontrast)
- **`warning`**: #8A5A00 hell (Text, Icon und Rand; Kontrast zu `surface` etwa 5.5:1, relative Luminanz 0.127 ≤ 0.167) / #E0B050 dunkel | exact
  (Kontrast)
- **`error`**: #B3261E hell / #F2B8B5 dunkel (Warnung) | intent
- **Kontrast Text**: ≥ 4.5:1, Grosstext ≥ 3:1; gilt für jede Text-/Hintergrund-Paarung inkl. `warning` , `success` , `error` auf `surface` und
  `surfaceVariant` | exact
- **Fokusring**: 2 dp in `primary` , 2 dp Abstand | exact
- **Schrift**: Überschriften „Fraunces“ (Serif), Text „Inter“; Fallback System-Serif/-Sans | intent
- **Typ-Skala (sp)**: 12, 14, 16, 20, 24, 32, 48, 72 | intent
- **Abstand (dp)**: 4, 8, 12, 16, 24, 32, 48 | intent
- **Radius (dp)**: Karten 16, Felder 12, Chips 999 | intent
- **Schatten**: Karte: y 2 dp, Blur 8 dp, Alpha 8 % `onSurface` ; Hover y 4 dp; im Dunkel kein Schatten, stattdessen 1 dp Rand | intent
- **Breakpoints (dp)**: Phone < 600, Tablet 600–1023, Desktop ≥ 1024 | intent

**Gezeichnete Elemente:**
- *Bohnenkarte, Bildbereich (56 × 56 dp, Radius 12):* linearer Verlauf 135° im HSL-Farbmodell von `HSL(H, 55 %, 62 %)` zu
  `HSL((H + 340) mod 360, 55 %, 42 %)` . `H = 15 + (fnv1a32(lowercase(name) als UTF-8) mod 36)` Grad, also 15°–50° (Braun/Orange); Hash-Funktion
  FNV-1a 32 Bit (Offset 2166136261, Primzahl 16777619), nicht `String.hashCode` . Mittig ein Bohnen-Icon 32 dp in `surface` (Alpha 90 %). Dunkel:
  Helligkeit beider Stops −12 Prozentpunkte. Rechts unten Röstgrad-Punkte (6 dp, Abstand 2 dp): light 1, medium 2, mediumDark 3, dark 4 gefüllte
  Punkte von 4.
- *Mühlenkarte (Bildbereich):* Drehknopf-Icon 40 dp, darum ein Bogen (Durchmesser 56 dp, Strichstärke 4 dp, Sweep 270°, Start 135° im Uhrzeigersinn,
  Ende 45°); Spur `onSurface` Alpha 15 %, Wert `primary` ; Wert-Anteil = (Einstellung − `scaleMin` ) / (`scaleMax` − `scaleMin` ). `scaleMin` und
  `scaleMax` als 12-sp-Labels unter dem Start- bzw. Endpunkt des Bogens.
- *Maschinenkarte:* Siebträger-Icon 24 dp in der Mitte eines Rings (Durchmesser 56 dp, Strichstärke 4 dp). Voller Ring = 7 Tage bis zum Backflush;
  Füllung = verbleibende Tage / 7 (mind. 0). Farbe: > 2 verbleibende Tage `success` , 1–2 `warning` , ≤ 0 `error` .
- *Platzhalter-Bild:* gestrichelter Kreis 64 dp mit Kamera-Icon, Text „Kein Bild“/„No image“.
- *Leere Zustände:* Icon 64 dp in `primary` Alpha 40 %, Titel (20 sp), Erklärsatz (14 sp), eine Aktion (Button).
- *Bestands-Balken:* 8 dp hoch, Radius 4 dp, volle Breite = 2 × `orderPoint` (Gesamtbestand der Bohne); Füllbreite = min(1, Gesamtbestand / (2 ×
  orderPoint)) × Breite; Markierung (2-dp-Strich) bei 50 % = `orderPoint` . Füllung: Bestand > orderPoint `success` ; 0 < Bestand ≤ orderPoint
  `warning` ; Bestand 0 leer mit Rand `error` .

**Komponenten (Zustände):**
- *Button:* default (`primary` gefüllt), hover (hell #7F4527 / dunkel #E5B591), pressed (hell #743F23 / dunkel #EBC3A5), selected mit Häkchen,
  disabled (Alpha 38 %, nicht klickbar), loading (20-dp-Spinner und Semantics), error (Fehlerbanner mit Wiederholen), empty nicht anwendbar. Dunkler
  Buttontext #1F1814.
- *Karte:* default, hover (Schatten y 4 dp), selected (2 dp `primary` Rand), disabled (Alpha 60 %), empty (Empty-State), loading (Skeleton in
  `surfaceVariant` ), error (Rand `error` mit Text und „Erneut versuchen“).
- *Feld:* default, focus (Fokusring), error (rote Zeile mit Text), disabled.
- *Chip:* „Bereit“ (success), „Ruht noch X Tage“ (warning), „Zu alt“ (error).
- *Banner:* Info/Warnung/Fehler mit Icon, Text und optionaler Aktion.
- *Themes:* hell und dunkel als Token-Overrides (`surface`, `surfaceVariant` , `onSurface` , `success` , `warning` , `error` , Schatten); Wahl nach
  System.

**App-Shell und Navigation:** Phone: Bottom-Bar mit 5 Zielen (Heute, Bohnen, Brühen, Ausrüstung, Mehr). Tablet: Navigation-Rail mit denselben 5
Zielen. Desktop (≥ 1024 dp): feste Seitenleiste 240 dp mit 7 Einträgen: Heute, Bohnen, Brühen, Ausrüstung, Wasser, Pflege, Einstellungen (Mehr
entfällt). Oben Titel und Aktionen. Seitenleiste und Inhalt füllen die Seite bis zum Viewport-Ende.

- **Screen**: Erreichbar

- **Heute (Home)**: Ziel „Heute“
- **Bohnen (Liste) / Bohnendetail / Bohnenformular**: „Bohnen“; Karte; Button „+“
- **Brühungen (Liste) / Brühungsformular / Brühungsdetail mit Empfehlung**: „Brühen“; „+“; Karte
- **Filter geführt (Fokus-Modus)**: „Brühen“ → „Filter starten“; Phone ohne Navigation
- **Ausrüstung (Mühlen, Maschinen) / Formulare**: „Ausrüstung“, Tabs
- **Wasser (Liste, Formular)**: Phone/Tablet: „Mehr“ → Wasser; Desktop: Seitenleiste „Wasser“
- **Pflege (Reinigung)**: „Heute“-Kachel; Phone/Tablet „Mehr“ → Pflege; Desktop Seitenleiste „Pflege“
- **Einstellungen (Einheit, Export/Import)**: Phone/Tablet „Mehr“ → Einstellungen; Desktop Seitenleiste

**Screens (Komposition):**
- *Heute:* Region 1 Warnbanner (Lückenwarnung, Bestellhinweise, Pflege fällig, Wasser-Check), Region 2 „Jetzt trinkbereit“ (Karten), Region 3 letzte
  Brühung. Primäre Aktion: „Neue Brühung“ (FAB). Dichte: mittel. Leer: Icon Kaffeebohne, „Noch nichts da“ / „Nothing here yet“, „Lege deine erste
  Bohne an.“ / „Add your first bean.“, Aktion „Bohne hinzufügen“ / „Add bean“.
- *Bohnen-Liste:* Karten sortiert nach R3; Chip Bereit/Ruht/Zu alt; Bestands-Balken; primär „Bohne hinzufügen“. Leer: Icon Bohne, „Noch keine Bohnen“
  / „No beans yet“, „Lege deine erste Bohne an.“ / „Add your first bean.“, Aktion „Bohne hinzufügen“ / „Add bean“.
- *Bohnendetail:* Kopfband, Kacheln (Restgramm, Reichweite in Tagen, Bereit-Datum, Mindestbestand), Packungsliste, Bestellhinweis, Aktion „Packung
  hinzufügen“ (primär), „Öffnen“ (sekundär).
- *Bohnen-/Packungsformular:* Name, Röster, Röstgrad, Art, Lieferzeit (Tage), Mindestbestand (g, optional); Packung: Röstdatum, Gewicht (g); primär
  „Speichern“/„Save“; Fehler pro Feld.
- *Brühungs-Liste:* nach Datum; Zeile zeigt Methode, Bohne, Zeit in s, Bewertung. Leer: Icon Tasse, „Noch keine Brühungen“ / „No brews yet“, „Erfasse
  deinen ersten Shot.“ / „Log your first shot.“, Aktion „Brühung erfassen“ / „Log a brew“.
- *Brühungsformular:* Methode, Maschine (nur Espresso), Mühle (Mahlgrad-Eingabe als Stepper in der Rasterstufe), Packung, Dosis, Spülmenge (g),
  Ausbeute, Shot-Timer (Start/Stopp, manuell änderbar), Wasserprofil, Geschmack (Chips), Bewertung; primär „Speichern“; sekundär „Timer starten“.
  Mühle-Spülhinweis (R7) als Banner oben.
- *Brühungsdetail:* Werte, darunter Karte „Empfehlung“ mit einem Satz, Grund und Quelle (Link-Text); Aktion „Nächster Versuch“ (übernimmt die Werte).
- *Filter geführt:* Setup (Methode, Dosis, Verhältnis-Slider 1:14–1:18 in 0.5-Schritten, Anzeige „Wasser gesamt: 320 g“), dann pro Schritt Timer plus
  Ziel-Zwischensumme („Giesse bis 120 g“). Rückmeldung am Schrittende: Android/iOS `HapticFeedback.mediumImpact` und `SystemSound.alert` ; Chrome: nur
  visuell (Hintergrund 300 ms in `primary` Alpha 20 %), keine Haptik. Primär „Weiter“/„Next“, sekundär „Abbrechen“; am Ende Abfluss-Zeit und Geschmack
  erfassen.
- *Ausrüstung:* zwei Tabs Mühlen/Maschinen; Karten; Formulare für Skala (Min, Max, Schritt, Richtung), Totraum (g), Maschine (Temperatur °C,
  Preinfusion s, Druckprofil, Standard-Wasser). Leer Mühlen: Icon Mühle, „Noch keine Mühle“ / „No grinder yet“, „Lege deine Mühle mit Skala und
  Totraum an.“ / „Add your grinder with scale and dead space.“, Aktion „Mühle hinzufügen“ / „Add grinder“. Leer Maschinen: Icon Espressomaschine,
  „Noch keine Maschine“ / „No machine yet“, „Lege deine Maschine mit Einstellungen an.“ / „Add your machine with its settings.“, Aktion „Maschine
  hinzufügen“ / „Add machine“.
- *Wasser:* Profil-Liste; Detail mit Messwert-Balken je Parameter gegen den SCA-Bereich; Härte in gewählter Einheit; Status-Chip „Gemessene Werte im
  Referenzbereich“ / „Ausserhalb Referenzbereich“. Leer: Icon Tropfen, „Noch kein Wasserprofil“ / „No water profile yet“, „Erfasse die Härte deines
  Wassers.“ / „Enter your water's hardness.“, Aktion „Wasserprofil hinzufügen“ / „Add water profile“.
- *Wasser-Formular:* Name (1–60 Zeichen); Härte (Pflicht, Einheit-Umschalter °fH/°dH/ppm, Bereich 0–1000 ppm); Alkalinität (ppm, 0–500); TDS (mg/L,
  0–1000); pH (0–14); Natrium (mg/L, 0–500); Chlor (mg/L, 0–10); optionale Felder dürfen leer bleiben („nicht gemessen“). Fehler: DE „Wert zwischen
  {min} und {max} eingeben“, EN „Enter a value between {min} and {max}“; Name leer: „Name eingeben“ / „Enter a name“. Primär „Speichern“.
- *Pflege:* Maschinenweise Aufgaben Backflush/Entkalken/Mühle mit Fälligkeit, Shots seit letztem Mal; primär „Erledigt“. Leer (keine Maschine/Mühle):
  Icon Schwamm, „Nichts zu pflegen“ / „Nothing to maintain“, „Lege zuerst eine Maschine an.“ / „Add a machine first.“, Aktion „Maschine hinzufügen“ /
  „Add machine“.
- *Einstellungen:* Härteeinheit (°fH/°dH/ppm), Export, Import, Über/Quellen-Liste.

**Texte (DE / EN, Beispiele verbindlich):** Heute/Today, Bohnen/Beans, Brühen/Brew, Ausrüstung/Equipment, Mehr/More, Speichern/Save, Abbrechen/Cancel,
Bereit/Ready, „Ruht noch {n} Tage“/„Resting, {n} days left“, „Jetzt bestellen“/„Order now“, „Packung {x} öffnen“/„Open pack {x}“, „Kein trinkbereiter
Kaffee vom {von} bis {bis}“/„No ready coffee from {from} to {to}“.

**Look and feel**
- LF1 Alle Screens: Hintergrund, Seitenleiste und Panels füllen die Seite bis zum unteren Viewport-Rand, auch bei kurzem Inhalt.
- LF2 Bohnen, Heute: Der Bildbereich jeder Bohnenkarte ist ein Verlauf mit Bohnen-Icon; Nachbarkarten mit unterschiedlichen Hash-Farbtönen
  unterscheiden sich; Röstgrad-Punkte sichtbar.
- LF3 Alle Listen (Bohnen, Brühungen, Mühlen, Maschinen, Wasser, Pflege, Heute): Kein Titel steht über einer leeren Fläche; der Empty-State mit Icon,
  Titel, Satz und Aktion ist sichtbar.
- LF4 Alle Screens: Jeder Text und jede Einheit ist in der Sprache des Screens (DE: „g“, „s“, „°C“, „°fH“; Datum 16.11.2026, Dezimalpunkt; EN: Datum
  16 Nov 2026).
- LF5 Filter geführt: Timer-Ziffern ≥ 72 sp, Ziel-Zwischensumme ≥ 48 sp, genau eine primäre Schaltfläche, keine Navigationsleiste.
- LF6 Heute, Bohnendetail: Lücken- und Bestellwarnungen stehen als Banner in `warning` /`error` mit Datum von–bis und einer Aktion.
- LF7 Phone (390 dp): Bottom-Bar mit 5 Zielen, kein horizontales Scrollen; ab 1024 dp feste Seitenleiste 240 dp mit 7 Einträgen.
- LF8 Dunkel: Karten haben 1-dp-Rand statt Schatten, Text-Kontrast ≥ 4.5:1.
- LF9 Wasser: Jeder Parameter zeigt einen Balken mit markiertem SCA-Bereich; ausserhalb ist der Balken `error` .
- LF10 Formulare: Einheit steht als Suffix im Feld, Fehler stehen als rote Zeile unter dem Feld, die primäre Schaltfläche ist die einzige gefüllte.
- LF11 Bohnen: Der Bestands-Balken zeigt die Markierung bei 50 % und die Füllfarbe gemäss Bestand (success/warning).
- LF12 Ausrüstung: Mühlenkarten zeigen den Bogen mit Min-/Max-Label, Maschinenkarten den Ring mit Tage-Anzeige.
