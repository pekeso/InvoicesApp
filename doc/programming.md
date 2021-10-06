# Programming conventions

## Introduction

### Qt e QML

* Installare Qt
* Leggere il tutorial QML https://doc.qt.io/qt-5/qml-tutorial.html
* Aprire compilare ed eseguire alcuni esempi in QtCreator, tra cui: 
   * Qt Quick Demo - QtockQt

### Coding conventions

Di regola quelle di default in Qt.

Più precismente:

* Ident di 4 spazi
* Spazi al posto dei tabulatori
* Apertura parentesi graffa sulla stessa riga degli 'if', definizione delle funzioni, ...
* Apertura parentesi graffa su una nuova riga per la dichirazione delle classi e dei namespaces
* Seguire il camel case di default del linguaggio

### Comments

Inserire tutti i commenti e le note che potrebbero essere utili a chi va a riprendere il codice fra qualche mese o qualche anno.

In particolare:

* Tutto quello che non rispecchierebbe la soluzione standard
* Dove c'è stato un certo ragionamente nella scelta di più opzioni
* Dove la soluzione è stata trovata tramite prove e non tramite la documentazione di Qt
* Dove il codice è stato modificato per aggirare un errore di Qt o del framework dell'applicazione

### Tests

Dove possibile e sensato implementare dei tests.

La nostra filosofia, se cambio una riga di codice, tramite i tests devo potermi sentire sicuro che tutto il resto dell'applicazione funziona correttamente.

## Applicazione Banana Invoice

* Installare Banana Accounting Internal
* Riprendere il repository https://github.com/BananaInternal/invoices-application
* Aprire in Banana il file invoices-application/test/testcases/invoices-examples.ac2




