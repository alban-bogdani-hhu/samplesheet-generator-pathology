# Installation Guide — SampleSheet Generator (WES, Pathology)

This is a **one-time setup** per computer. After it, the app is started as
described in **`USER_GUIDE.md`**.

The app runs locally on a Windows PC. It does **not** need an internet
connection to run — all required software packages are included in the
delivered folder.

---

## Prerequisites (installed once, by IT or by the user if permitted)

1. **R, version 4.6.x** — this specific version is required.
   Download: <https://cran.r-project.org/bin/windows/base/>
2. **RStudio Desktop** (free).
   Download: <https://posit.co/download/rstudio-desktop/>

> The R version matters. The app was built and tested with **R 4.6**. A
> different major/minor version (e.g. 4.5) may cause package problems. If in
> doubt, install R 4.6.x.

---

## Installation steps

1. **Unzip** the delivered file
   `samplesheet-generator-pathology_R1.zip` to a local folder
   (for example the Desktop). Do not run it from inside the zip.

2. Open the unzipped folder and **double-click**
   **`samplesheet-generator-pathology.Rproj`**.
   RStudio opens with the project loaded.

   > Always open the project via the **`.Rproj`** file. Double-clicking
   > `app.R` directly can open it in the wrong program (e.g. a plain text
   > editor) where it will not run.

3. In RStudio, open **`app.R`** from the file list (top-left) and click
   **Run App** (top-right of the editor).

4. The app opens in a window. Installation is complete.

> When the project opens, RStudio may show a short `renv` message
> (for example "renv activated" or a note about the project library).
> **This is normal.** As long as the app starts when you click **Run App**,
> everything is working.

---

## Verify the installation (with fake data)

Do a quick test with an invented sample — **do not use real patient data for
this check**:

1. In the app, type a fake Sample_ID such as `1234-26_3-N`.
2. Pick any index and click **Probe hinzufügen**.
3. The check panel should turn green ("Keine Probleme gefunden").
4. Click **SampleSheet exportieren** and save the file.
5. Confirm a file `1234-26_3-samplesheet.csv` (or similar) was created and
   opens.

If all five steps work, the app is correctly installed on this machine.

---

## Troubleshooting

**The app will not start, or RStudio reports missing packages.**
In the RStudio console (bottom-left), type:

```r
renv::restore()
```

Press Enter and wait for it to finish, then try **Run App** again.
(In normal use this is not needed — the packages are already included — but it
repairs the library if something did not unzip correctly.)

**Still not working, or any other problem.**
Contact **Kai Horny**.

---
---

# Installationsanleitung — SampleSheet Generator (WES, Pathologie)

Dies ist eine **einmalige Einrichtung** pro Rechner. Danach wird die App wie in
**`USER_GUIDE.md`** beschrieben gestartet.

Die App läuft lokal auf einem Windows-PC. Sie benötigt zum Ausführen **keine**
Internetverbindung — alle benötigten Software-Pakete sind im gelieferten Ordner
enthalten.

---

## Voraussetzungen (einmalig, durch IT oder durch die Nutzer, falls erlaubt)

1. **R, Version 4.6.x** — genau diese Version wird benötigt.
   Download: <https://cran.r-project.org/bin/windows/base/>
2. **RStudio Desktop** (kostenlos).
   Download: <https://posit.co/download/rstudio-desktop/>

> Die R-Version ist wichtig. Die App wurde mit **R 4.6** erstellt und getestet.
> Eine andere Haupt-/Nebenversion (z. B. 4.5) kann zu Paketproblemen führen.
> Im Zweifel R 4.6.x installieren.

---

## Installationsschritte

1. **Entpacken** Sie die gelieferte Datei
   `samplesheet-generator-pathology_R1.zip` in einen lokalen Ordner
   (zum Beispiel den Desktop). Nicht direkt aus der ZIP-Datei starten.

2. Öffnen Sie den entpackten Ordner und **doppelklicken** Sie auf
   **`samplesheet-generator-pathology.Rproj`**.
   RStudio öffnet sich mit dem geladenen Projekt.

   > Öffnen Sie das Projekt immer über die **`.Rproj`**-Datei. Ein direkter
   > Doppelklick auf `app.R` kann die Datei im falschen Programm öffnen
   > (z. B. einem einfachen Texteditor), in dem sie nicht läuft.

3. Öffnen Sie in RStudio die Datei **`app.R`** aus der Dateiliste (oben links)
   und klicken Sie auf **Run App** (oben rechts im Editor).

4. Die App öffnet sich in einem Fenster. Die Installation ist abgeschlossen.

> Beim Öffnen des Projekts zeigt RStudio eventuell eine kurze `renv`-Meldung
> (z. B. "renv activated" oder einen Hinweis zur Projektbibliothek).
> **Das ist normal.** Solange die App nach dem Klick auf **Run App** startet,
> funktioniert alles.

---

## Installation prüfen (mit Testdaten)

Führen Sie einen kurzen Test mit einer erfundenen Probe durch — **verwenden Sie
für diese Prüfung keine echten Patientendaten**:

1. Geben Sie in der App eine fiktive Sample_ID wie `1234-26_3-N` ein.
2. Wählen Sie einen beliebigen Index und klicken Sie auf **Probe hinzufügen**.
3. Der Prüfungsbereich sollte grün werden ("Keine Probleme gefunden").
4. Klicken Sie auf **SampleSheet exportieren** und speichern Sie die Datei.
5. Prüfen Sie, dass eine Datei `1234-26_3-samplesheet.csv` (oder ähnlich)
   erstellt wurde und sich öffnen lässt.

Funktionieren alle fünf Schritte, ist die App auf diesem Rechner korrekt
installiert.

---

## Fehlerbehebung

**Die App startet nicht, oder RStudio meldet fehlende Pakete.**
Geben Sie in der RStudio-Konsole (unten links) ein:

```r
renv::restore()
```

Drücken Sie Enter, warten Sie, bis der Vorgang abgeschlossen ist, und klicken
Sie erneut auf **Run App**. (Im Normalbetrieb ist das nicht nötig — die Pakete
sind bereits enthalten — aber es repariert die Bibliothek, falls beim Entpacken
etwas nicht korrekt übernommen wurde.)

**Funktioniert weiterhin nicht, oder anderes Problem.**
Wenden Sie sich an **Kai Horny**.