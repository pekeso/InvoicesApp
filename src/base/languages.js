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

// @includejs = contacts.js
// @includejs = invoices.js

function getLanguageName(lang) {
    if (lang === "de") {
        return qsTr("German");
    } else if (lang === "fr") {
        return qsTr("French");
    } else if (lang === "en") {
        return qsTr("English");
    } else if (lang === "es") {
        return qsTr("Spanish");
    } else if (lang === "it") {
        return qsTr("Italian");
    } else if (lang === "nl") {
        return qsTr("Dutch");
    } else if (lang === "pt") {
        return qsTr("Portuguese");
    } else if (lang === "zh") {
        return qsTr("Chinese");
    } else {
        return lang;
    }
}

/**
 * The method getInvoicesLanguages return all the langauges codes used for
 * the application, the document, contacts and invoices.
 */
function getUsedLanguagesCodes() {
    // Default languages, always showed
    let languages = ['de', 'en', 'fr', 'it'];

    // Application language
    let lang = Banana.application.locale.substring(0, 2);
    if (languages.indexOf(lang) === -1)
        languages.push(lang);

    // Document language
    lang = Banana.document.locale.substring(0, 2);
    if (languages.indexOf(lang) === -1)
        languages.push(lang);

    // Contacts languages
    let contactsLanguages = Object.getOwnPropertyNames(contactsLocalesGet());
    for (let i = 0; i < contactsLanguages.length; ++i) {
        lang = contactsLanguages[i];
        if (languages.indexOf(lang) === -1)
            languages.push(lang);
    }

    // Invoices languages
    let invoicesLanguages = invoicesLocalesGet();
    for (let i = 0; i < invoicesLanguages.length; ++i) {
        lang = invoicesLanguages[i];
        if (languages.indexOf(lang) === -1)
            languages.push(lang);
    }

    // Estimates languages
    let estimatesLanguages = estimatesLocalesGet();
    for (let i = 0; i < estimatesLanguages.length; ++i) {
        lang = estimatesLanguages[i];
        if (languages.indexOf(lang) === -1)
            languages.push(lang);
    }

    return languages;
}
