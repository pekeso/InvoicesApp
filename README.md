# Applicazione Offerte e Fatture

L'applicazione Offerte e fatture permette la creazione, la stmapa e la gestione di offerte e fatture.

## Introduzione

L'applicazione Offerte e fatture è disponibile in tutte le versioni di BananaPlus.

Aprendo un documento di tipo Offerte e Fatture in Banana Contabilità apparirà il menu Fatture (Invoices) dal quale
saranno disponibili diversi comandi per la creazione, modifica, stampa e altro ancora di offerte e fatture.

## Struttura del repository

```
src/  
    main.js             Il file principale che definisce l'estensione
                        Implementa l'interfaccia JsAction

    changelog.md        Cronologia delle modifiche all'estensione

    ch.banana.application.invoice.default.manifest.json
                        Manifesto per la descrizione dell'estensione

    ch.banana.application.invoice.default.qrc
                        File qrc per la creazione del pacchetto

    invoice-app.pro     Progetto Qt Creator (facilitare l'editing dell'estensione in Qt Creator)

    ui/                 Contiene i dialoghi dell'estensione

    ui/components/      Contiene i widgets comuni usati nei dialoghi

    translations/       Contiene le traduzioni

test/                   Contiene i tests dell'estensione
```

## API

L'estensione implementa la API definita nella classe [JsBanana](http://strawberry.parsec5.local/git/banana.ch/bananaX/src/branch/master/src/banapp/scripts/jsaction.md) di Banana Accounting.

