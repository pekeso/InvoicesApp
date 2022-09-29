// Copyright [2021] [Banana.ch SA - Lugano Switzerland]
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import QtQuick 2.15
import QtQuick.Controls 1.4 as QuickControls14
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "."
import "./components"

import "../base/utils.js" as Utils
import "../base/invoice.js" as Invoice
import "../base/contacts.js" as Contacts
import "../base/items.js" as Items
import "../base/settings.js" as Settings
import "../base/vatcodes.js" as VatCodes

Item {
    id: window

    property bool isVatModeVatNone: false
    property bool isVatModeVatInclusive : true

    property int currentInvoiceItemRow : -1
    property string currentInvoiceItemCol : ""

    required property AppSettings appSettings
    required property Invoice invoice

    property string currentView: appSettings.data.interface.invoice.current_view ?
                                     appSettings.data.interface.invoice.current_view :
                                     appSettings.view_id_base

    onCurrentViewChanged: {
        invoiceItemsTable.updateColumnsWidths()
    }

    function createInvoiceFromEstimate() {
        if (invoice.isModified) {
            invoice.save()
        }
        invoice.setType(invoice.type_invoice)
        invoice.json = Invoice.invoiceCreateFromEstimateObj(invoice.json)
        invoice.tabPos.tableName = "Invoices"
        invoice.tabPos.rowNr = Banana.document.table("Invoices").rowCount

        invoice.isNewDocument = true
        updateView()
        setDocumentModified()

        notificationPopUp.text = qsTr("Invoice created");
        notificationPopUp.visible = true
    }

    function duplicateInvoice() {
        if (invoice.isModified) {
            invoice.save()
        }
        invoice.setType(invoice.type_invoice)
        invoice.json = Invoice.invoiceDuplicateObj(invoice.json, invoice.tabPos)
        invoice.tabPos.rowNr = Banana.document.table(invoice.tabPos.tableName).rowCount

        invoice.isNewDocument = true
        updateView()
        setDocumentModified()

        notificationPopUp.text = invoice.isEstimate() ? qsTr("Estimate copied") : qsTr("Invoice copied");
        notificationPopUp.visible = true
    }

    function printInvoice() {
        if (appSettings.modified) {
            // We have to save the settings before printing
            // if not the changes to customs fields are not taken over
            appSettings.saveSettings()
        }

        if (invoice.isModified) {
            invoice.save()

            notificationPopUp.text = invoice.isEstimate() ? qsTr("Estimate saved") : qsTr("Invoice saved");
            notificationPopUp.visible = true
        }

        invoiceUpdateCustomFields()

        Invoice.invoicePrint(invoice.json);
    }

    Component.onCompleted: {
        loadLanguages()
        loadCurrencies()
        loadCustomerAddresses()
        loadItems()
        loadTaxRates()
    }

    ListModel {
        id: invoiceItemsModel
    }

    VatModesModel {
        id: vatModesModel
    }

    ListModel {
        id: taxRatesModel
    }

    ListModel {
        id: customerAddressesModel
    }

    ListModel {
        id: itemsModel
    }

    ListModel {
        id: languagesModel
    }

    ListModel {
        id: currenciesModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Stylesheet.defaultMargin
        spacing: Stylesheet.defaultMargin

        RowLayout { // Views bar
            spacing: 20 * Stylesheet.pixelScaleRatio

            StyledLabel{
                text: qsTr("Views:")
            }

            StyledLabel{
                property string viewId: appSettings.view_id_base
                text: appSettings.getViewTitle(viewId)
                visible: appSettings.isViewVisible(viewId)
                font.bold: currentView === viewId
                font.underline: currentView != viewId
                color: currentView === viewId ? Stylesheet.textColor : Stylesheet.linkColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentView = parent.viewId
                        appSettings.data.interface.invoice.current_view = parent.viewId
                    }
                    cursorShape: currentView === parent.viewId ? Qt.ArrowCursor : Qt.PointingHandCursor
                }
            }

            StyledLabel{
                property string viewId: appSettings.view_id_short
                text: appSettings.getViewTitle(viewId)
                visible: appSettings.isViewVisible(viewId)
                font.bold: currentView === viewId
                font.underline: currentView != viewId
                color: currentView === viewId ? Stylesheet.textColor : Stylesheet.linkColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentView = parent.viewId
                        appSettings.data.interface.invoice.current_view = parent.viewId
                    }
                    cursorShape: currentView === parent.viewId ? Qt.ArrowCursor : Qt.PointingHandCursor
                }
            }

            StyledLabel{
                property string viewId: appSettings.view_id_long
                text: appSettings.getViewTitle(viewId)
                visible: appSettings.isViewVisible(viewId)
                font.bold: currentView === viewId
                font.underline: currentView != viewId
                color: currentView === viewId ? Stylesheet.textColor : Stylesheet.linkColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentView = parent.viewId
                        appSettings.data.interface.invoice.current_view = parent.viewId
                    }
                    cursorShape: currentView === parent.viewId ? Qt.ArrowCursor : Qt.PointingHandCursor
                }
            }

            StyledLabel{
                property string viewId: appSettings.view_id_full
                text: appSettings.getDefaultViewTitle(viewId)
                font.bold: currentView === viewId
                font.underline: currentView != viewId
                color: currentView === viewId ? Stylesheet.textColor : Stylesheet.linkColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentView = parent.viewId
                        appSettings.data.interface.invoice.current_view = parent.viewId
                    }
                    cursorShape: currentView === parent.viewId ? Qt.ArrowCursor : Qt.PointingHandCursor
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledLabel {
                font.bold: true
                //Layout.minimumWidth: 320 * Stylesheet.pixelScaleRatio
                text: qsTr("Total") + (invoice.signalInvoiceChanged && invoice.json && invoice.json.document_info.currency ? " " + invoice.json.document_info.currency.toLocaleUpperCase() : "") +
                      " " + toLocaleNumberFormat(invoice.json ? invoice.json.billing_info.total_to_pay : "", true)
            }

        }

        ScrollView { // Invoice content
            id: scrollView
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Stylesheet.defaultMargin

            ColumnLayout {
                width: scrollView.availableWidth - scrollView.ScrollBar.vertical.width - Stylesheet.defaultMargin
                height: scrollView.availableHeight

                spacing: Stylesheet.defaultMargin

                GridLayout {  // Top part
                    columns: 3

                    GridLayout { // Invoice info
                        id: invoice_info
                        columns: 2

                        Layout.alignment:  Qt.AlignBottom
                        Layout.fillWidth: true

                        StyledLabel{
                            text: qsTr("Invoice No")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_number.visible
                        }

                        StyledTextField {
                            id: invoice_number
                            visible: focus || isInvoiceFieldVisible("show_invoice_number", text)
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            readOnly: invoice.isReadOnly
                            text: invoice.json && invoice.json.document_info.number ? invoice.json.document_info.number : "{invoice_no}"
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.number = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledLabel{
                            text: qsTr("Language")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_language.visible
                        }

                        StyledKeyDescrComboBox {
                            id: invoice_language
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            visible: isInvoiceFieldVisible("show_invoice_language")

                            editable: true
                            model: languagesModel
                            textRole: "descr"

                            Connections {
                                target: invoice
                                function onInvoiceChanged() {
                                    invoice_language.setCurrentKey(
                                                invoice.json && invoice.json.document_info.locale ?
                                                    invoice.json.document_info.locale : ""
                                                )
                                }
                            }

                            onCurrentKeySet: function(key, isExistingKey) {
                                setDocumentLocale(key)
                            }

                        }

                        StyledLabel{
                            text: qsTr("Currency")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_currency.visible
                        }

                        StyledKeyDescrComboBox {
                            id: invoice_currency
                            visible: isInvoiceFieldVisible("show_invoice_currency")
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            editable: true
                            enabled: !invoice.isReadOnly
                            model: currenciesModel
                            textRole: "key"

                            cleanKey: function(text) {
                                return text.trim().toUpperCase()
                            }

                            Connections {
                                target: invoice
                                function onInvoiceChanged() {
                                    invoice_currency.setCurrentKey(
                                                invoice.json && invoice.json.document_info.currency ?
                                                    invoice.json.document_info.currency : ""
                                                )
                                }
                            }

                            onCurrentKeySet: function(key, isExistingKey) {
                                invoice.json.document_info.currency = key
                                setDocumentModified()
                            }
                        }

                        StyledLabel{
                            text: qsTr("VAT mode")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_vat_mode.visible
                        }

                        StyledKeyDescrComboBox {
                            id: invoice_vat_mode
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            visible: isInvoiceFieldVisible("show_invoice_vat_mode")

                            editable: false
                            model: vatModesModel
                            textRole: "descr"
                            listItemTextIncludesKey: false

                            Connections {
                                target: invoice
                                function onInvoiceChanged() {
                                    if (invoice.json && invoice.json.document_info.vat_mode) {
                                        invoice_vat_mode.setCurrentKey(invoice.json.document_info.vat_mode)
                                    }
                                }
                            }

                            onCurrentKeySet: function(key, isExistingKey) {
                                invoice.setVatMode(key)
                                calculateInvoice()
                            }

                        }

                        StyledLabel{
                            text: qsTr("Invoice date")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_date.visible
                        }

                        StyledTextField {
                            id: invoice_date
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            visible: focus || isInvoiceFieldVisible("show_invoice_date", text)
                            property int updateText: 1 // Binding for updating the text

                            readOnly: invoice.isReadOnly
                            text: {
                                if (updateText && invoice.json && invoice.json.document_info.date) {
                                    var dateString = invoice.json.document_info.date.split('T')[0]
                                    Banana.Converter.toLocaleDateFormat(dateString)
                                } else {
                                    ""
                                }
                            }

                            onEditingFinished: {
                                if (modified) {
                                    // Check date
                                    let date = Banana.Converter.toInternalDateFormat(text)
                                    let localDate = Banana.Converter.toLocaleDateFormat(date)
                                    if (!localDate || localDate.length === 0) {
                                        errorMessageDialog.text = qsTr("Invalid date: " + text)
                                        errorMessageDialog.visible = true
                                        updateText++
                                        return
                                    }
                                    // Set date
                                    invoiceSetDate(invoice.json, date);
                                    invoice_due_date.update()
                                    setDocumentModified()
                                }
                            }
                            function getDate() {
                                if (updateText > 0) {
                                    if (invoice.json && invoice.json.document_info.date) {
                                        var dateString = invoice.json.document_info.date.split('T')[0]
                                        return Banana.Converter.toLocaleDateFormat(dateString)
                                    }
                                }
                                return ""

                            }
                        }

                        StyledLabel{
                            text: qsTr("Due date")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_due_date.visible
                        }

                        StyledTextField {
                            id: invoice_due_date
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            visible: focus || isInvoiceFieldVisible("show_invoice_due_date", text)

                            text: getDate()

                            onEditingFinished: {
                                if (modified) {
                                    // Check date
                                    let date = Banana.Converter.toInternalDateFormat(text)
                                    let localDate = Banana.Converter.toLocaleDateFormat(date)
                                    if (!localDate || localDate.length === 0) {
                                        errorMessageDialog.text = qsTr("Invalid date: " + text)
                                        errorMessageDialog.visible = true
                                        update()
                                        return
                                    }
                                    // Set date
                                    invoice.json.payment_info.due_date = date
                                    setDocumentModified()
                                }
                            }

                            function update() {
                                text = getDate()
                            }

                            function getDate() {
                                if (invoice.json && invoice.json.payment_info.due_date) {
                                    var date = invoice.json.payment_info.due_date.split('T')[0]
                                    return Banana.Converter.toLocaleDateFormat(date)
                                } else {
                                    return ""
                                }
                            }
                        }

                        StyledLabel{
                            text: qsTr("Order No")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_order_no.visible
                        }

                        StyledTextField {
                            id: invoice_order_no
                            visible: focus || isInvoiceFieldVisible("show_invoice_order_number", text)
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            readOnly: invoice.isReadOnly
                            text: invoice.json && invoice.json.document_info.order_number ? invoice.json.document_info.order_number : ""
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.order_number = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledLabel{
                            text: qsTr("Order date")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_order_date.visible
                        }

                        StyledTextField {
                            id: invoice_order_date
                            visible: focus || isInvoiceFieldVisible("show_invoice_order_date", text)
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            readOnly: invoice.isReadOnly
                            text: invoice.json && invoice.json.document_info.order_date ? toLocaleDateTimeFormat(invoice.json.document_info.order_date) : ""
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.order_date = toInternalDateTimeFormat(text)
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledLabel{
                            Layout.columnSpan: 2
                            height: Stylesheet.defaultMargin
                            visible: invoice_decimal_amounts.visible || invoice_rounding_total.visible
                        }

                        StyledLabel{
                            text: qsTr("Decimal points")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_decimal_amounts.visible
                        }

                        StyledTextField {
                            id: invoice_decimal_amounts
                            visible: focus || isInvoiceFieldVisible("show_invoice_decimals")
                            text: invoice.json && invoice.json.document_info.decimals_amounts ? invoice.json.document_info.decimals_amounts : ""
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio

                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.decimals_amounts = Number(text)
                                    setDocumentModified(true)
                                    calculateInvoice()
                                }
                            }
                        }

                        StyledLabel{
                            text: qsTr("Total rounding")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_rounding_total.visible
                        }

                        StyledTextField {
                            id: invoice_rounding_total
                            visible: focus || isInvoiceFieldVisible("show_invoice_rounding_totals")
                            text: invoice.json && invoice.json.document_info.rounding_total ?
                                      Banana.Converter.toLocaleNumberFormat(invoice.json.document_info.rounding_total) : ""
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio

                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.rounding_total =
                                            Banana.Converter.toInternalNumberFormat(text)
                                    wdgInvoice.setDocumentModified(true)
                                    wdgInvoice.calculateInvoice()
                                }
                            }
                        }

                        StyledLabel{
                            Layout.columnSpan: 2
                            height: Stylesheet.defaultMargin
                        }

                        StyledLabel{
                            text: qsTr("Customer ref.")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_customer_reference.visible
                        }

                        StyledTextField {
                            id: invoice_customer_reference
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_customer_reference", text)
                            readOnly: invoice.isReadOnly
                            text: invoice.json && invoice.json.document_info.customer_reference ? invoice.json.document_info.customer_reference : ""
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.customer_reference = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledLabel{
                            Layout.columnSpan: 2
                            height: Stylesheet.defaultMargin
                            visible: invoice_customer_reference.visible |
                                     invoice_custom_field_1.visible |
                                     invoice_custom_field_2.visible |
                                     invoice_custom_field_3.visible |
                                     invoice_custom_field_4.visible |
                                     invoice_custom_field_5.visible |
                                     invoice_custom_field_6.visible |
                                     invoice_custom_field_7.visible |
                                     invoice_custom_field_8.visible
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_1"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_1.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_1
                            property string customFieldId: "custom_field_1"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_1", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_1")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_1")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_2"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_2.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_2
                            property string customFieldId: "custom_field_2"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_2", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_2")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_1")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_3"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_3.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_3
                            property string customFieldId: "custom_field_3"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_3", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_3")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_3")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_4"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_4.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_4
                            property string customFieldId: "custom_field_4"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_4", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_4")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_4")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_5"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_5.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_5
                            property string customFieldId: "custom_field_5"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_5", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_5")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_5")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_6"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_6.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_6
                            property string customFieldId: "custom_field_6"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_6", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_6")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_6")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_7"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_7.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_7
                            property string customFieldId: "custom_field_7"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_7", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_7")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_7")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            property string trId: "invoice_custom_field_8"
                            text: appSettings.signalTranslationsChanged ?
                                      Settings.getTranslatedText(appSettings.data, trId, Banana.application.locale.substring(0, 2)) :
                                      trId
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_custom_field_8.visible
                        }

                        StyledTextField {
                            id: invoice_custom_field_8
                            property string customFieldId: "custom_field_8"
                            Layout.preferredWidth: 300 * Stylesheet.pixelScaleRatio
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_custom_field_8", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_8")
                            text: invoiceCustomFieldGet(invoice.json, customFieldId)
                            onEditingFinished: {
                                if (modified) {
                                    invoiceUpdateCustomFields();
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_custom_field_8")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledLabel{
                            Layout.columnSpan: 2
                            height: Stylesheet.defaultMargin
                            visible: invoice_customer_reference.visible |
                                     invoice_custom_field_1.visible |
                                     invoice_custom_field_2.visible |
                                     invoice_custom_field_3.visible |
                                     invoice_custom_field_4.visible |
                                     invoice_custom_field_5.visible |
                                     invoice_custom_field_6.visible |
                                     invoice_custom_field_7.visible |
                                     invoice_custom_field_8.visible
                        }

                        StyledLabel{
                            text: qsTr("Object")
                            horizontalAlignment: Text.AlignLeft
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: invoice_description.visible
                        }

                        StyledTextField {
                            id: invoice_description
                            readOnly: invoice.isReadOnly
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_title", text)
                            text: invoice.json && invoice.json.document_info.description ? invoice.json.document_info.description : ""
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.description = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledLabel{
                            text: qsTr("Begin text")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: ivoice_begin_text.visible
                        }

                        StyledTextArea {
                            id: ivoice_begin_text
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_begin_text", text)
                            text: invoice.json && invoice.json.document_info && invoice.json.document_info.text_begin
                                  ? invoice.json.document_info.text_begin  : ""

                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.document_info.text_begin = text
                                    setDocumentModified()
                                }
                            }

                            KeyNavigation.priority: KeyNavigation.BeforeItem
                            KeyNavigation.tab: ivoice_notes
                        }

                        StyledLabel{
                            text: qsTr("End text")
                            Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                            visible: ivoice_notes.visible
                        }

                        StyledTextArea {
                            id: ivoice_notes
                            Layout.fillWidth: true
                            visible: focus || isInvoiceFieldVisible("show_invoice_end_text", text)
                            text: invoice.json && invoice.json.note && invoice.json.note[0] &&
                                  invoice.json.note[0].description ? invoice.json.note[0].description : ""

                            onEditingFinished: {
                                if (modified) {
                                    var noteObj = {
                                        'date': null,
                                        'description': text
                                    }
                                    invoice.json.note = [noteObj]
                                    setDocumentModified()
                                }
                            }

                            KeyNavigation.priority: KeyNavigation.BeforeItem
                            KeyNavigation.tab: address_customer_selector
                        }
                    }

                    Item {
                        Layout.preferredWidth: 100 * Stylesheet.pixelScaleRatio
                    }

                    ColumnLayout { // Address
                        Layout.alignment: Qt.AlignTop

                        StyledLabel{
                            text: qsTr("Customer")
                            visible: address_customer_selector.visible
                        }

                        StyledKeyDescrComboBox {
                            id: address_customer_selector
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            visible: focus || isInvoiceFieldVisible("show_invoice_customer_selector")
                            popupMinWidth: 400  * Stylesheet.pixelScaleRatio
                            popupAlign: Qt.AlignRight

                            editable: true
                            model: customerAddressesModel
                            textRole: "descr"
                            filterEnabled: true
                            displayTextIncludesKey: true

                            Connections {
                                target: invoice
                                function onInvoiceChanged() {
                                    address_customer_selector.setCurrentKey(
                                                invoice.json && invoice.json.customer_info.number ?
                                                    invoice.json.customer_info.number : ""
                                                )
                                }
                            }

                            onCurrentKeySet: function(key, isExistingKey) {
                                if (isExistingKey) {
                                    var contactId = key
                                    invoice.json.customer_info = Contacts.contactAddressGet(contactId)
                                    invoice.json.customer_info.number = contactId
                                    setDocumentLocale(Contacts.contactLocaleGet(contactId))
                                    updateViewAddress()
                                } else {
                                    invoice.json.customer_info.number = ""
                                }
                                setDocumentModified()
                            }
                        }

                        StyledLabel{
                            id: addressLabel
                            text: qsTr("Address")
                            visible: address_business_name.visible || address_first_name.visible || address_last_name.visible
                        }

                        StyledTextField {
                            id: address_business_name
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_business", text)
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Business name")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.business_name = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledTextField {
                            id: address_business_unit
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_business_unit", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit")
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Business unit")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.business_unit = text
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledTextField {
                            id: address_business_unit_2
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_business_unit_2", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_2")
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Business unit 2")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.business_unit2 = text
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_2")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledTextField {
                            id: address_business_unit_3
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_business_unit_3", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_3")
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Business unit 3")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.business_unit3 = text
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_3")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledTextField {
                            id: address_business_unit_4
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_business_unit_4", text)
                            readOnly: invoice.isReadOnly || !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_4")
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Business unit 4")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.business_unit4 = text
                                    setDocumentModified()
                                }
                            }
                            onPressed: {
                                if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_address_business_unit_4")) {
                                    dlgLicense.visible = true
                                }
                            }
                        }

                        StyledTextField {
                            id: address_courtesy
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_courtesy", text)
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Prefix")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.courtesy = text
                                    setDocumentModified()
                                }
                            }
                        }

                        RowLayout {
                            StyledTextField {
                                id: address_first_name
                                Layout.preferredWidth: 158 * Stylesheet.pixelScaleRatio
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_first_and_last_name", text)
                                placeholderText: qsTr("First name")
                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.first_name = text
                                        setDocumentModified()
                                    }
                                }
                            }

                            StyledTextField {
                                id: address_last_name
                                Layout.preferredWidth: 158 * Stylesheet.pixelScaleRatio
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_first_and_last_name", text)
                                placeholderText: qsTr("Last name")
                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.last_name = text
                                        setDocumentModified()
                                    }
                                }
                            }
                        }

                        StyledTextField {
                            id: address_address1
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_street", text)
                            placeholderText: qsTr("Street")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.address1 = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledTextField {
                            id: address_address2
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_extra", text)
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("Extra")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.address2 = text
                                    setDocumentModified()
                                }
                            }
                        }

                        StyledTextField {
                            id: address_address3
                            visible: focus || isInvoiceFieldVisible("show_invoice_address_postbox", text)
                            Layout.preferredWidth: 320 * Stylesheet.pixelScaleRatio
                            placeholderText: qsTr("P.O.Box")
                            onEditingFinished: {
                                if (modified) {
                                    invoice.json.customer_info.address3 = text
                                    setDocumentModified()
                                }
                            }
                        }

                        RowLayout {
                            StyledTextField {
                                id: address_country_code
                                Layout.preferredWidth: 50 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("CC")
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Country code")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.country_code = text
                                        setDocumentModified()
                                    }
                                }
                            }

                            StyledLabel{
                                text: "-"
                            }

                            StyledTextField {
                                id: address_postal_code
                                Layout.preferredWidth: 60 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("Zip")
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Postal code")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.postal_code = text
                                        setDocumentModified()
                                    }
                                }
                            }

                            StyledTextField {
                                id: address_city
                                Layout.preferredWidth: 188 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("City")
                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.city = text
                                        setDocumentModified()
                                    }
                                }
                            }

                        }

                        RowLayout {
                            Layout.alignment:  Qt.AlignBottom
                            visible: address_email.visible || address_phone.visible

                            StyledTextField {
                                id: address_email
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_phone_and_email")
                                Layout.preferredWidth: 158 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("Email")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.email = text
                                        setDocumentModified()
                                    }
                                }
                            }

                            StyledTextField {
                                id: address_phone
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_phone_and_email")
                                Layout.preferredWidth: 157 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("Phone")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.phone = text
                                        setDocumentModified()
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.alignment:  Qt.AlignBottom
                            visible: address_vat_number.visible || address_fiscal_number.visible

                            StyledTextField {
                                id: address_vat_number
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_vat_and_fiscal_number", text)
                                Layout.preferredWidth: 158 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("VAT number")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.vat_number = text
                                        setDocumentModified()
                                    }
                                }
                            }

                            StyledTextField {
                                id: address_fiscal_number
                                visible: focus || isInvoiceFieldVisible("show_invoice_address_vat_and_fiscal_number", text)
                                Layout.preferredWidth: 157 * Stylesheet.pixelScaleRatio
                                placeholderText: qsTr("Fiscal number")

                                onEditingFinished: {
                                    if (modified) {
                                        invoice.json.customer_info.fiscal_number = text
                                        setDocumentModified()
                                    }
                                }
                            }
                        }

                    }
                }

                // Items
                QuickControls14.TableView {
                    // Items table
                    id: invoiceItemsTable
                    model: invoiceItemsModel

                    Layout.fillWidth: true
                    //Layout.fillHeight: true
                    Layout.minimumHeight: getTableHeigth()

                    selectionMode: QuickControls14.SelectionMode.NoSelection

                    verticalScrollBarPolicy: getMaxVisibleItems() === 0 ?
                                                 Qt.ScrollBarAlwaysOff :
                                                 Qt.ScrollBarAlwaysOn

                    property int signalUpdateRowHeights: 1
                    property int signalUpdateTableHeight: 1

                    QuickControls14.TableViewColumn {
                        id: itemRowNrColumn
                        role: "number"
                        title: qsTr("#")
                        width: getColumnWidth()
                        property int defaultWidth: 30 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignLeft;
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_row_number")
                        delegate: Item {
                            StyledTextField {
                                borderless: true
                                readOnly: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3
                                horizontalAlignment: styleData.textAlignment
                                text: styleData.row + 1
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_row_number", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_row_number", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemNumberColumn
                        role: "number"
                        title: qsTr("Item")
                        width: getColumnWidth()
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_number", role)
                        delegate: Item {
                            StyledKeyDescrComboBox {
                                id: invoiceItemComboBox
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: 3 * Stylesheet.pixelScaleRatio
                                anchors.rightMargin: 3 * Stylesheet.pixelScaleRatio
                                anchors.leftMargin: 3 * Stylesheet.pixelScaleRatio
                                popupMinWidth: 300 * Stylesheet.pixelScaleRatio

                                editable: true
                                model: itemsModel
                                textRole: "key"
                                filterEnabled: true

                                currentIndex: -1
                                displayText: {
                                    undoKey = styleData.value
                                    styleData.value
                                }

                                onCurrentKeySet: function(key, isExistingKey) {
                                    if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                        if (isExistingKey) {
                                            var itemId = key
                                            var vatExclusive = !isVatModeVatNone && !isVatModeVatInclusive
                                            var item = Items.itemGet(itemId, vatExclusive)
                                            if (item) {
                                                var vatCode = VatCodes.vatCodeGet(item.unit_price.vat_code)
                                                if (vatCode) {
                                                    item.unit_price.vat_rate = vatCode.rate
                                                } else {
                                                    // Fill with the default vat amount
                                                    let hasAmount = item.unit_price.amount_vat_inclusive ||
                                                        item.unit_price.amount_vat_exclusive;
                                                    if (hasAmount && !isVatModeVatNone && !item.unit_price.vat_rate) {
                                                        if (appSettings.data.new_documents.default_vat_code) {
                                                            item.unit_price.vat_code = appSettings.data.new_documents.default_vat_code
                                                            var defaultVatCode = VatCodes.vatCodeGet(item.unit_price.vat_code)
                                                            if (defaultVatCode) {
                                                                item.unit_price.vat_rate = defaultVatCode.rate
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                item = emptyInvoiceItem()
                                            }
                                            invoice.json.items[styleData.row] = item
                                            setDocumentModified()
                                            calculateInvoice()
                                        } else {
                                            invoice.json.items[styleData.row].number = key
                                            setDocumentModified()
                                        }
                                    }
                                }

                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_number", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_number", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemDateColumn
                        role: "date";
                        title: qsTr("Date");
                        width: getColumnWidth();
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignLeft;
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_date", role)
                        delegate: Item {
                            StyledTextField {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                property int updateText: 1  // Binding for updating the text
                                text: updateText && styleData.value ? Banana.Converter.toLocaleDateFormat(styleData.value) : ""
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                readOnly: !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_item_column_date")
                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            let date = text
                                            if (date) {
                                                date = Banana.Converter.toInternalDateFormat(date)
                                                // Check date
                                                let localDate = Banana.Converter.toLocaleDateFormat(date)
                                                if (!localDate || localDate.length === 0) {
                                                    errorMessageDialog.text = qsTr("Invalid date: " + text)
                                                    errorMessageDialog.visible = true
                                                    updateText++
                                                    modified = false
                                                    focus = false
                                                    return
                                                }
                                            }
                                            invoice.json.items[styleData.row].date = date
                                            invoiceItemsModel.setProperty(styleData.row, styleData.role, date)
                                        }
                                        setDocumentModified()
                                        modified = false
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                                onPressed: {
                                    if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_item_column_date")) {
                                        dlgLicense.visible = true
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_date", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_date", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemDescriptionColumn
                        role: "description"
                        title: qsTr("Description")
                        width: defaultWidth
                        property int defaultWidth: 220 * Stylesheet.pixelScaleRatio
                        delegate: Item {
                            StyledTextArea {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: styleData.value

                                Keys.onTabPressed: {
                                    // Steal key press, it is not nice because the navigation doesn't work but ...
                                    focus = false
                                    event.accepted = true;
                                }

                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            invoice.json.items[styleData.row].description = text
                                            invoiceItemsModel.setProperty(styleData.row, styleData.role, text)
                                        }
                                        setDocumentModified()
                                        modified = false
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }

                                // In case the lines count change we emit a signal to update the row heigth
                                property int textLinesCount: 1

                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                        textLinesCount = text.split('\n').length
                                    }
                                }

                                onTextChanged: {
                                    let newLinesCount = text.split('\n').length
                                    if (newLinesCount !== textLinesCount) {
                                        textLinesCount = newLinesCount
                                        // Save text to let calculate the right row height
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            invoice.json.items[styleData.row].description = text
                                        }
                                        // emit signal to update the row height
                                        ++invoiceItemsTable.signalUpdateRowHeights
                                    }
                                }
                            }
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemQuantityColumn
                        role: "quantity"
                        title: qsTr("Qty")
                        width: getColumnWidth()
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_quantity", role)
                        horizontalAlignment: Text.AlignRight;
                        delegate: Item {
                            StyledTextField {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: Banana.Converter.toLocaleNumberFormat(styleData.value)
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            let quantity = text ? Banana.Converter.toInternalNumberFormat(text) : ""
                                            invoice.json.items[styleData.row].quantity = quantity
                                            invoiceItemsModel.setProperty(styleData.row, styleData.role, quantity)
                                        }
                                        setDocumentModified()
                                        calculateInvoice()
                                        modified = false
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_quantity", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_quantity", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemUnitColumn
                        role: "mesure_unit"
                        title: qsTr("Unit")
                        width: getColumnWidth()
                        property int defaultWidth: 60 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignRight
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_unit", role)
                        delegate: Item {
                            StyledTextField {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: styleData.value
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            invoice.json.items[styleData.row].mesure_unit = text
                                            invoiceItemsModel.setProperty(styleData.row, styleData.role, text)
                                        }
                                        setDocumentModified()
                                        modified = false
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_unit", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_unit", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemPriceColumn
                        role: "price"
                        title: isVatModeVatNone ?
                                   qsTr("Price") : isVatModeVatInclusive ?
                                       qsTr("Price incl.") : qsTr("Price excl.")
                        width: getColumnWidth()
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignRight
                        delegate: Item {
                            StyledTextField {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: toLocaleItemNumberFormat(styleData.value)
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            let item = invoice.json.items[styleData.row];
                                            let internalAmountFormat = text ? toInternalItemNumberFormat(text) : ""
                                            if (isVatModeVatInclusive) {
                                                item.unit_price.amount_vat_inclusive = internalAmountFormat
                                                item.unit_price.amount_vat_exclusive = null
                                            } else {
                                                item.unit_price.amount_vat_inclusive = null
                                                item.unit_price.amount_vat_exclusive = internalAmountFormat
                                            }
                                            if (internalAmountFormat && !invoice.json.items[styleData.row].quantity) {
                                                // Fill quantity if a price is set
                                                item.quantity = "1"
                                            }
                                            if (internalAmountFormat && !isVatModeVatNone && !item.unit_price.vat_rate) {
                                                if (appSettings.data.new_documents.default_vat_code) {
                                                    item.unit_price.vat_code = appSettings.data.new_documents.default_vat_code
                                                    var vatCode = VatCodes.vatCodeGet(item.unit_price.vat_code)
                                                    if (vatCode) {
                                                        item.unit_price.vat_rate = vatCode.rate
                                                    }
                                                }
                                            }

                                            setDocumentModified()
                                            calculateInvoice()
                                            modified = false
                                        }
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_price", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_price", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemDiscountColumn
                        role: "discount"
                        title: qsTr("Discount")
                        width: getColumnWidth()
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignRight
                        visible: invoiceItemsTable.isColumnVisible("show_invoice_item_column_discount", role)
                        delegate: Item {
                            StyledTextField {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: toLocaleItemDiscountFormat(styleData.value)
                                placeholderText: hovered ? qsTr("30% or 30.00") : ""
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                readOnly: !appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_item_column_discount")
                                onEditingFinished: {
                                    if (modified) {
                                        if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                            let discount = parseDiscountFormat(text)
                                            if (discount.isZero) {
                                                delete invoice.json.items[styleData.row].discount
                                            } else if (discount.isPercentage) {
                                                invoice.json.items[styleData.row].discount = {
                                                    'percent' : discount.value
                                                }
                                            } else {
                                                invoice.json.items[styleData.row].discount = {
                                                    'amount' : discount.value
                                                }
                                            }
                                            setDocumentModified()
                                            calculateInvoice()
                                            modified = false
                                        }
                                    }
                                    focus = false // call at the end, if not with the tab key the edited text is lost
                                }
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                                onPressed: {
                                    if (!appSettings.meetInvoiceFieldLicenceRequirement("show_invoice_item_column_discount")) {
                                        dlgLicense.visible = true
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_discount", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_discount", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemTotalColumn
                        role: "total"
                        title: qsTr("Total")
                        width: getColumnWidth()
                        property int defaultWidth: 100 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignRight
                        delegate: Item {
                            StyledTextField {
                                readOnly: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                horizontalAlignment: styleData.textAlignment
                                text: toLocaleItemTotalFormat(styleData.value, styleData.row)
                                selected: invoiceItemsTable.focus &&
                                          currentInvoiceItemRow === styleData.row && currentInvoiceItemCol === styleData.role
                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_total", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_total", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    QuickControls14.TableViewColumn {
                        id: itemVatRateColumn
                        role: "vat_code"
                        title: qsTr("VAT")
                        width: getColumnWidth()
                        property int defaultWidth: 80 * Stylesheet.pixelScaleRatio
                        horizontalAlignment: Text.AlignRight
                        visible: !isVatModeVatNone
                        delegate: Item {
                            StyledKeyDescrComboBox {
                                id: invoice_item_vat
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.margins: 3 * Stylesheet.pixelScaleRatio
                                popupMinWidth: 300  * Stylesheet.pixelScaleRatio
                                popupAlign: Qt.AlignRight

                                currentIndex: getCurrentVatCodeIndex()
                                displayText: getDisplayText()

                                model: taxRatesModel
                                textRole: "key"
                                editable: false

                                onCurrentKeySet: function(key, isExistingKey) {
                                    if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                        let vatItem = invoice_item_vat.getCurrentItem()
                                        if (vatItem) {
                                            invoice.json.items[styleData.row].unit_price.vat_code = vatItem.key
                                            invoice.json.items[styleData.row].unit_price.vat_rate = vatItem.rate
                                            setDocumentModified()
                                            calculateInvoice()
                                        }
                                    }
                                }

                                Keys.onPressed: {
                                    if (event.key === Qt.Key_Tab) {
                                        if (currentIndex === -1) {
                                            updateInvoiceItem()
                                        }
                                    }
                                }

                                onFocusChanged: {
                                    if (focus) {
                                        currentInvoiceItemRow = styleData.row
                                        currentInvoiceItemCol = styleData.role
                                    }
                                }

                                function getDisplayText() {
                                    if (styleData.value) {
                                        return styleData.value
                                    } else if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                        // If the code is not set, show the rate
                                        if (invoice.json.items[styleData.row].unit_price.vat_rate) {
                                            return invoice.json.items[styleData.row].unit_price.vat_rate
                                        }
                                    }
                                    return "";
                                }

                                function updateInvoiceItem() {
                                    if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                        var vatRate = getCurrentVatCode()
                                        invoice.json.items[styleData.row].unit_price.vat_rate = vatRate.rate
                                        if (vatRate.code)
                                            invoice.json.items[styleData.row].unit_price.vat_code = vatRate.code
                                        else
                                            delete invoice.json.items[styleData.row].unit_price.vat_code
                                        setDocumentModified()
                                        calculateInvoice()
                                    }
                                }

                                function getCurrentVatCodeIndex() {
                                    if (styleData.row >= 0 && styleData.row < invoice.json.items.length) {
                                        if (invoice.json.items[styleData.row].unit_price.vat_code) {
                                            var itemVatCode = invoice.json.items[styleData.row].unit_price.vat_code
                                            for (var i = 0; i < model.count; i++) {
                                                if (model.get(i).code === itemVatCode) {
                                                    return i
                                                }
                                            }
                                        }
                                        invoice_item_vat.editText = invoice.json.items[styleData.row].unit_price.vat_rate
                                    }
                                    return -1
                                }

                                function getCurrentVatCode() {
                                    var vatRate = ""
                                    if (currentIndex > 0) {
                                        var currentVatRate = model.get(currentIndex)
                                        vatRate = {
                                            rate: currentVatRate.rate,
                                            code: currentVatRate.code,
                                        }

                                    } else if (currentIndex === 0) {
                                        vatRate = {
                                            rate: ""
                                        }

                                    } else if (currentIndex < 0) {
                                        var vatCode = VatCodes.vatCodeGet(editText)
                                        vatRate = {
                                            rate: editText,
                                        }

                                    } else {
                                        vatRate = {
                                            rate: ""
                                        }
                                    }

                                    if (Banana.SDecimal.isZero(vatRate.rate))
                                        vatRate.rate = ""

                                    return vatRate
                                }
                            }
                        }
                        onWidthChanged: {
                            saveInvoiceItemColumnWidth("width_invoice_item_column_vat", width)
                            updateColumnDescrWidhtTimer.restart()
                        }
                        function getColumnWidth() {
                            return getInvoiceItemColumnWidth("width_invoice_item_column_vat", defaultWidth)
                        }
                        function updateColumnWidth() {
                            width = getColumnWidth()
                        }
                    }

                    Timer {
                        id: updateColumnDescrWidhtTimer
                        interval: 500
                        repeat: false
                        onTriggered: invoiceItemsTable.updateColDescrWidth()
                    }

                    headerDelegate: Rectangle {
                        height: textItem.implicitHeight * 1.8
                        color: Stylesheet.baseColor
                        anchors.bottom: parent.top
                        anchors.bottomMargin: -textItem.implicitHeight * 1.8 + (6 * Stylesheet.pixelScaleRatio)


                        Text {
                            id: textItem
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: styleData.textAlignment
                            anchors.rightMargin: 6 * Stylesheet.pixelScaleRatio
                            anchors.leftMargin: 6 * Stylesheet.pixelScaleRatio
                            anchors.topMargin: 6 * Stylesheet.pixelScaleRatio
                            text: styleData.value
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                            color: Stylesheet.textColor
                        }
                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1 * Stylesheet.pixelScaleRatio
                            anchors.topMargin: 1 * Stylesheet.pixelScaleRatio
                            width: 1
                            color: "#ccc"
                        }
                    }

                    rowDelegate: Item {
                        height: getRowHeight(styleData.row)
                        //anchors.bottom: parent.top
                        anchors.top: parent.top

                        function getRowHeight(rowNr) {
                            let rowHeight = 30
                            if (invoiceItemsTable.signalUpdateRowHeights) {
                                if (invoice.json && invoice.json.items.length > rowNr) {
                                    if (invoice.json.items[rowNr]) {
                                        let linesCount = invoice.json.items[rowNr].description.split('\n').length
                                        rowHeight = 30 + 16 * (linesCount - 1)
                                    }
                                }
                            }
                            return rowHeight * Stylesheet.pixelScaleRatio
                        }

                        TextArea {
                            id: dummyTextArea
                            visible: false
                        }
                    }

                    onCurrentRowChanged: {
                        currentInvoiceItemRow = currentRow
                    }

                    onFocusChanged: {
                        if (!focus) {
                            //currentInvoiceItemRow = -1
                            //currentInvoiceItemCol = ""
                        }
                    }

                    onWidthChanged: {
                        updateColDescrWidth()
                    }

                    function isColumnVisible(fieldId, dataRole) {
                        if (appSettings.signalFieldsVisibilityChanged) {
                            if (currentView === appSettings.view_id_full) {
                                return true // In full view all items are visible
                            }
                            let viewAppearance = appSettings.data.interface.invoice.views[currentView].appearance
                            if (fieldId in viewAppearance) {
                                if (viewAppearance[fieldId]) {
                                    return true
                                } else if (viewAppearance.show_invoice_fields_if_not_empty) {
                                    if (dataRole) {
                                        for (let i = 0; i < invoiceItemsModel.count; ++i) {
                                            let data = invoiceItemsModel.get(i)[dataRole]
                                            if (data)
                                                return true
                                        }
                                    }
                                    return false
                                } else {
                                    return false
                                }
                            } else {
                                console.log("appearance flag '" + fieldId + "' in view '" + currentView + "' not found")
                            }
                        }
                        return true;

                    }

                    function updateColDescrWidth() {
                        let visColCount = getVisibleColumnCount() // just for binding
                        let colDescription = null
                        let availableWidth = viewport.width - 5
                        for (let i = 0; i < columnCount; ++i) {
                            let col = getColumn(i)
                            if (col.role !== "description") {
                                if (col.visible) {
                                    availableWidth -= col.width
                                }
                            } else {
                                colDescription = col
                            }
                        }

                        if (colDescription) {
                            colDescription.width = Math.max(200 * Stylesheet.pixelScaleRatio, availableWidth)
                        }
                    }

                    function updateColumnsWidths() {
                        for (let i = 0; i < columnCount; ++i) {
                            let col = getColumn(i)
                            if (col.role !== "description") {
                                col.updateColumnWidth()
                            }
                        }
                        updateColDescrWidth()
                    }

                    // Just for binding visible column count change with updateColDescrWidth
                    property int visibleColumnCount : getVisibleColumnCount()

                    onVisibleColumnCountChanged: {
                        updateColDescrWidth()
                    }

                    function getVisibleColumnCount() {
                        let c = 0
                        if (itemRowNrColumn.visible) c++
                        if (itemNumberColumn.visible) c++
                        if (itemDateColumn.visible) c++
                        if (itemDescriptionColumn.visible) c++
                        if (itemQuantityColumn.visible) c++
                        if (itemUnitColumn.visible) c++
                        if (itemDiscountColumn.visible) c++
                        if (itemVatRateColumn.visible) c++
                        return c
                    }

                    function getTableHeigth() {
                        if (!invoice.json || !invoice.json.items)
                            return 400 * Stylesheet.pixelScaleRatio

                        // Just for binding
                        if (!signalUpdateRowHeights || !signalUpdateTableHeight || !appSettings.signalItemsVisibilityChanged)
                            return 400 * Stylesheet.pixelScaleRatio

                        let maxVisibleItems = getMaxVisibleItems()
                        if (maxVisibleItems > 0) {
                            return (30 + 30 * maxVisibleItems)  * Stylesheet.pixelScaleRatio

                        } else {
                            // Compute current height
                            let height = 34;
                            for (let rowNr = 0; rowNr < invoice.json.items.length; ++rowNr) {
                                let linesCount = invoice.json.items[rowNr].description.split('\n').length
                                height += 30 + 16 * (linesCount - 1)
                            }
                            return height * Stylesheet.pixelScaleRatio
                        }
                    }

                    function getMaxVisibleItems() {
                        let maxVisibleItems = 0
                        if (currentView === appSettings.view_id_full) {
                            return 0 // In full view all items are visible
                        }
                        if (appSettings.data.interface.invoice.views[currentView] &&
                                ('invoce_max_visible_items_without_scrolling' in appSettings.data.interface.invoice.views[currentView].appearance)) {
                            maxVisibleItems = appSettings.data.interface.invoice.views[currentView].appearance['invoce_max_visible_items_without_scrolling'];
                        }
                        return maxVisibleItems
                    }

                }

                RowLayout { // Items button bar
                    Layout.fillWidth: true

                    StyledButton {
                        text: qsTr("Add")
                        enabled: !invoice.isReadOnly
                        onClicked: {
                            var rowIndex = currentInvoiceItemRow
                            if (rowIndex < 0 || (rowIndex + 1 < rowIndex.count)) {
                                invoice.json.items.push(emptyInvoiceItem())
                            } else {
                                invoice.json.items.splice(rowIndex + 1, 0, emptyInvoiceItem())
                            }
                            invoice.setIsModified(true)
                            updateViewItems()
                            invoiceItemsTable.signalUpdateTableHeight++
                        }
                    }

                    StyledButton { // Remove item button
                        text: qsTr("Remove")
                        enabled: !invoice.isReadOnly && invoiceItemsTable.currentRow >= 0
                        onClicked: {
                            var rowIndex = currentInvoiceItemRow
                            if (rowIndex >= 0 && rowIndex < invoiceItemsModel.count) {
                                invoice.json.items.splice(rowIndex, 1)
                            }
                            invoice.setIsModified(true)
                            calculateInvoice()
                            updateView()
                            //signalUpdateTableHeight++ not necessary cz updateView
                        }
                    }

                    Item {
                        Layout.preferredWidth: 10 * Stylesheet.pixelScaleRatio
                    }

                    StyledButton { // Move up button
                        text: qsTr("Move up")
                        enabled: !invoice.isReadOnly && invoiceItemsTable.currentRow > 0
                        onClicked: {
                            var itemRow = currentInvoiceItemRow
                            if (itemRow > 0 && itemRow < invoiceItemsModel.count) {
                                var itemCopy = invoice.json.items[itemRow]
                                invoice.json.items[itemRow] = invoice.json.items[itemRow-1]
                                invoice.json.items[itemRow - 1] = itemCopy
                                calculateInvoice()
                                updateViewItems()
                                currentInvoiceItemRow--
                                invoiceItemsTable.currentRow--
                                invoiceItemsTable.focus = true
                                //                                    invoiceItemsTable.currentRow = itemRow
                                //                                    invoiceItemsTable.selection.clear()
                                //                                    invoiceItemsTable.selection.select(itemRow)
                                //                                    invoiceItemsTable.forceActiveFocus()
                            }
                        }
                    }

                    StyledButton { // Move down button
                        text: qsTr("Move Down")
                        enabled: !invoice.isReadOnly && invoiceItemsTable.currentRow >= 0 && invoiceItemsTable.currentRow + 1 < invoiceItemsTable.rowCount
                        onClicked: {
                            var itemRow = currentInvoiceItemRow
                            if (itemRow >= 0 && itemRow < invoiceItemsModel.count - 1) {
                                var itemCopy = invoice.json.items[itemRow]
                                invoice.json.items[itemRow] = invoice.json.items[itemRow+1]
                                invoice.json.items[itemRow + 1] = itemCopy
                                calculateInvoice()
                                updateViewItems()
                                currentInvoiceItemRow++
                                invoiceItemsTable.currentRow++
                                invoiceItemsTable.focus = true
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 10 * Stylesheet.pixelScaleRatio
                    }


                }

                GridLayout {
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                    }

                    GridLayout { // Totals
                        id: columnLayoutTotal
                        columns: 2
                        columnSpacing: 30 * Stylesheet.pixelScaleRatio

                        Layout.fillWidth: true
                        Layout.alignment:  Qt.AlignRight
                        Layout.rightMargin: 0

                        StyledTextField {
                            readOnly: true
                            borderless: true
                            text: isVatModeVatNone ? qsTr("Subtotal") : isVatModeVatInclusive ? qsTr("Subtotal") : qsTr("Total Net")
                        }

                        StyledTextField {
                            id: subtotal_amount
                            readOnly: true
                            borderless: true
                            Layout.alignment: Qt.AlignRight
                            text: invoice.json ?
                                      toLocaleNumberFormat(
                                          (isVatModeVatNone || isVatModeVatInclusive) ?
                                              invoice.json.billing_info.total_amount_vat_inclusive_before_discount :
                                              invoice.json.billing_info.total_amount_vat_exclusive_before_discount,
                                          true
                                          ) : ""
                        }

                        RowLayout {
                            visible: invoice_totals_discount.visible

                            StyledTextField {
                                text: getDiscountDescription()
                                readOnly: invoice.isReadOnly
                                borderless: !hovered && !focus
                                Layout.minimumWidth: 150 * Stylesheet.pixelScaleRatio

                                onEditingFinished: {
                                    if (modified) {
                                        setDiscountDescription(text)
                                        if (!text) {
                                            text = qsTr("Discount")
                                        }
                                    }
                                }

                                function getDiscountDescription() {
                                    if (invoice.json && invoice.json.billing_info && invoice.json.billing_info.discount) {
                                        if (invoice.json.billing_info.discount.description)
                                            return invoice.json.billing_info.discount.description
                                    }
                                    return qsTr("Discount");
                                }

                                function setDiscountDescription(description) {
                                    if (!invoice.json)
                                        return
                                    if (!invoice.json.billing_info)
                                        invoice.json.billing_info = {}
                                    if (!invoice.json.billing_info.discount)
                                        invoice.json.billing_info.discount = {}
                                    invoice.json.billing_info.discount.description = description
                                }
                            }

                            StyledTextField {
                                id: discount_amount
                                Layout.minimumWidth: 100 * Stylesheet.pixelScaleRatio
                                Layout.alignment: Qt.AlignRight
                                readOnly: invoice.isReadOnly
                                text: invoice.json ? getDiscount() : ""
                                placeholderText: hovered ? qsTr("30% or 30.00") : ""
                                horizontalAlignment: Text.AlignRight

                                onEditingFinished: {
                                    if (modified) {
                                        let discount = parseDiscountFormat(text)
                                        if (discount.isZero) {
                                            delete invoice.json.billing_info.discount
                                        } else if (discount.isPercentage) {
                                            if (!invoice.json.billing_info.discount)
                                                invoice.json.billing_info.discount = {}
                                            invoice.json.billing_info.discount.percent = discount.value
                                            delete invoice.json.billing_info.discount.amount
                                            delete invoice.json.billing_info.discount.amount_vat_inclusive
                                            delete invoice.json.billing_info.discount.amount_vat_exclusive
                                        } else {
                                            if (!invoice.json.billing_info.discount)
                                                invoice.json.billing_info.discount = {}
                                            delete invoice.json.billing_info.discount.percent
                                            delete invoice.json.billing_info.discount.amount
                                            if (!isVatModeVatInclusive) {
                                                invoice.json.billing_info.discount.amount_vat_exclusive = discount.value
                                                delete invoice.json.billing_info.discount.amount_vat_inclusive
                                            } else {
                                                invoice.json.billing_info.discount.amount_vat_inclusive = discount.value
                                                delete invoice.json.billing_info.discount.amount_vat_exclusive
                                            }
                                        }
                                        calculateInvoice()
                                    }
                                }

                                function getDiscount() {
                                    if (invoice.json && invoice.json.billing_info && invoice.json.billing_info.discount) {
                                        if (invoice.json.billing_info.discount.percent) {
                                            let value = invoice.json.billing_info.discount.percent
                                            let dec = getDecimalsCount(value);
                                            return Banana.Converter.toLocaleNumberFormat(value, dec, true) + "%"
                                        } else if (invoice.json.billing_info.discount.amount_vat_inclusive) {
                                            let value = invoice.json.billing_info.discount.amount_vat_inclusive
                                            return toLocaleNumberFormat(value, false)
                                        } else if (invoice.json.billing_info.discount.amount_vat_exclusive) {
                                            let value = invoice.json.billing_info.discount.amount_vat_exclusive
                                            return toLocaleNumberFormat(value, false)
                                        } else if (invoice.json.billing_info.discount.amount) {
                                            let value = invoice.json.billing_info.discount.amount
                                            return toLocaleNumberFormat(value, false)
                                        }
                                    }
                                    return ""
                                }
                            }

                        }

                        StyledTextField {
                            id: invoice_totals_discount
                            Layout.alignment: Qt.AlignRight
                            readOnly: true
                            borderless: true
                            visible: discount_amount.focus ||
                                     isInvoiceFieldVisible("show_invoice_discount", !isLocaleZero(text))
                            text: toLocaleNumberFormat(invoice.json ? getDiscountAmount() : "", true)

                            function getDiscountAmount() {
                                let amount = ""
                                if (invoice.json && invoice.json.billing_info) {
                                    if (isVatModeVatNone || isVatModeVatInclusive) {
                                        if (invoice.json.billing_info.total_discount_vat_inclusive) {
                                            amount = invoice.json.billing_info.total_discount_vat_inclusive
                                        } else if (invoice.json.billing_info.discount && invoice.json.billing_info.discount.amount) {
                                            amount = invoice.json.billing_info.discount.amount
                                        }
                                    } else {
                                        if (invoice.json.billing_info.total_discount_vat_exclusive) {
                                            amount = invoice.json.billing_info.total_discount_vat_exclusive
                                        } else if (invoice.json.billing_info.discount && invoice.json.billing_info.discount.amount) {
                                            amount = invoice.json.billing_info.discount.amount
                                        }
                                    }
                                }
                                if (amount)
                                    amount = Banana.SDecimal.invert(amount)
                                return amount
                            }
                        }

                        StyledTextField {
                            readOnly: true
                            borderless: true
                            visible: vattotal_amount.visible
                            text: qsTr("VAT")
                        }

                        StyledTextField {
                            id: vattotal_amount
                            visible: !isVatModeVatNone && !isVatModeVatInclusive
                            readOnly: true
                            borderless: true
                            Layout.alignment: Qt.AlignRight
                            text: toLocaleNumberFormat(
                                      invoice.json ? invoice.json.billing_info.total_vat_amount : "",
                                      true)
                        }

                        StyledTextField {
                            text: qsTr("Rounding")
                            readOnly: true
                            borderless: true
                            visible: rounding_total_amounts.visible
                        }

                        StyledTextField {
                            id: rounding_total_amounts
                            readOnly: true
                            borderless: true
                            visible: isInvoiceFieldVisible("show_invoice_rounding", !isLocaleZero(text))
                            Layout.alignment: Qt.AlignRight
                            text: toLocaleNumberFormat(
                                      invoice.json ? invoice.json.billing_info.total_rounding_difference : "",
                                      true)
                        }

                        RowLayout {
                            visible: invoice_totals_deposit.visible

                            StyledTextField {
                                text: getDepositDescription()
                                readOnly: invoice.isReadOnly
                                borderless: !hovered && !focus
                                Layout.minimumWidth: 150 * Stylesheet.pixelScaleRatio

                                onEditingFinished: {
                                    if (modified) {
                                        setDepositDescription(text)
                                        if (!text)
                                            text = qsTr("Deposit")
                                    }
                                }


                                function getDepositDescription() {
                                    if (invoice.json && invoice.json.billing_info && invoice.json.billing_info.total_advance_payment_description) {
                                        return invoice.json.billing_info.total_advance_payment_description
                                    }
                                    return qsTr("Deposit");
                                }

                                function setDepositDescription(description) {
                                    if (!invoice.json || !invoice.json.billing_info)
                                        return
                                    invoice.json.billing_info.total_advance_payment_description = description
                                    setDocumentModified()
                                }
                            }

                            StyledTextField {
                                id: deposit_amount
                                horizontalAlignment: Text.AlignRight
                                Layout.alignment: Qt.AlignRight
                                Layout.preferredWidth: 100 * Stylesheet.pixelScaleRatio
                                readOnly: invoice.isReadOnly
                                text: toLocaleNumberFormat(invoice.json ? getDepositAmount() : "")

                                onEditingFinished: {
                                    if (modified) {
                                        let amount = ""
                                        if (!isLocaleZero(text)) {
                                            amount = toInternalNumberFormat(text)
                                            amount = Banana.SDecimal.invert(amount)
                                            amount = Banana.SDecimal.round(amount, {'decimals': getRoundingDecimals()})
                                        }
                                        invoice.json.billing_info.total_advance_payment = amount
                                        calculateInvoice()
                                    }
                                }

                                function getDepositAmount() {
                                    if (invoice.json && invoice.json.billing_info && invoice.json.billing_info.total_advance_payment) {
                                        return Banana.SDecimal.invert(invoice.json.billing_info.total_advance_payment)
                                    }
                                    return "";
                                }
                            }
                        }

                        StyledTextField {
                            id: invoice_totals_deposit
                            readOnly: true
                            borderless: true
                            text: invoice.json ? getDepositAmount() : ""
                            Layout.alignment: Qt.AlignRight
                            visible: deposit_amount.focus ||
                                     isInvoiceFieldVisible("show_invoice_deposit", !isLocaleZero(text))

                            function getDepositAmount() {
                                if (invoice.json && invoice.json.billing_info && invoice.json.billing_info.total_advance_payment) {
                                    return toLocaleNumberFormat(invoice.json.billing_info.total_advance_payment)
                                }
                                return toLocaleNumberFormat("", true);
                            }
                        }

                        RowLayout {
                            StyledTextField {
                                readOnly: true
                                borderless: true
                                text: qsTr("Total")
                            }
                            StyledLabel{
                                text: invoice.signalInvoiceChanged && invoice.json && invoice.json.document_info.currency ?
                                          invoice.json.document_info.currency.toLocaleUpperCase() : ""
                            }
                        }

                        StyledTextField {
                            id: total_amount
                            readOnly: true
                            borderless: true
                            horizontalAlignment: Text.AlignRight
                            Layout.alignment: Qt.AlignRight
                            Layout.minimumWidth: 120 * Stylesheet.pixelScaleRatio
                            text: toLocaleNumberFormat(invoice.json ? invoice.json.billing_info.total_to_pay : "", true)
                        }

                        StyledLabel{
                            Layout.topMargin: Stylesheet.defaultMargin
                            Layout.columnSpan: 2
                            Layout.leftMargin: 4 * Stylesheet.pixelScaleRatio
                            visible: isInvoiceFieldVisible("show_invoice_summary", text) && !isVatModeVatNone

                            text: invoice.json && invoice.json.billing_info.total_vat_rates ? getVatDetails() : ""

                            function getVatDetails() {
                                var vatDetails = "";
                                var totalVatRatesLength = invoice.json.billing_info.total_vat_rates.length;
                                for (var i = 0; i < totalVatRatesLength; i++) {
                                    var vatRatesObj = invoice.json.billing_info.total_vat_rates[i];
                                    var vatText = getVatRateDetails(vatRatesObj);
                                    if (vatDetails.length > 0)
                                        vatDetails += "\n";
                                    vatDetails += vatText;
                                }
                                if (invoice.json.billing_info.total_vat_rate_zero &&
                                        invoice.json.billing_info.total_vat_rate_zero.total_amount_vat_exclusive) {
                                    if (vatDetails.length > 0)
                                        vatDetails += "\n";
                                    vatDetails += getVatRateDetails(invoice.json.billing_info.total_vat_rate_zero);
                                }
                                return vatDetails;
                            }

                            function getVatRateDetails(vatRateObj) {
                                var vatText = qsTr("VAT %1% %4 %2 (%4 %3)");
                                vatText = vatText.replace("%1", vatRateObj["vat_rate"] ? vatRateObj["vat_rate"] : "0");
                                vatText = vatText.replace("%2", Banana.Converter.toLocaleNumberFormat(vatRateObj["total_vat_amount"], invoice.json.document_info.decimals_amounts, true));
                                vatText = vatText.replace("%3", Banana.Converter.toLocaleNumberFormat(vatRateObj["total_amount_vat_exclusive"], invoice.json.document_info.decimals_amounts, true));
                                vatText = vatText.replace(/%4/g, (invoice.signalInvoiceChanged && invoice.json.document_info.currency ?
                                                                      invoice.json.document_info.currency.toUpperCase() : ""));
                                return vatText;
                            }

                        }


                        Text { // Accounting details
                            id: accounting_details

                            Layout.columnSpan: 2
                            Layout.alignment: Qt.AlignRight

                            text: invoice.json ? getAccountingDetails() : ""
                            visible: text.length > 0

                            function getAccountingDetails() {
                                var accDetails = ""
                                if (invoice.json && invoice.json.accounting_info) {
                                    if (invoice.signalInvoiceChanged && invoice.json.document_info.currency !== appAccountingSettings.value("base_currency", "CHF")) {
                                        // Accounting amount 1'200 EUR (1 EUR / 1.2 CHF)
                                        var amount_acc_currency = Banana.Converter.toLocaleNumberFormat(invoice.json.accounting_info.amount)
                                        var multiplier = invoice.json.accounting_info.multiplier ? invoice.json.accounting_info.multiplier : "1.00"
                                        var exchangeRate = Banana.Converter.toLocaleNumberFormat(invoice.json.accounting_info.exchange_rate, 4)
                                        accDetails = "Base currency total %1 %2 (%3 %4 / %5 %6)".arg(amount_acc_currency).arg(invoice.json.accounting_info.currency)
                                        if (Banana.SDecimal.sign(multiplier) >= 0) {
                                            if (Banana.SDecimal.compare(multiplier, "1") === 0)
                                                multiplier = "1"
                                            accDetails = accDetails.arg(multiplier).arg(invoice.json.document_info.currency)
                                            accDetails = accDetails.arg(exchangeRate).arg(invoice.json.accounting_info.currency)
                                        } else {
                                            multiplier = Banana.SDecimal.invert(multiplier)
                                            if (Banana.SDecimal.compare(multiplier, "1") === 0)
                                                multiplier = "1"
                                            accDetails = accDetails.arg(exchangeRate).arg(invoice.json.document_info.currency)
                                            accDetails = accDetails.arg(multiplier).arg(invoice.json.accounting_info.currency)
                                        }
                                    }
                                }
                                return accDetails
                            }

                            function update() {
                                text = getAccountingDetails()
                            }
                        }
                    }
                }

                Item { // Spacer
                    height: Stylesheet.defaultMargin
                }

                StyledLabel{
                    text: qsTr("Internal notes")
                    visible: invoice_internal_notes.visible
                }

                StyledTextArea {
                    id: invoice_internal_notes
                    Layout.minimumHeight: 60 * Stylesheet.pixelScaleRatio
                    Layout.fillWidth: true
                    visible: focus || isInvoiceFieldVisible("show_invoice_internal_notes", text)
                    text: invoice.json && invoice.json.internalNote ? invoice.json.internalNote : ""
                    onEditingFinished: {
                        if (modified) {
                            invoice.json.internalNote = text
                            setDocumentModified()
                        }
                    }
                }

            }
        }
    }

    // Dialogs

    NotificationPopUp {
        id: notificationPopUp
        visible: false
    }

    SimpleMessageDialog { // Error message dialog
        id: errorMessageDialog
        visible: false
    }

    DlgLincense {
        id: dlgLicense
        visible: false
    }

    // Document methods
    function isWithoutVat() {
        if (invoice.json && invoice.json.document_info.vat_mode === "vat_none") {
            return true
        }
        return false
    }

    function arePricesVatExclusive() {
        if (invoice.json && invoice.json.document_info.vat_mode === "vat_excl") {
            return true
        }
        return false
    }

    function getRoundingDecimals() {
        if (invoice.json && invoice.json.document_info.decimals_amounts !== null) {
            if (invoice.json.document_info.decimals_amount >= 0) {
                return invoice.json.document_info.decimals_amounts
            }
        }
        return Banana.document.rounding.decimals
    }

    function setDocumentLocale(lang) {
        if (lang) {
            let curLang = invoice.json.document_info.locale;
            if (curLang !== lang) {
                // Update document title if not modified
                let docNr = invoice.json.document_info.number;
                let defaultTitle = Invoice.invoiceGetTitle(invoice.isEstimate(), docNr, curLang);
                if (defaultTitle === invoice.json.document_info.description) {
                    // Update document title
                    let newDescription = Invoice.invoiceGetTitle(invoice.isEstimate(), docNr, lang);
                    invoice_description.text = newDescription;
                    invoice.json.document_info.description = newDescription;
                }
            }
            invoice.json.document_info.locale = lang;
            invoiceUpdateCustomFields();
            setDocumentModified()
        }
    }

    function setDocumentModified() {
        invoice.setIsModified(true)
    }

    function setAddressModified() {
        updateViewAddress()
        setDocumentModified()
    }

    function emptyInvoiceItem() {
        var invoiceItem = {
            "description": "",
            "item_type": "",
            "mesure_unit": "",
            "number": "",
            "quantity": "",
            "unit_price": {}
        };

        if (isVatModeVatInclusive) {
            invoiceItem.unit_price.amount_vat_inclusive = ""
            invoiceItem.unit_price.amount_vat_exclusive = null
        } else {
            invoiceItem.unit_price.amount_vat_inclusive = null
            invoiceItem.unit_price.amount_vat_exclusive = ""
        }
        return invoiceItem;
    }

    function invoiceItemToModelItem(invoiceItem, itemIndex) {
        var modelItem = {
            'item_type' : "",
            'number': "",
            'date': "",
            'description' : "",
            'quantity' : "",
            'price' : "",
            'mesure_unit' : "",
            'discount' : "",
            'vat_rate' : "",
            'vat_code' : "",
            'total' : ""
        }

        if (invoiceItem) {
            // Don't let assign 'null' if not the table will not show any text afterwards
            modelItem.item_type = invoiceItem.item_type ? invoiceItem.item_type : ""
            modelItem.number = invoiceItem.number ? invoiceItem.number : ""
            modelItem.date = invoiceItem.date ? invoiceItem.date : ""
            modelItem.description = invoiceItem.description ? invoiceItem.description : ""
            modelItem.quantity = invoiceItem.quantity ? invoiceItem.quantity : ""
            modelItem.mesure_unit = invoiceItem.mesure_unit ? invoiceItem.mesure_unit : ""
            if (invoiceItem.unit_price) {
                if (isVatModeVatNone) {
                    modelItem.price = invoiceItem.unit_price.amount_vat_inclusive ? invoiceItem.unit_price.amount_vat_inclusive : ""
                    modelItem.total = invoiceItem.total_amount_vat_inclusive ? invoiceItem.total_amount_vat_inclusive : ""

                } else {
                    modelItem.vat_rate = invoiceItem.unit_price.vat_rate ? invoiceItem.unit_price.vat_rate : ""
                    modelItem.vat_code = invoiceItem.unit_price.vat_code ? invoiceItem.unit_price.vat_code : ""
                    if (isVatModeVatInclusive) {
                        if (invoiceItem.unit_price.amount_vat_inclusive)
                            modelItem.price = invoiceItem.unit_price.amount_vat_inclusive ? invoiceItem.unit_price.amount_vat_inclusive : ""
                        else
                            modelItem.price = invoiceItem.unit_price.calculated_amount_vat_inclusive ? invoiceItem.unit_price.calculated_amount_vat_inclusive : ""
                        modelItem.total = invoiceItem.total_amount_vat_inclusive ? invoiceItem.total_amount_vat_inclusive : ""
                    } else {
                        if (invoiceItem.unit_price.amount_vat_exclusive)
                            modelItem.price = invoiceItem.unit_price.amount_vat_exclusive ? invoiceItem.unit_price.amount_vat_exclusive : ""
                        else
                            modelItem.price = invoiceItem.unit_price.calculated_amount_vat_exclusive ? invoiceItem.unit_price.calculated_amount_vat_exclusive : ""
                        modelItem.total = invoiceItem.total_amount_vat_exclusive ? invoiceItem.total_amount_vat_exclusive : ""
                    }
                }

            } else {
                modelItem.vat_rate = ""
                modelItem.vat_code = ""
                modelItem.price = ""
                modelItem.total = ""
                modelItem.quantity = ""

            }

            if (invoiceItem.discount) {
                if (invoiceItem.discount.percent) {
                    modelItem.discount = invoiceItem.discount.percent + "%"
                } else if (invoiceItem.discount.amount) {
                    modelItem.discount = invoiceItem.discount.amount
                } else {
                    modelItem.discount = ""
                }
            } else {
                modelItem.discount = ""
            }

        }

        return modelItem
    }

    function addItemToInvoice(invoiceItem) {
        if (invoiceItem) {
            if (invoiceItemsTable.currentRow < 0) {
                invoice.json.items.push(invoiceItem)
            } else {
                invoice.json.items.splice(invoiceItemsTable.currentRow, 0, invoiceItem)
            }
            calculateInvoice()
            invoiceItemsTable.selection.clear()
            invoiceItemsTable.currentRow = insertPos
            invoiceItemsTable.selection.select(insertPos)
        }
    }

    // Address methods
    function addressToModelAddress(addressRow) {
        var invoiceAddress = {
            'number': addressRow.ContactId,
            'courtesy' : addressRow.ContactSalutation,
            'business_name' : addressRow.ContactOrganisation,
            'first_name' : addressRow.ContactFirstName,
            'last_name' : addressRow.ContactLastName,
            'address1' : addressRow.ContactAddress1,
            'address2' : addressRow.ContactAddress2,
            'address3' : addressRow.ContactAddress3,
            'postal_code' : addressRow.ContactPostalCode,
            'city' : addressRow.ContactCity,
            'country' : addressRow.ContactCountry,
            'vat_number' : addressRow.ContactVatNumber,
            'fiscal_number' : addressRow.ContactFiscalNumber,
            'phone' : addressRow.ContactPhone,
            'mobile' : addressRow.ContactMobile,
            'email' : addressRow.ContactEmail,
        }
        return invoiceAddress
    }


    // View methods

    function loadCustomerAddresses() {
        customerAddressesModel.clear()
        customerAddressesModel.append({'key': '','descr': ''})
        var contacts = Contacts.contactsAddressesGet()
        for (var i = 0; i < contacts.length; ++i) {
            customerAddressesModel.append(contacts[i])
        }
    }

    function loadItems() {
        itemsModel.clear();
        itemsModel.append({'key': '','descr': ''})
        var items = Items.itemsGet()
        for (var i = 0; i < items.length; ++i) {
            itemsModel.append(items[i]);
        }
    }

    function loadLanguages() {
        // Get default languages
        var languages = {
            'de' : {"englishName":  'German', "nativeName": 'Deutsch'},
            'en' : {"englishName":  'English', "nativeName": 'English'},
            'es' : {"englishName":  'Spanish', "nativeName": 'Español'},
            'fr' : {"englishName":  'French', "nativeName": 'Français'},
            'it' : {"englishName":  'Italian', "nativeName": 'Italiano'},
            'nl' : {"englishName":  'Portuguese', "nativeName": 'Portuguese'},
            'pt' : {"englishName":  'Portuguese', "nativeName": 'Portuguese'},
            'ru' : {"englishName":  'Russian', "nativeName": 'Русский'},
            'zh' : {"englishName":  'Chinese', "nativeName": '简体中文'}
        }

        // Fill default languages with the customer languages
        let contactsLocales = contactsLocalesGet()
        let contactsLanguagesCodes = Object.keys(contactsLocales);
        for (let i = 0; i < contactsLanguagesCodes.length; ++i) {
            let langCode = contactsLanguagesCodes[i]
            if (!languages[langCode]) {
                languages[langCode] = contactsLocales[langCode]
            }
        }

        // Sort languages by code and fill the model
        let languagesCodes = Object.keys(languages).sort();
        for (let i = 0; i < languagesCodes.length; ++i) {
            let langCode = languagesCodes[i]
            let language = languages[langCode];
            languagesModel.append({key: langCode, descr: language.nativeName})
        }
    }

    function loadCurrencies() {
        // Get default currencies
        var currencies = {
            'CHF' : {"descr":  qsTr('Swiss Franc')},
            'EUR' : {"descr":  qsTr('Euro')},
            'USD' : {"descr":  qsTr('US Dollar')},
        }

        // Fill default currencies with the customer currencies
        /**
            let contactsCurrencies = contactsCurrenciesGet()
            let contactsLanguagesCodes = Object.keys(contactsCurrencies);
            for (let i = 0; i < contactsLanguagesCodes.length; ++i) {
                let currencyCode = contactsLanguagesCodes[i]
                if (!currencies[currencyCode]) {
                    currencies[currencyCode] = contactsCurrencies[currencyCode]
                }
            }
            */

        // Fill default currencies with the invoices currencies
        /**
            let invoicesCurrencies = invoicesCurrenciesGet()
            let invoicesLanguagesCodes = Object.keys(invoicesCurrencies);
            for (let i = 0; i < invoicesLanguagesCodes.length; ++i) {
                let currencyCode = contactsLanguagesCodes[i]
                if (!currencies[currencyCode]) {
                    currencies[currencyCode] = invoicesCurrencies[currencyCode]
                }
            }
            */

        // Sort languages by code and fill the model
        currenciesModel.clear()
        let currenciesAbbreviations = Object.keys(currencies).sort();
        for (let i = 0; i < currenciesAbbreviations.length; ++i) {
            let currencyCode = currenciesAbbreviations[i]
            currenciesModel.append({key: currencyCode, descr: currencies[currencyCode].descr})
        }
    }

    function loadTaxRates() {
        taxRatesModel.clear();
        taxRatesModel.append(
                    {
                        'key': "",
                        'descr' : "",
                        'rate': ""
                    })
        var vatCodes = VatCodes.vatCodesGet()
        for (var i = 0; i < vatCodes.length; ++i) {
            taxRatesModel.append(vatCodes[i]);
        }
    }

    function updateView() {
        updateViewAddress()
        updateViewVatMode()
        updateViewItems()
    }

    function updateViewAddress() {
        if (!invoice.json)
            return

        address_business_name.text = invoice.json ? invoice.json.customer_info.business_name : ""
        address_business_unit.text = invoice.json && invoice.json.customer_info.business_unit ? invoice.json.customer_info.business_unit : ""
        address_business_unit_2.text = invoice.json && invoice.json.customer_info.business_unit2 ? invoice.json.customer_info.business_unit2 : ""
        address_business_unit_3.text = invoice.json && invoice.json.customer_info.business_unit3 ? invoice.json.customer_info.business_unit3 : ""
        address_business_unit_4.text = invoice.json && invoice.json.customer_info.business_unit4 ? invoice.json.customer_info.business_unit4 : ""
        address_courtesy.text = invoice.json.customer_info.courtesy ? invoice.json.customer_info.courtesy : ""
        address_first_name.text = invoice.json.customer_info.first_name
        address_last_name.text = invoice.json.customer_info.last_name
        address_address1.text = invoice.json.customer_info.address1 ? invoice.json.customer_info.address1 : ""
        address_address2.text = invoice.json.customer_info.address2 ? invoice.json.customer_info.address2 : ""
        address_address3.text = invoice.json.customer_info.address3 ? invoice.json.customer_info.address3 : ""
        address_postal_code.text = invoice.json.customer_info.postal_code
        address_city.text = invoice.json.customer_info.city
        address_country_code.text = invoice.json.customer_info.country_code
        address_phone.text = invoice.json.customer_info.phone ? invoice.json.customer_info.phone : ""
        address_email.text = invoice.json.customer_info.email ? invoice.json.customer_info.email : ""
        address_vat_number.text = invoice.json.customer_info.vat_number ? invoice.json.customer_info.vat_number : ""
        address_fiscal_number.text = invoice.json.customer_info.fiscal_number ? invoice.json.customer_info.fiscal_number : ""
    }

    function updateViewVatMode() {
        isVatModeVatNone = isWithoutVat();
        isVatModeVatInclusive = !arePricesVatExclusive()
    }

    function updateViewItems() {
        var modelItem = null
        var modelIndex = 0;
        var invoiceItemIndex = 0;

        // Aggiorna items esistenti
        for (modelIndex = 0 ;modelIndex < invoiceItemsModel.count && invoiceItemIndex < invoice.json.items.length; modelIndex++, invoiceItemIndex++) {
            modelItem = invoiceItemToModelItem(invoice.json.items[invoiceItemIndex], invoiceItemIndex)
            invoiceItemsModel.set(modelIndex, modelItem)
        }

        if (invoiceItemIndex < invoice.json.items.length) {
            // Aggiungi nuovi items
            for (;invoiceItemIndex < invoice.json.items.length; invoiceItemIndex++) {
                modelItem = invoiceItemToModelItem(invoice.json.items[invoiceItemIndex], invoiceItemIndex)
                invoiceItemsModel.append(modelItem)
            }
        } else if (modelIndex < invoiceItemsModel.count) {
            // Rimuovi items cancellati
            invoiceItemsModel.remove(modelIndex, invoiceItemsModel.count - modelIndex)
        }
    }

    function calculateInvoice() {
        if (invoice.calculate()) {
            updateView()
        } else {
            errorMessageDialog.text = invoice.errorString
            errorMessageDialog.visible = true
        }
    }

    function exportInvoice() {
        // ...
    }

    function setInvoiceCustomerAddress(invoice, address) {
        if (invoice && address) {
            if (!invoice.customer_info)
                invoice.customer_info = {}

            invoice.customer_info.number = address.number
            invoice.customer_info.courtesy = address.courtesy
            invoice.customer_info.business_name = address.business_name
            invoice.customer_info.first_name = address.first_name
            invoice.customer_info.last_name = address.last_name
            invoice.customer_info.address1 = address.address1
            invoice.customer_info.address2 = address.address2
            invoice.customer_info.address3 = address.address3
            invoice.customer_info.postal_code = address.postal_code
            invoice.customer_info.city = address.city
            invoice.customer_info.country_code = address.country_code
            invoice.customer_info.vat_number = address.vat_number
            invoice.customer_info.fiscal_number = address.fiscal_number
            invoice.customer_info.phone = address.phone
            invoice.customer_info.mobile = address.mobile
            invoice.customer_info.email = address.email
        }
    }

    function setInvoiceShippingAddress(invoice, address) {
        if (invoice && address) {
            if (!invoice.shipping_info)
                invoice.shipping_info = {}

            invoice.shipping_info.courtesy = address.courtesy
            invoice.shipping_info.business_name = address.business_name
            invoice.shipping_info.first_name = address.first_name
            invoice.shipping_info.last_name = address.last_name
            invoice.shipping_info.address1 = address.address1
            invoice.shipping_info.address2 = address.address2
            invoice.shipping_info.address3 = address.address3
            invoice.shipping_info.postal_code = address.postal_code
            invoice.shipping_info.city = address.city
            invoice.shipping_info.country_code = address.country_code
            invoice.shipping_info.phone = address.phone
            invoice.shipping_info.mobile = address.mobile
            invoice.shipping_info.email = address.email
        }
    }

    function invoiceCompleteMissingFields(invoice) {
        if (!invoice)
            invoice = {}

        invoice.version = "1.0"

        if (!invoice.document_info)
            invoice.document_info = {}
        if (!invoice.document_info.decimals_amounts)
            invoice.document_info.decimals_amounts = 2
        if (!invoice.document_info.rounding_total)
            invoice.document_info.rounding_total = "0.05"

        if (!invoice.customer_info)
            invoice.customer_info = {}
        if (!invoice.customer_info.address)
            invoice.customer_info.address = {}

        if (!invoice.shipping_info)
            invoice.shipping_info = {}
        if (!invoice.shipping_info.address) {
            invoice.shipping_info.different_shipping_address = false
            invoice.shipping_info.address = {}
        }

        if (!invoice.items)
            invoice.items = []
    }

    function invoiceUpdateCustomFields() {

        // Read form custom fields
        let language = invoice && invoice.json && invoice.json.document_info && invoice.json.document_info.locale ?
                invoice.json.document_info.locale.substring(0,2) : Banana.document.locale.substring(0,2);
        let custom_fields = []
        if (invoice_custom_field_1.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_1.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_1.customFieldId, language),
                                  "value": invoice_custom_field_1.text
                              });
        }
        if (invoice_custom_field_2.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_2.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_2.customFieldId, language),
                                  "value": invoice_custom_field_2.text
                              });
        }
        if (invoice_custom_field_3.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_3.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_3.customFieldId, language),
                                  "value": invoice_custom_field_3.text
                              });
        }
        if (invoice_custom_field_4.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_4.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_4.customFieldId, language),
                                  "value": invoice_custom_field_4.text
                              });
        }
        if (invoice_custom_field_5.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_5.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_5.customFieldId, language),
                                  "value": invoice_custom_field_5.text
                              });
        }
        if (invoice_custom_field_6.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_6.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_6.customFieldId, language),
                                  "value": invoice_custom_field_6.text
                              });
        }
        if (invoice_custom_field_7.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_7.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_7.customFieldId, language),
                                  "value": invoice_custom_field_7.text
                              });
        }
        if (invoice_custom_field_8.text) {
            custom_fields.push({
                                  'id': invoice_custom_field_8.customFieldId,
                                  "title": Settings.getTranslatedText(appSettings.data, "invoice_" + invoice_custom_field_8.customFieldId, language),
                                  "value": invoice_custom_field_8.text
                              });
        }

        // Keeps custom fields not present in the form
        if (invoice.json.document_info.custom_fields) {
            let implFields = [
                    'invoice_custom_field_1',
                    'invoice_custom_field_2',
                    'invoice_custom_field_3',
                    'invoice_custom_field_4',
                    'custom_field_1',
                    'custom_field_2',
                    'custom_field_3',
                    'custom_field_4',
                    'custom_field_5',
                    'custom_field_6',
                    'custom_field_7',
                    'custom_field_8',
                ]
            for (let i = 0; i < invoice.json.document_info.custom_fields; ++i) {
                if (implFields.indexOf(invoice.json.document_info.custom_fields[i].id) === -1) {
                    custom_fields.push(invoice.json.document_info.custom_fields[i]);
                }
            }
        }

        invoice.json.document_info.custom_fields = custom_fields;
    }

    // Convertion functions

    /**
         * Return the number of decimals.
         */
    function getDecimalsCount(value) {
        if (value) {
            var separatorPos = value.indexOf('.')
            if (separatorPos > -1) {
                return value.length - separatorPos - 1
            }
        }
        return 0
    }

    function isLocaleZero(value) {
        if (!value)
            return true
        return Banana.SDecimal.isZero(Banana.Converter.toInternalNumberFormat(value))
    }

    function parseDiscountFormat(value) {
        let result = {
            'isZero': true,
            'isPercentage': false,
            'value': null
        }

        if (value.indexOf('%') >= 0) {
            result.isPercentage = true
            let perc = Banana.Converter.toInternalNumberFormat(value.substring(0, value.indexOf('%')))
            if (!Banana.SDecimal.isZero(perc)) {
                result.isZero = false
                result.value = perc
            }
        } else {
            result.isPercentage = false
            let amount = Banana.Converter.toInternalNumberFormat(value)
            if (!Banana.SDecimal.isZero(amount)) {
                result.isZero = false
                result.value = amount
            }
        }

        return result
    }

    function toLocaleNumberFormat(value, convZeroValues) {
        return Banana.Converter.toLocaleNumberFormat(value, getRoundingDecimals(), convZeroValues)
    }

    function toLocaleItemNumberFormat(value) {
        let dec = getDecimalsCount(value);
        return Banana.Converter.toLocaleNumberFormat(value, dec, false)
    }

    function toLocaleItemDiscountFormat(value) {
        if (value.indexOf('%') >= 0) {
            let perc = value.substring(0, value.indexOf('%'))
            if (!perc || perc.trim().length === 0)
                return ""
            let dec = getDecimalsCount(perc);
            return Banana.Converter.toLocaleNumberFormat(perc, dec, true) + "%"

        } else {
            if (!value || value.trim().length === 0)
                return ""
            let dec = getDecimalsCount(value);
            return Banana.Converter.toLocaleNumberFormat(value, dec, false)
        }
    }

    function toLocaleItemTotalFormat(value, row) {
        let convIfZero = false
        if (invoiceItemsModel && invoiceItemsModel.count > row && row >= 0) {
            convIfZero = invoiceItemsModel.get(row).price && invoiceItemsModel.get(row).price.length > 0
        }
        return Banana.Converter.toLocaleNumberFormat(value, getRoundingDecimals(), convIfZero);
    }

    /* This method convert an iso date/time string to the local date/time format */
    function toLocaleDateTimeFormat(value) {
        if (!value || !value.length)
            return value

        var datetimeParts = value.split('T');
        if (datetimeParts.length === 2) {
            return Banana.Converter.toLocaleDateFormat(datetimeParts[0]) + " " +
                    Banana.Converter.toLocaleTimeFormat(datetimeParts[1])
        }
        return Banana.Converter.toLocaleDateFormat(datetimeParts[0])
    }

    /* This method convert a local amount to the interal amount format */
    function toInternalNumberFormat(value) {
        if (!value)
            return ""
        let retValue = Banana.Converter.toInternalNumberFormat(value)
        if (Banana.SDecimal.isZero(retValue))
            return ""
        var dec = getRoundingDecimals()
        retValue = Banana.SDecimal.round(retValue, {'decimals': dec})
        return retValue
    }

    /* This method convert a local amount to the interal amount format */
    function toInternalItemNumberFormat(value) {
        if (!value)
            return ""
        var amount = Banana.Converter.toInternalNumberFormat(value)
        if (Banana.SDecimal.isZero(amount))
            return ""
        if (getDecimalsCount(amount) < getRoundingDecimals()) {
            amount = Banana.SDecimal.round(amount, {'decimals': getRoundingDecimals()})
        }
        return amount
    }

    /* This method convert a local date/time string to the iso format */
    function toInternalDateTimeFormat(value) {
        if (!value || !value.length)
            return value;

        var datetimeParts = value.trim().split(' ');
        if (datetimeParts.length === 2) {
            return Banana.Converter.toInternalDateFormat(datetimeParts[0]) + "T" +
                    Banana.Converter.toInternalTimeFormat(datetimeParts[1])
        }
        return Banana.Converter.toInternalDateFormat(datetimeParts[0]);
    }

    function showHelp() {
        Banana.Ui.showHelp("dlginvoiceedit");
    }

    // Appearance methods

    function isInvoiceFieldVisible(fieldId, isNotEmpty) {
        if (appSettings.signalFieldsVisibilityChanged) {
            if (currentView === appSettings.view_id_full) {
                return true
            }
            let viewAppearance = appSettings.data.interface.invoice.views[currentView].appearance
            if (fieldId in viewAppearance) {
                if (viewAppearance[fieldId]) {
                    return true
                } else if (isNotEmpty && viewAppearance.show_invoice_fields_if_not_empty) {
                    return true
                } else {
                    return false
                }
            } else {
                console.log("appearance flag '" + fieldId + "' in view '" + currentView + "' not found")
            }
        }
        return true;
    }

    function getInvoiceItemColumnWidth(columnId, defaultWidth) {
        let viewAppearance = appSettings.data.interface.invoice.views[currentView].appearance
        if (columnId in viewAppearance) {
            let width = viewAppearance[columnId]
            if (width > 10)
                return width
        } else {
            console.log("appearance flag '" + columnId + "' in view '" + currentView + "' not found")
        }
        return defaultWidth;
    }

    function saveInvoiceItemColumnWidth(columnId, width) {
        let viewAppearance = appSettings.data.interface.invoice.views[currentView].appearance
        viewAppearance[columnId] = width
    }

}
