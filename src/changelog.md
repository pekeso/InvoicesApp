# Changelog
 
## 2021-10-28

* [Bug] Fix tab key on field item quantity does not save the edited text

## 2021-10-20

* [Bug] Fix textes and translations

## 2021-10-13 [Beta1]

### Main changes

* [Enhancement] Add in the items the discount column (require advanced plan)
* [Enhancement] Add in the items the date column (require advanced plan)
* [Enhancement] Let insert items quantity and unit price with 4 or more decimals
* [Enhancement] Let insert multi line text in the item's description
* [Enhancement] Let insert multi line text in the invoice's begin text
* [Enhancement] Let choose which invoice's fields are visibles
* [Enhancement] Let choose which item's columns are visibles
* [Enhancement] Let insert bold text in item's description, invoice's begin text and invoice's end text
* [Enhancement] Let set the title for new invoices and estimates
* [Enhancement] Add views to the dialog
* [Bug] Resolves an issue where text changes sometimes were not applied if the enter key was not pressed
* [Bug] Resolves an issue related to clipped text fields on hdpi monitors under window

### Other changes

* [Enhancement] Add address fields Postbox and Extra
* [Enhancement] Add address fields Postbox and Extra
* [Enhancement] Add smart fill to the customer language column
* [Enhancement] Add in the edit invoice dialog the languages spanish, portuguese, russia, dutch and chinese
* [Enhancement] Add in the edit invoice dialog all the languages present in the customer table (user defined languages)
* [Enhancement] Add help button to dialogs;
* [Enhancement] In the edit invoice dialog the width of invoice details fields grows with the widht of the dialog;
* [Enhancement] In the edit invoice dialog the height of invoice articles a grows with the height of the dialog;
* [Enhancement] The dimension of the invoice dialog is saved and restored at the next opening (require the last version of Banana Accounting);
* [Enhancement] Support dynamic switch to dark mode
* [Enhancement] Add the invoice / estimate total to the dialog's top right corner
* [Bug] Fix textes and translations

### To do [Beta2]

* [Enhancement] Simplify the search of customers and articles
* [Enhancement] Allow to add customer fields to the invoice
* [Enhancement] Allow to print remainders
* [Enhancement] Allow to print delivery note
* [Enhancement] Add status to the invoice (draft, sent, remainder1, canceled, ...)
* [Enhancement] Allow to to insert totals and subtotals of items


## 2021-08-24

* [Bug] Fix under macOs dark mode item's texts are not visible;

## 2021-03-16

* [Bug] Prints amounts for items without price (0.00) but with quantity

## 2021-02-03

* [Enhancement] Doesn't prints amounts for items used as notes (items without price)

## 2021-01-18

* [Bug] Fix error invoiceObj is not defined in command duplicate;

## 2021-01-13

* [Bug] Fix translations errors;

## 2020-12-01

* [Enhancement] Add fields for deposit's amount and deposit's description;

## 2020-11-26

* [Bug] Fix changing invoice's notes in the dialog will not update the Note's field in the invoice's table;
* [Bug] Fix creating a new invoice doesn't set the expiring date;

## 2020-11-18

* [Bug] Fix when adding an item to the invoice, the item's price is set to amount_vat_exclusive or amount_vat_inclusive depending on invoice's settings;

## 2020-10-27

* [Enhancement] Add copy and paste of invoice's rows;

