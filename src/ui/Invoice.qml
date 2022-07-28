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

import QtQuick

import "../base/invoice.js" as Invoice

QtObject {
    // Constants
    readonly property int type_invoice: 0
    readonly property int type_estimate: 1

    // Properties
    property var json: null
    property int type: type_invoice
    property var tabPos: null

    property bool isModified: false
    property bool isNewDocument: false
    property bool isReadOnly: false

    property bool error: false
    property string errorString: ""

    // Private properties
    property var docChange: null
    property bool docChangeRowModifyAdded : false
    property bool docChangeRowAddAdded : false

    // Signals
    signal invoiceChanged()
    signal invoiceSaved()

    property int signalInvoiceChanged: 1

    // Methods

    function calculate() {
        clearError()
        Invoice.invoiceUpdateCreatorInfo(json)
        Invoice.invoiceUpdateSupplierInfo(json)

        // Calculate
        var jsonData = JSON.stringify(json)
        jsonData = Banana.document.calculateInvoice(jsonData)
        if (jsonData && jsonData.length) {
            try {
                // Update json
                json = JSON.parse(jsonData)
                setIsModified(true)
                return true
            } catch(err) {
                error = true
                errorString = err.message()
            }
        }
        return false
    }

    function clearError() {
        error = false
        errorString = null
    }

    function isEstimate() {
        return type === type_estimate;
    }

    function save() {
        Invoice.invoiceUpdateCreatorInfo(invoice.json);
        Invoice.invoiceUpdateSupplierInfo(invoice.json)

        if (isNewDocument) {
            // new invoice / estimate
            let changedRowFields = invoiceChangedFieldsGet(invoice.json, null)
            let invoiceDataField = invoiceUpdatedInvoiceDataFieldGet(null, invoice.json)
            changedRowFields["InvoiceData"] = invoiceDataField

            if (docChangeRowAddAdded)
                docChange.removeLastOperation();

            docChange.addOperationRowAdd(tabPos.tableName, changedRowFields);
            docChange.setOperationCursorMove(
                        tabPos.tableName,
                        Banana.document.table(tabPos.tableName).rowCount,
                        "RowId");
            docChangeRowAddAdded = true

        } else {
            // existing invoice / estimate
            let invoiceRow = invoiceRowGet(invoice.tabPos)
            let changedRowFields = invoiceChangedFieldsGet(invoice.json, invoiceRow)
            let invoiceDataField = invoiceUpdatedInvoiceDataFieldGet(tabPos, invoice.json)
            changedRowFields["InvoiceData"] = invoiceDataField

            if (docChangeRowModifyAdded)
                invoice.docChange.removeLastOperation()

            docChange.addOperationRowModify(
                        invoice.tabPos.tableName,
                        invoice.tabPos.rowNr,
                        changedRowFields);
            docChangeRowAddAdded = true;

        }

        setIsModified(false)
        invoiceSaved()
    }

    function setIsNew(newDocument) {
        isNewDocument = newDocument
    }

    function setIsModified(modified) {
        isModified = modified
        invoiceChanged()
        signalInvoiceChanged++
    }

    function setIsEstimate(estimate) {
        if (estimate) {
            type = type_estimate
        } else {
            type = type_invoice
        }
    }

    function setIsReadOnly(readOnly) {
        isReadOnly = readOnly
        invoiceChanged()
    }

    function setDocumentChange(doc) {
        docChange = doc
    }

    function setInvoice(invoice) {
        json = invoice
        invoiceChanged()
        signalInvoiceChanged++
    }

    function setPosition(pos) {
        tabPos = pos
    }

    function setType(tp) {
        type = tp
    }
}
