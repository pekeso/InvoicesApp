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

/**
 * The object InvoiceTools define common methods used by the JsAction.
 */

// @includejs = invoice.js

function invoicesLocalesGet() {
    var languages = [];
    var table = invoicesTableGet();
    for (var i = 0; i < table.rowCount; ++i) {
        let invoice = invoiceObjGet(i);
        if (invoice) {
            let lang = invoice.document_info.locale.substring(0, 2);
            if (languages.indexOf(lang) === -1) {
                languages.push(lang);
            }
        }
    }
    return languages;
}

function estimatesLocalesGet() {
    var languages = [];
    var table = estimatesTableGet();
    for (var i = 0; i < table.rowCount; ++i) {
        let invoice = invoiceObjGet(i);
        if (invoice) {
            let lang = invoice.document_info.locale.substring(0, 2);
            if (languages.indexOf(lang) === -1) {
                languages.push(lang);
            }
        }
    }
    return languages;
}

function invoicesTableGet() {
    return Banana.document.table("Invoices");
}

function estimatesTableGet() {
    return Banana.document.table("Estimates");
}
