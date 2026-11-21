# UI und Design (Ergänzung zu SPEC.md)


**Richtung:** „Warme Rösterei“ – ruhig, warm, lesbar; Karten in Papier-Anmutung = Fläche `surfaceVariant`, 1 dp Rand `onSurface` mit Alpha 12 %,
Kartenschatten gemäss Tokens; ein Akzent in Kupfer. **Looks like:**
- *Liste* (Bohnen, Brühungen, Maschinen): vertikale Karten, 88 dp hoch, 12 dp Abstand; links ein 56 × 56-dp-Bildbereich als visueller Anker.
- *Detail*: Kopfband mit grossem Bildbereich (160 dp hoch), darunter Kennzahlen-Kacheln in 2 Spalten, darunter Verlauf/Empfehlung.
- *Formular*: einspaltig, Felder mit Label oben, Einheit als Suffix im Feld, primäre Schaltfläche unten fixiert.
- *Fokus-Modus* (Filter geführt): Vollbild, riesiger Timer (Ziffern 72 sp) und darunter die Ziel-Zwischensumme in g (48 sp), keine Navigation, ein
  Schritt pro Ansicht.

**Tokens** (intent = Richtwert, exact = verbindlich):
| Token | Wert | Art |
|---|---|---|
| `primary` | #8A4B2A Kupfer hell / #E0A27A dunkel (Hauptaktion, aktive Navigation); hover/pressed: Overlay 8 % / 16 % (hell Schwarz: #7F4527 / #743F23; dunkel Weiss); disabled: Alpha 38 % | intent | <!-- octryx: allow-long-line -->
| `onPrimary` | #FFFFFF hell / #1F1814 dunkel (Text und Icon auf gefüllten `primary`-Flächen, Kontrast ≥ 4.5:1) | exact (Kontrast) |
| `surface` | #FBF6EF hell / #1F1814 dunkel | intent |
| `surfaceVariant` | #F0E6D8 hell / #2B211B dunkel (Karten, Seitenleiste) | intent |
| `onSurface` | #2A1E17 hell / #F3E9DD dunkel | intent |
| `success` | #36703F hell (Kontrast etwa 4.8:1 auf `surfaceVariant`, 5.5:1 auf `surface`, relative Luminanz ≤ 0.139) / #7CC28E dunkel (Bereit) | exact (Kontrast) | <!-- octryx: allow-long-line -->
| `warning` | #8A5A00 hell (Text, Icon und Rand; Kontrast zu `surface` etwa 5.5:1, relative Luminanz 0.127 ≤ 0.167) / #E0B050 dunkel | exact (Kontrast) |
| `error` | #B3261E hell / #F2B8B5 dunkel (Warnung) | intent |
| Kontrast Text | ≥ 4.5:1, Grosstext ≥ 3:1; gilt für jede Text-/Hintergrund-Paarung inkl. `warning`, `success`, `error` auf `surface` und `surfaceVariant` | exact | <!-- octryx: allow-long-line -->
| Fokusring | 2 dp in `primary`, 2 dp Abstand | exact |
| Schrift | Überschriften „Fraunces“ (Serif), Text „Inter“; Fallback System-Serif/-Sans | intent |
| Typ-Skala (sp) | 12, 14, 16, 20, 24, 32, 48, 72 | intent |
| Abstand (dp) | 4, 8, 12, 16, 24, 32, 48 | intent |
| Radius (dp) | Karten 16, Felder 12, Chips 999 | intent |
| Schatten | Karte: y 2 dp, Blur 8 dp, Alpha 8 % `onSurface`; Hover y 4 dp; im Dunkel kein Schatten, stattdessen 1 dp Rand | intent |
| Breakpoints (dp) | Phone < 600, Tablet 600–1023, Desktop ≥ 1024 | intent |

**Gezeichnete Elemente:**
- *Bohnenkarte, Bildbereich (56 × 56 dp, Radius 12):* linearer Verlauf 135° im HSL-Farbmodell von `HSL(H, 55 %, 62 %)` zu
  `HSL((H + 340) mod 360, 55 %, 42 %)`. `H = 15 + (fnv1a32(lowercase(name) als UTF-8) mod 36)` Grad, also 15°–50° (Braun/Orange);
  Hash-Funktion FNV-1a 32 Bit (Offset 2166136261,
  Primzahl 16777619), nicht `String.hashCode`. Mittig ein Bohnen-Icon 32 dp in `surface` (Alpha 90 %). Dunkel: Helligkeit beider Stops −12
  Prozentpunkte. Rechts unten Röstgrad-Punkte (6 dp, Abstand 2 dp): light 1, medium 2, mediumDark 3, dark 4 gefüllte Punkte von 4.
