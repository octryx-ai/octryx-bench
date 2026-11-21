### Vollständiger Bildschirmvertrag

#### Präzisierte Aktionen und Zustände

- `brew-detail` → „Nächster Versuch“ kopiert Methode, Maschine, Mühle, Packung, Wasserprofil,
  Dosis, zuletzt bestätigten Purge, Ausbeute bzw. Filterrezept, Temperatur, Preinfusion,
  Druckprofil und Mahlgrad in einen neuen Entwurf. Zeit, Geschmack und Bewertung sind leer,
  `operationId` ist neu. Vor dem Start werden aktueller Bestand, Archivierung und Bereitschaft
  erneut geprüft; historische Snapshots werden nicht als heutige Verfügbarkeit behandelt.
  Bei `grind` wird nur der vorgeschlagene Mahlgrad eingesetzt. Bei `none` bleiben alle
  Parameter gleich. Bei `water` bleibt auch das Wasserprofil zunächst gleich, der Entwurf
  zeigt zuerst die Wasserwarnung und führt zur Wasserprüfung/-auswahl; keine automatische
  Profilwahl. Bei `rest` bleibt die Packung gleich, der Entwurf zeigt das Bereit-Datum und
  bietet eine bereite Packung zur manuellen Auswahl. Ein Filter mit unreifer Packung kann
  nicht starten. Kein Wasser-/Ruhehinweis wird als numerische Mahlgradänderung angewandt.
- `filter-setup` enthält „Tatsächliche Spülmenge“ / „Actual purge amount“ in g (0–50 g).
  Ein Totraumvorschlag kann das Feld vorbelegen, ist aber noch kein bestätigter Verbrauch.
  `filter-finish` zeigt die tatsächlich verwendete Menge erneut editierbar sowie
  „Verbrauch bestätigen: {dose} g + {purge} g“ / „Confirm consumption: {dose} g + {purge} g“.
  Erst „Speichern und Verbrauch bestätigen“ / „Save and confirm consumption“ bucht
  `doseG + purgeG` atomar und genau einmal; bis dahin bucht der Entwurf nichts.
  Beispiel: 20 g Dosis, Vorschlag 2.5 g, bestätigt 1 g → 21 g Bestandsabzug.
  Abbruch nach physischem Verbrauch bietet weiter den bestätigten ConsumptionEvent-Weg.
- `water-detail`: für jeden der sechs Parameter Label; gemessen → Wertbalken, Referenz,
  Quelle und Status, ungemessen → nur „nicht gemessen“ / „not measured“, kein Messwertbalken.
  Diese Darstellung ist zugleich die verbindliche LF9-Auslegung für Screenshots.

Für jede folgende Route gilt die Composition oben plus die konkreten Elemente hier. Desktop per Seitenleiste, Phone per gleichnamigem Bottom-Ziel bzw.
Mehr → Wasser/Pflege/Einstellungen; Unterseiten per Karten/Aktionen. System-Zurück führt zum übergeordneten Screen; ungespeicherte Änderungen mit
„Änderungen verwerfen?“ / „Discard changes?“ bestätigen. Formulare kompakt einspaltig (max. 640 dp), Listen mittlere Dichte (88-dp-Karten), Details
max. 960 dp. Primär genau eine gefüllte Aktion. Sekundär „Abbrechen“ / „Cancel“ bzw. „Zurück“ / „Back“. Form-Empty zeigt weiterhin alle beschrifteten
Felder und deaktiviertes Speichern, kein dekorativer Empty-State statt des Formulars. Mehr und Einstellungen sind immer bedienbar, auch ohne
Datensätze. Nicht gefundene IDs zeigen den angegebenen Fehlerzustand statt Absturz.

- **today** `/` : Heute / Today. Warnungen vor bereiten Bohnen und letzter Brühung. Banner öffnen Detail bzw. Pflege; Bohnenkarte öffnet Bohnendetail.
  Primär „Neue Brühung“ / „New brew“ → `brew-new` . Leer/fehlend: „Noch nichts da“ / „Nothing here yet“, „Erfasse die Angaben, um fortzufahren.“ /
  „Enter the details to continue.“; Aktion „Bohne hinzufügen“ / „Add bean“ → `bean-new` .
- **beans** `/beans` : Bohnen / Beans. Karten mit Röster, Bereitschaft, Restgramm, Stock-Balken; Tippen öffnet Detail. Primär „Bohne hinzufügen“ /
  „Add bean“ → `bean-new` . Leer/fehlend: „Noch keine Bohnen“ / „No beans yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to
  continue.“; Aktion „Bohne hinzufügen“ / „Add bean“ → `bean-new` .
