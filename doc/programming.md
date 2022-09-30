# Programming

This page explain you what you need to create and use a custom estimates and invoices extension. We encourage to start by forking the repository and doing some small changes, befor you start with a whole reprogramming of the extension.

## Introduction

### Requirements

* Last version of [Banana Accounting+](https://www.banana.ch/en/download) or [Banana Accounting+ Dev Channel](https://www.banana.ch/en/insiderprogram)
* A valid [Advanced Plan subscription](https://www.banana.ch/en/buy)
* A fork of this repository
* The last version of [Qt](https://www.qt.io/home)

### For newbies

If you have never created a Banana Extension or you have never used Qt, we suggest you take a look at the following tutorials:

* [Qt - QML tutorial](https://doc.qt.io/qt-5/qml-tutorial.html)
* [Banana.ch - Build your first Extension](https://www.banana.ch/doc/en/node/9324)
* Create a new Estimates and Invoces file, and creates new invoices

### Frameworks and API

The following frameworks and API are used in this project:

* [Banana.ch - Js API documentation](https://www.banana.ch/doc/en/node/4714)  
* [Banana.ch - Invoice Json Object documentation](https://www.banana.ch/doc/en/node/8833)  
* [Banana.ch - DocumentChange API documentation](https://www.banana.ch/doc/en/node/9641)  
* [Banana.ch - JsAction API documentation](...)  

### Programming conventions

We use the [Qt Coding Style](https://wiki.qt.io/Qt_Coding_Style).

More precisely:

* Identation with 4 spaces
* Spaces instead of tabulators
* Opening braces on the same line of 'if', function definition, ...
* Opening braces on the next line for class definition and namespaces
* Camel case for function, class and variables names
* Undrscores for json property names

### Comments

As best rule insert all comments and notes that could be useful to the programmers who will go to resume the code in a few months or a few years.

More precisely:

* Anything that wouldn't reflect a standard solution
* Where there was some reasoning in choosing between multiple options
* Where the solution was found through trials and not through the documentation
* Where the code has been modified to bypass a framework or api error
* Where I spent a lot of time to find a solution

## Developement

## Environment

To devlop the Estimate and Invoices extension you need the following tools:

* BananaPlus installed on you PC
* A valid advanced plan subscription for BananaPlus
* [Qt 6.4.0](www.qt.io) or newer installed on your PC

## First steps

* Clone the [Repository InvoiceApp](https://github.com/BananaAccounting/InvoicesApp) on your pc
* Open in Qt Creator the file InvoicesApp/src/CMakeLists.txt
* Modify the source code of the extension
  * For example you can modify the file ch.banana.application.invoice.default.sbaa/ui/DlgInvoice.aml adding a label in the upper part of the dialog
* In Qt Creator build the project InvoiceApp
* In BananaPlus go to the Manage extensions dialog
  * Disable the installed InvoiceApp
  * Add the local InvoiceApp InvoiceApp/src/ch.banana.application.invoice.default.sbaa to the extensions
* Open an invoice and test your modifications

### Translations

To update the translations:

* In Qt Creator build the target InvoiceApp/lpudate
* Open the files *.tx with Qt Linguist
* Insert the translations
* Build the project InvoiceApp

### Tests

Where possible and sensible implement tests.

Our philosophy, before changing the code, check that a corresponding test function is implemented, if not insert it.  
If I change a line of code, through the tests I must be able to feel sure that all the rest of the application works correctly.