- *Mühlenkarte (Bildbereich):* Drehknopf-Icon 40 dp, darum ein Bogen (Durchmesser 56 dp, Strichstärke 4 dp, Sweep 270°, Start 135° im Uhrzeigersinn,
  Ende 45°); Spur `onSurface` Alpha 15 %, Wert `primary`; Wert-Anteil = (Einstellung − `scaleMin`) / (`scaleMax` − `scaleMin`). `scaleMin` und
  `scaleMax` als 12-sp-Labels unter dem Start- bzw. Endpunkt des Bogens.
- *Maschinenkarte:* Siebträger-Icon 24 dp in der Mitte eines Rings (Durchmesser 56 dp, Strichstärke 4 dp). Voller Ring = 7 Tage bis zum Backflush;
  Füllung = verbleibende Tage / 7 (mind. 0, höchstens 1). Verbleibende Tage = ganze Tage bis zur Fälligkeit, aufgerundet. Farbe: > 2 `success`,
  1–2 `warning`, ≤ 0 `error` (lückenlos; Pflege-Fälligkeit R-Pflege).
- *Onboarding-Kopf (160 dp hoch, Radius 16 unten):* linearer Verlauf 135° von `HSL(H, 55 %, 62 %)` zu `HSL((H + 340) mod 360, 55 %, 42 %)` mit fester
  Tönung je Seite: Seite 1 H = 30 (zweiter Stop 10°), Seite 2 H = 38 (18°), Seite 3 Mühle H = 22 (2°), Seite 4 Bohne H = 46 (26°), damit sich die
  Seiten unterscheiden. Mittig ein Icon 64 dp in `surface` (Alpha 90 %): Tasse (1), Liste mit Häkchen (2), Mühlen-Drehknopf (3), Bohne (4). Dunkel:
  Lightness beider Stops −12 Punkte (50 % / 30 %). Fortschritt: 4 Punkte (8 dp, Abstand 8 dp) unter dem Kopf; erledigte und aktuelle Punkte `primary`,
  übrige `onSurface` Alpha 15 % (Farben je Theme); daneben Text „k von 4“. Tokens: `onboardingHeaderHeight` 160 dp, `onboardingMaxWidth`
  480 dp, `minTouchTarget` 48 dp, `focusRingWidth` 2 dp.
- *Platzhalter-Bild:* gestrichelter Kreis 64 dp mit Kamera-Icon, Text „Kein Bild“/„No image“.
- *Leere Zustände:* Icon 64 dp in `primary` Alpha 40 %, Titel (20 sp), Erklärsatz (14 sp), eine Aktion (Button).
- *Bestands-Balken:* 8 dp hoch, Radius 4 dp, volle Breite = 2 × `orderPoint` (Gesamtbestand der Bohne); Füllbreite = min(1, Gesamtbestand / (2 ×
  orderPoint)) × Breite; Markierung (2-dp-Strich) bei 50 % = `orderPoint`. Füllung: Bestand > orderPoint `success`; 0 < Bestand ≤ orderPoint
  `warning`; Bestand 0 leer mit Rand `error`.