- **bean-detail** `/beans/:id` : Bohnendetail / Bean details. Kopfband, Rest 250 g, Reichweite, Bereit-Datum, Packungen. Öffnen setzt openedAt;
  Bearbeiten öffnet Bohnenformular, Archivieren erhält Historie. Primär „Packung hinzufügen“ / „Add pack“ → `pack-new` . Leer/fehlend: „Keine
  Packungen“ / „No packs“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Packung hinzufügen“ / „Add pack“ →
  `pack-new` .
- **bean-new** `/beans/new` : Bohne erfassen / Add bean. Einspaltig: Name, Röster, Röstgrad, Art, Lieferzeit, Mindestbestand; optional erste Packung.
  Bearbeiten nutzt /beans/:id/edit. Primär „Speichern“ / „Save“ → `bean-detail` . Leer/fehlend: „Noch keine Eingaben“ / „No values yet“, „Erfasse die
  Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Abbrechen“ / „Cancel“ → `beans` .
- **pack-new** `/beans/:id/packs/new` : Packung erfassen / Add pack. Röstdatum, Gewicht, Rest (bei Anlage gleich Gewicht), geöffnet-Datum optional.
  Pflichtdatum fehlt → Feldfehler; Abbrechen verwirft. Primär „Speichern“ / „Save“ → `bean-detail` . Leer/fehlend: „Noch keine Eingaben“ / „No values
  yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Abbrechen“ / „Cancel“ → `bean-detail` .
- **brews** `/brews` : Brühungen / Brews. Neueste zuerst; Methode, Bohne, Zeit, Bewertung. Sekundär Filter starten → filter-setup; Karte öffnet
  Brühdetail. Primär „Brühung erfassen“ / „Log a brew“ → `brew-new` . Leer/fehlend: „Noch keine Brühungen“ / „No brews yet“, „Erfasse die Angaben, um
  fortzufahren.“ / „Enter the details to continue.“; Aktion „Brühung erfassen“ / „Log a brew“ → `brew-new` .
- **brew-new** `/brews/new` : Brühung erfassen / Log a brew. Maschine, Mühle, Packung, Raster-Mahlgrad, Dosis, Spülmenge, Ausbeute,
  Wassertemperatur/Profil, Timer, Geschmack, Sterne, Notiz. Timer starten/stoppen misst ab Pumpenstart inkl. Preinfusion. Primär „Speichern“ / „Save“
  → `brew-detail` . Leer/fehlend: „Zuerst eine Mühle anlegen“ / „Add a grinder first“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to
  continue.“; Aktion „Mühle hinzufügen“ / „Add grinder“ → `grinder-form` .
- **brew-detail** `/brews/:id` : Brühungsdetail / Brew details. Zweispaltige Kennzahlen mit eingefrorenen Parametern; genau eine Empfehlung samt Grund
  und Quelle. Nächster Versuch übernimmt Parameter plus Vorschlag; Geschmack, Zeit und Bewertung leer. Primär „Nächster Versuch“ / „Next try“ →
  `brew-new` . Leer/fehlend: „Brühung nicht gefunden“ / „Brew not found“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“;
  Aktion „Zu Brühungen“ / „Back to brews“ → `brews` .
- **filter-setup** `/filter` : Filter vorbereiten / Filter setup. Methode, Mühle/Raster, bereite Packung, Wasser, Dosis, Verhältnis, Gesamtsumme und
  Plan. Blend-Backups hinter anderen; keine fertige Packung → Start deaktiviert. Primär „Starten“ / „Start“ → `filter-focus` . Leer/fehlend: „Keine
  bereite Packung“ / „No ready pack“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Zu Bohnen“ / „Go to beans“ →
  `beans` .
- **filter-focus** `/filter/focus` : Filter geführt / Guided filter. Vollbild: Timer 00:45, Ziel 120 g, zusätzlich jetzt 80 g; nächster Schritt mit
  Zeit. Weiter bestätigt Schritt, letzter Schritt → Finish. Abbrechen fragt nach bereits verbrauchtem Kaffee. Primär „Weiter“ / „Next“ →
  `filter-finish` . Leer/fehlend: „Keine laufende Brühung“ / „No active brew“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to
  continue.“; Aktion „Filter vorbereiten“ / „Set up filter“ → `filter-setup` .
- **filter-finish** `/filter/finish` : Filter abschliessen / Finish filter. Gesamtzeit 200 s, Geschmack, Bewertung; Speichern bucht Dosis und
  bestätigten Purge genau einmal, öffnet Detail. Zurück erhält Entwurf. Primär „Speichern“ / „Save“ → `brew-detail` . Leer/fehlend: „Keine laufende
  Brühung“ / „No active brew“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Filter vorbereiten“ / „Set up
  filter“ → `filter-setup` .
