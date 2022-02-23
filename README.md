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

    CMakeLists.txt              Project file for building the sbaa package and update the translations

    changelog.md                Cronology of modifications

    ch.banana.application.invoice.default.manifest.json
                                Manifest of the extension

    ch.banana.application.invoice.default.qrc
                                Qrc file for the creation of the extension's package

    main.js                     Main file that implement the JsAction interface

    base/                       Js code

    ui/                         Dialogs and widgets

        DlgInvoice.qml          Main dialog

        components/             Ui components

            Stylesheet.qml      Ui Stylesheet

            ...

    translations/               Translations

test/                           Tests
```

## Branches

* main: this branch correspond to the stable release
* beta: this branch correspond to the beta release
* develop: this branch correspond to the develop release

All other branches are used internally for developping and testing of new functionalities.

## Resources

* [Banana.ch - Estimates and Invoices user documentation](https://www.banana.ch/doc/en/node/9752)  
* [Banana.ch - Estimates and Invoices extension page](https://www.banana.ch/apps/en/node/9411)  
* [Banana.ch - Js API documentation](https://www.banana.ch/doc/en/node/4714)  
* [Banana.ch - Invoice Json Object documentation](https://www.banana.ch/doc/en/node/8833)  
* [Banana.ch - DocumentChange API documentation](https://www.banana.ch/doc/en/node/9641)  
* [Banana.ch - JsAction API documentation](...)  
