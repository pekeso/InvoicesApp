# Invoices and Estimates Extension

The extension Invoices and Estimates allow you to create, edit, print and manages estimates and invoices with [Banana Accounting+](https://www.banana.ch).

## Introduction

This extention is available in all plans of Banana Accounting+.
Some feautures, like item discount or custom fields, are available only within the advanced plan.

![Main dialog](./doc/images/application_invoice_edit_2.png)


## Repository structure

```
doc/                            Documentation

src/                            Source code

    main.js                     Main file that implement the JsAction interface

    changelog.md                Cronology of modifications

    ch.banana.application.invoice.default.manifest.json
                                Manifest of the extension

    ch.banana.application.invoice.default.qrc
                                Qrc file for the creation of the extension's package

    invoice-app.pro             Project file for Qt Creator

    base/                       Js code

    ui/                         Dialogs and widgets

        DlgInvoice.qml          Main dialog

        components/             Ui components

            Stylesheet.qml      Ui Stylesheet

            ...

    translations/               Translations

test/                           Tests
```

## Resources

* [Banana.ch - Estimates and Invocies user documentation](https://www.banana.ch/doc/en/node/9752)  
* [Banana.ch - Estimates and Incoices extension page](https://www.banana.ch/apps/en/node/9411)  
* [Banana.ch - Javascript API documentation](https://www.banana.ch/doc/en/node/4714)  
* [Banana.ch - Invoice Json Object documentation](https://www.banana.ch/doc/en/node/8833)  
* [Banana.ch - DocumentChange API documentation](https://www.banana.ch/doc/en/node/9641)  
* [Banana.ch - JsAction API documentation](...)  