- **equipment** `/equipment` : Ausrüstung / Equipment. Tabs Mühlen/Maschinen; im Maschinen-Tab primär Maschine hinzufügen. Karten mit Skalenbogen oder
  Pflegering; Karte öffnet Bearbeiten. Primär „Mühle hinzufügen“ / „Add grinder“ → `grinder-form` . Leer/fehlend: „Noch keine Ausrüstung“ / „No
  equipment yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Mühle hinzufügen“ / „Add grinder“ →
  `grinder-form` .
- **grinder-form** `/equipment/grinders/new` : Mühle erfassen / Add grinder. Name, Typ, Skalen-Min/Max/Schritt/Richtung, Totraum; Bearbeiten
  /equipment/grinders/:id/edit. Kein gerätefremder Mahlgraddefault, Wert muss auf Raster liegen. Primär „Speichern“ / „Save“ → `equipment` .
  Leer/fehlend: „Noch keine Eingaben“ / „No values yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion
  „Abbrechen“ / „Cancel“ → `equipment` .
- **machine-form** `/equipment/machines/new` : Maschine erfassen / Add machine. Name, Temperatur, Preinfusion, Druckprofil, Standardwasser;
  Backflush-Eignung und Pflegegrenzen unter Erweitert. Bearbeiten /equipment/machines/:id/edit. Primär „Speichern“ / „Save“ → `equipment` .
  Leer/fehlend: „Noch keine Eingaben“ / „No values yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion
  „Abbrechen“ / „Cancel“ → `equipment` .
- **water** `/water` : Wasser / Water. Karten: Profilname, Härte, Status und n/6 gemessen. Tippen öffnet Messwertdetail. Primär „Wasserprofil
  hinzufügen“ / „Add water profile“ → `water-form` . Leer/fehlend: „Noch kein Wasserprofil“ / „No water profile yet“, „Erfasse die Angaben, um
  fortzufahren.“ / „Enter the details to continue.“; Aktion „Wasserprofil hinzufügen“ / „Add water profile“ → `water-form` .
- **water-detail** `/water/:id` : Wasserdetail / Water details. Sechs Parameter-Balken mit Wert, Grenzen, Status, Quelle und Datum; nicht gemessene
  Parameter mit Text statt Balken. Kein Trinkbarkeitsurteil. Primär „Bearbeiten“ / „Edit“ → `water-form` . Leer/fehlend: „Wasserprofil nicht gefunden“
  / „Water profile not found“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Zu Wasser“ / „Back to water“ →
  `water` .
- **water-form** `/water/new` : Wasserprofil erfassen / Add water profile. Name, Härte mit Einheit-Umschalter, optionale
  Alkalinität/TDS/pH/Natrium/Chlor; Bearbeiten /water/:id/edit. Wechsel der Einheit erhält ppm-Wert. Primär „Speichern“ / „Save“ → `water-detail` .
  Leer/fehlend: „Noch keine Eingaben“ / „No values yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion
  „Abbrechen“ / „Cancel“ → `water` .
- **care** `/care` : Pflege / Care. Aufgaben gruppiert pro Gerät nach Fälligkeit. Zeigt Tage/Shots/Sekunden; Erledigt bestätigt Ereignis und setzt nur
  diese Aufgabe zurück. Grenzen bearbeiten im Geräteformular. Primär „Erledigt“ / „Done“ → `care` . Leer/fehlend: „Nichts zu pflegen“ / „Nothing to
  maintain“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the details to continue.“; Aktion „Maschine hinzufügen“ / „Add machine“ → `machine-form`
  .
- **more** `/more` : Mehr / More. Kompakte Navigationsliste Wasser, Pflege, Einstellungen; jede Zeile öffnet das entsprechende Ziel. Desktop nutzt
  direkte Seitenleiste. Primär „Wasser“ / „Water“ → `water` . Leer/fehlend: „Navigation verfügbar“ / „Navigation available“, „Erfasse die Angaben, um
  fortzufahren.“ / „Enter the details to continue.“; Aktion „Wasser“ / „Water“ → `water` .
- **settings** `/settings` : Einstellungen / Settings. Härteeinheit, Systemtheme-Vorschau, Importieren (Dateiauswahl), Quellen. Export
  teilt/downloadet JSON; Import zeigt hinzugefügt/ersetzt/übersprungen oder Fehler. Quellen öffnen Browser erst nach Tippen. Primär „Exportieren“ /
  „Export“ → `settings` . Leer/fehlend: „Noch keine eigenen Daten“ / „No personal data yet“, „Erfasse die Angaben, um fortzufahren.“ / „Enter the
  details to continue.“; Aktion „Exportieren“ / „Export“ → `settings` .