**Komponenten (Zustände):**
- *Button:* default (`primary` gefüllt), hover (#7F4527), pressed (#743F23), disabled (Alpha 38 %), loading (20-dp-Spinner statt Text).
- *Karte:* default, hover (Schatten y 4 dp), selected (2 dp `primary` Rand), disabled (Alpha 60 %), empty (Empty-State), loading (Skeleton in
  `surfaceVariant`), error (Rand `error` mit Text und „Erneut versuchen“).
- *Feld:* default, focus (Fokusring), error (rote Zeile mit Text), disabled.
- *Chip:* „Bereit“ (success), „Ruht noch X Tage“ (warning), „Zu alt“ (error).
- *Banner:* Info/Warnung/Fehler mit Icon, Text und optionaler Aktion.
- *Themes:* hell und dunkel als Token-Overrides (`primary`, `onPrimary`, `surface`, `surfaceVariant`, `onSurface`, `success`, `warning`, `error`,
  Schatten); Wahl nach System. Hover/pressed-Overlay: hell Schwarz, dunkel Weiss.

**App-Shell und Navigation:** Phone: Bottom-Bar mit 5 Zielen (Heute, Bohnen, Brühen, Ausrüstung, Mehr). Tablet: Navigation-Rail mit denselben 5
Zielen. Desktop (≥ 1024 dp): feste Seitenleiste 240 dp mit 7 Einträgen: Heute, Bohnen, Brühen, Ausrüstung, Wasser, Pflege, Einstellungen (Mehr
entfällt). „Mehr“ (Phone/Tablet) listet Wasser, Pflege, Einstellungen. Oben Titel und Aktionen. Seitenleiste und Inhalt füllen die Seite bis zum Viewport-Ende.

| Screen | Erreichbar |
|---|---|
| Onboarding (4 Seiten) | Nur beim ersten Start (`onboardingDone` fehlt oder `false`), Vollbild ohne Bottom-Bar, Rail oder Seitenleiste; von keiner anderen Stelle erreichbar; nach Abschluss oder Überspringen → Heute (Phone und Desktop gleich) | <!-- octryx: allow-long-line -->
| Heute (Home) | Ziel „Heute“ |
| Bohnen (Liste) / Bohnendetail / Bohnenformular | „Bohnen“; Karte; Button „+“ |
| Brühungen (Liste) / Brühungsformular / Brühungsdetail mit Empfehlung | „Brühen“; „+“; Karte |
| Filter geführt (Fokus-Modus) | „Brühen“ → „Filter starten“; Phone ohne Navigation |
| Ausrüstung (Mühlen, Maschinen) / Formulare | „Ausrüstung“, Tabs |
| Wasser (Liste, Formular) | Phone/Tablet: „Mehr“ → Wasser; Desktop: Seitenleiste „Wasser“ |
| Pflege (Reinigung) | „Heute“-Kachel; Phone/Tablet „Mehr“ → Pflege; Desktop Seitenleiste „Pflege“ |
| Einstellungen (Einheit, Export/Import) | Phone/Tablet „Mehr“ → Einstellungen; Desktop Seitenleiste |

**Screens (Komposition):**
- *Onboarding:* Vollbild, auf allen Breakpoints eine mittig zentrierte Spalte (max. 480 dp), Dichte mittel. Regionen von oben: Kopf mit Verlauf und
  Icon (160 dp), Fortschritt (Punkte plus „k von 4“), Titel (Fraunces 24 sp) mit Text (Inter 16 sp), Inhalt, Aktionsleiste unten fixiert. Primäre
  Aktion: „Weiter“/„Next“ (gefüllt, `primary`); sekundär als Textschaltflächen „Zurück“/„Back“ (ab Seite 2) und „Überspringen“/„Skip“ (auf jeder
  Seite, ohne Rückfrage; setzt `onboardingDone` und führt zu Heute; bereits erfasste Mühle/Bohne bleiben). Titel und Text (DE / EN):
  Seite 1 „Willkommen“ / „Welcome“, „Halte fest, wie dein Kaffee gelingt.“ / „Keep track of how your coffee turns out.“ Seite 2 „Das kann die
  App“ / „What the app does“, drei Punkte „Brühungen erfassen“ / „Log brews“, „Bohnen und Ruhezeit führen“ / „Track beans and resting time“,
  „Empfehlung zur Verbesserung“ / „Get tips to improve“. Seite 3 „Deine Mühle“ / „Your grinder“, „Lege deine Mühle mit Skala und Totraum an.“ /
  „Add your grinder with scale and dead space.“ Seite 4 „Deine erste Bohne“ / „Your first bean“, „Lege deine erste Bohne an.“ / „Add your first
  bean.“ Seite 3: Mühlenformular (Felder und Fehler wie in Ausrüstung), primär „Speichern“/„Save“, sekundär „Später“/„Later“; nach dem Speichern
  automatisch Seite 4. Seite 4: Bohnenformular (Name, Röster, Röstgrad, Art), primär „Speichern“, sekundär „Später“; nach dem Speichern bleibt die
  Seite stehen, zeigt „Angelegt: {Name}“/„Created: {name}“ statt des Formulars und die primäre Aktion „Los geht’s“/„Let’s go“ → Heute. Fehler:
  rote Zeile unter dem Feld. Schreibfehler des Flags: Banner (Fehler) „Einstellung konnte nicht gespeichert werden“ / „Setting could not be
  saved“ mit Aktion „Erneut versuchen“ / „Retry“, Nutzer bleibt auf der Seite. Touch-Ziele ≥ `minTouchTarget`, Fokusring `focusRingWidth`,
  Semantics-Labels für Fortschritt, „Überspringen“ und „Zurück“.
- *Heute:* Region 1 Warnbanner (Lückenwarnung, Bestellhinweise, Pflege fällig, Wasser-Check), Region 2 „Jetzt trinkbereit“ (Karten), Region 3 letzte
  Brühung; Bohnen ohne Packung stehen in einer Region „Ohne Packung“ / „No pack yet“ mit Hinweis „Packung hinzufügen“ / „Add a pack“. Primäre
  Aktion: „Neue Brühung“ (FAB). Dichte: mittel. Leer (nur wenn keine Bohne existiert):
  Icon Kaffeebohne, „Noch nichts da“ / „Nothing here yet“, „Lege deine erste
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
- *Filter geführt:* Setup (Methode, Dosis, Verhältnis-Slider 1:14–1:18 in 0.5-Schritten, Anzeige „Wasser gesamt: {g} g“ = Dosis × Verhältnis, z. B.
  20 g × 16 = „320 g“), dann pro Schritt Timer plus
  Ziel-Zwischensumme („Giesse bis 120 g“). Rückmeldung am Schrittende: Android/iOS `HapticFeedback.mediumImpact` und `SystemSound.alert`; Chrome: nur
  visuell (Hintergrund 300 ms in `primary` Alpha 20 %), keine Haptik. Primär „Weiter“/„Next“, sekundär „Abbrechen“; am Ende Abfluss-Zeit und Geschmack
  erfassen.
- *Ausrüstung:* zwei Tabs Mühlen/Maschinen; Karten; Formulare für Skala (Min, Max, Schritt, Richtung), Totraum (g), Maschine (Temperatur °C,
  Preinfusion s, Druckprofil, Standard-Wasser). Leer Mühlen: Icon Mühle, „Noch keine Mühle“ / „No grinder yet“, „Lege deine Mühle mit Skala und
  Totraum an.“ / „Add your grinder with scale and dead space.“, Aktion „Mühle hinzufügen“ / „Add grinder“. Leer Maschinen: Icon Espressomaschine,
  „Noch keine Maschine“ / „No machine yet“, „Lege deine Maschine mit Einstellungen an.“ / „Add your machine with its settings.“, Aktion „Maschine
  hinzufügen“ / „Add machine“.
- *Wasser:* Profil-Liste; Detail mit Messwert-Balken je Parameter gegen den SCA-Bereich; Härte in gewählter Einheit; Status-Chip „Im SCA-Bereich“ /
  „Ausserhalb SCA“. Leer: Icon Tropfen, „Noch kein Wasserprofil“ / „No water profile yet“, „Erfasse die Härte deines Wassers.“ / „Enter your water's
  hardness.“, Aktion „Wasserprofil hinzufügen“ / „Add water profile“.
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
- LF2 Bohnen, Heute: Der Bildbereich jeder Bohnenkarte ist ein Verlauf mit Bohnen-Icon; Nachbarkarten unterscheiden sich im Farbton
  (Test: „Bohne 1“ H 35 und „Bohne A“ H 43, Differenz ≥ 5°); Röstgrad-Punkte sichtbar.
- LF3 Alle Listen (Bohnen, Brühungen, Mühlen, Maschinen, Wasser, Pflege, Heute): Kein Titel steht über einer leeren Fläche; der Empty-State mit Icon,
  Titel, Satz und Aktion ist sichtbar.
- LF4 Alle Screens: Jeder Text und jede Einheit ist in der Sprache des Screens (DE: „g“, „s“, „°C“, „°fH“; Datum 16.11.2026, Dezimalpunkt; EN: Datum
  16 Nov 2026).
- LF5 Filter geführt: Timer-Ziffern ≥ 72 sp, Ziel-Zwischensumme ≥ 48 sp, genau eine primäre Schaltfläche, keine Navigationsleiste.
- LF6 Heute, Bohnendetail: Lücken- und Bestellwarnungen stehen als Banner in `warning`/`error` mit Datum von–bis und einer Aktion.
- LF7 Phone (390 dp): Bottom-Bar mit 5 Zielen, kein horizontales Scrollen; ab 1024 dp feste Seitenleiste 240 dp mit 7 Einträgen.
- LF8 Dunkel: Karten haben 1-dp-Rand statt Schatten, Text-Kontrast ≥ 4.5:1.
- LF9 Wasser: Jeder Parameter zeigt einen Balken mit markiertem SCA-Bereich; ausserhalb ist der Balken `error`.
- LF10 Formulare: Einheit steht als Suffix im Feld, Fehler stehen als rote Zeile unter dem Feld, die primäre Schaltfläche ist die einzige gefüllte.
- LF11 Bohnen: Der Bestands-Balken zeigt die Markierung bei 50 % und die Füllfarbe gemäss Bestand (success/warning).
- LF12 Ausrüstung: Mühlenkarten zeigen den Bogen mit Min-/Max-Label, Maschinenkarten den Ring mit Tage-Anzeige.

- LF13 Onboarding: Vollbild ohne Bottom-Bar, Rail oder Seitenleiste, Inhalt in einer zentrierten Spalte ≤ 480 dp; bei 390 dp Breite ist nichts
  abgeschnitten und es gibt kein horizontales Scrollen; Kopf mit Verlauf und Icon, je Seite anderer Farbton; „k von 4“ und Punkte sichtbar; „Weiter“
  ist die einzige gefüllte Schaltfläche.

