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
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "./components"

Item {
    id: root

    required property AppSettings appSettings

    // Style properties
    property int stylePropertyWidth: 200 * Stylesheet.pixelScaleRatio
    property int styleButtonMinWidth: 140 * Stylesheet.pixelScaleRatio
    property int styleSectionSeparatorHeight: 4 * Stylesheet.defaultMargin
    property int styleColumnSpacing: 2.5 * Stylesheet.defaultMargin
    property int styleRowSpacing: 0.5 * Stylesheet.defaultMargin


    VatModesModel {
        id: vatModesModel
    }

    ScrollView {
        id: scrollView
        clip: true

        anchors.fill: parent
        anchors.margins: Stylesheet.defaultMargin
        //anchors.topMargin: styleSectionSeparatorHeight / 2

        ColumnLayout {
            width: scrollView.availableWidth
            height: scrollView.availableHeight

            ColumnLayout {
                Layout.fillWidth: true

                StyledLabel{
                    text: qsTr("New documents")
                    font.bold: true
                }

                RowLayout {
                    Layout.topMargin: styleSectionSeparatorHeight / 2

                    StyledLabel{
                        text: qsTr("Invoice title")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.invoice_title
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.invoice_title = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Estimate title")
                        Layout.fillWidth: true
                    }
                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.estimate_title
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.estimate_title = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Vat mode")
                        Layout.fillWidth: true
                    }

                    StyledComboBox {
                        implicitWidth: stylePropertyWidth

                        model: vatModesModel
                        editable: false
                        textRole: "descr"
                        currentIndex: getVatModeIndex(appSettings.data.new_documents.vat_mode)

                        onActivated: {
                            appSettings.data.new_documents.vat_mode = vatModesModel.get(index).mode
                            appSettings.modified = true
                        }

                        function getVatModeIndex(vatMode) {
                            for (var i = 0; i < vatModesModel.count; i++) {
                                if (vatModesModel.get(i).mode === vatMode) {
                                    return i
                                }
                            }
                            return 0;
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Currency")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.currency
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.currency = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Decimals")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.decimals_amounts.toString()
                        validator: IntValidator{bottom: 0; top: 24;}
                        onEditingFinished: {
                            if (modified) {
                                let decimals = Number(text)
                                if (Number.isNaN(decimals)) {
                                    text: appSettings.data.new_documents.decimals_amounts.toString()
                                } else {
                                    appSettings.data.new_documents.decimals_amounts = decimals
                                    appSettings.modified = true
                                }
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Total rounding")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.rounding_total
                        validator: DoubleValidator{bottom: 0.00; top: 1.00; decimals: 24;}
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.rounding_total = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Invoice payment term")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.payment_term_days
                        validator: IntValidator{bottom: 0; top: 3650;}
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.payment_term_days = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Estimate validity")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        implicitWidth: stylePropertyWidth
                        text: appSettings.data.new_documents.estimate_validity_days
                        validator: IntValidator{bottom: 0; top: 3650;}
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.new_documents.estimate_validity_days = text
                                appSettings.modified = true
                                focus = false
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: styleSectionSeparatorHeight / 2
                Layout.bottomMargin: styleSectionSeparatorHeight / 2
                height: 1
                color: Stylesheet.buttonColor
            }

            ColumnLayout {
                width: scrollView.availableWidth
                height: scrollView.availableHeight

                StyledLabel{
                    text: qsTr("Interface")
                    font.bold: true
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight / 2

                    StyledLabel{
                        text: qsTr("Views")
                        font.bold: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Title")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        property string viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.getSettingsViewTitle(viewId)
                        placeholderText: appSettings.getDefaultViewTitle(viewId)
                        onEditingFinished:  {
                            if (modified) {
                                appSettings.setViewTitle(viewId, text)
                                focus = false
                            }
                        }
                    }

                    StyledTextField {
                        property string viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.getSettingsViewTitle(viewId)
                        placeholderText: appSettings.getDefaultViewTitle(viewId)
                        onEditingFinished:  {
                            if (modified) {
                                appSettings.setViewTitle(viewId, text)
                                focus = false
                            }
                        }
                    }

                    StyledTextField {
                        property string viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.getSettingsViewTitle(viewId)
                        placeholderText: appSettings.getDefaultViewTitle(viewId)
                        onEditingFinished:  {
                            if (modified) {
                                appSettings.setViewTitle(viewId, text)
                                focus = false
                            }
                        }
                    }

                    StyledLabel{
                        text: qsTr("Visible")
                        Layout.fillWidth: true
                    }

                    Switch {
                        property string viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: styleSectionSeparatorHeight
                        checked: appSettings.isViewVisible(viewId)
                        onToggled: appSettings.setViewVisible(viewId, checked)
                    }

                    Switch {
                        property string viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: styleSectionSeparatorHeight
                        checked: appSettings.isViewVisible(viewId)
                        onToggled: appSettings.setViewVisible(viewId, checked)
                    }

                    Switch {
                        property string viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: styleSectionSeparatorHeight
                        checked: appSettings.isViewVisible(viewId)
                        onToggled: appSettings.setViewVisible(viewId, checked)
                    }

                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: styleSectionSeparatorHeight / 2
                Layout.bottomMargin: styleSectionSeparatorHeight / 2
                height: 1
                color: Stylesheet.buttonColor
            }

            ColumnLayout {
                width: scrollView.availableWidth
                height: scrollView.availableHeight

                StyledLabel{
                    text: qsTr("Invoice fields")
                    font.bold: true
                    Layout.bottomMargin: styleRowSpacing
                }

                StyledLabel{
                    text: qsTr("In this section you can select whitch fields are visibles.")
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("General")
                        font.bold: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Fields not empties")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_fields_if_not_empty"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_fields_if_not_empty"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_fields_if_not_empty"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Parameters")
                        font.bold: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Decimals")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_decimals"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_decimals"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_decimals"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Total rounding")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding_totals"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding_totals"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding_totals"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Language")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_language"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_language"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_language"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Currency")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_currency"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_currency"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_currency"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Vat mode")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_vat_mode"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_vat_mode"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_vat_mode"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Details")
                        font.bold: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Invoice number")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_number"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_number"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_number"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Invoice date")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_date"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_date"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_date"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Due date")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_due_date"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_due_date"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_due_date"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Order number")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_number"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_number"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_number"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Order date")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_date"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_date"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_order_date"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Customer reference")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_reference"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_reference"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_reference"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Invoice title")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_title"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_title"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_title"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Begin text")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_begin_text"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_begin_text"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_begin_text"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("End text")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_end_text"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_end_text"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_end_text"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Internal notes")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_internal_notes"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_internal_notes"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_internal_notes"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Invoice summary")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Address")
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Customer selector")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_selector"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_selector"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_customer_selector"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Business name")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_business"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_business"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_business"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Courtesy")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_courtesy"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_courtesy"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_courtesy"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("First and last name")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_first_and_last_name"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_first_and_last_name"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_first_and_last_name"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Address street")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_street"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_street"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_street"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Address extra")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_extra"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_extra"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_extra"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Post box")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_postbox"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_postbox"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_postbox"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Country and locality")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_country_and_locality"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_country_and_locality"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_country_and_locality"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Email and phone")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_phone_and_email"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_phone_and_email"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_phone_and_email"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Vat and fiscal number")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_vat_and_fiscal_number"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_vat_and_fiscal_number"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_address_vat_and_fiscal_number"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Items")
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Invoice items visible without scolling (0 = all items)")
                        Layout.fillWidth: true
                    }

                    StyledTextField {
                        property string flagId: "invoce_max_visible_items_without_scrolling"
                        property string viewId: appSettings.view_id_base
                        validator: IntValidator{bottom: 0; top: 1024;}
                        horizontalAlignment: Qt.AlignRight
                        Layout.minimumWidth: styleSectionSeparatorHeight
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.data.interface.invoice.views[viewId].appearance[flagId] ?
                                  appSettings.data.interface.invoice.views[viewId].appearance[flagId].toString() : "0"
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.interface.invoice.views[viewId].appearance[flagId] = Number(text)
                                appSettings.signalItemsVisibilityChanged++
                            }
                            focus = false
                        }

                    }

                    StyledTextField {
                        property string flagId: "invoce_max_visible_items_without_scrolling"
                        property string viewId: appSettings.view_id_short
                        validator: IntValidator{bottom: 0; top: 1024;}
                        horizontalAlignment: Qt.AlignRight
                        Layout.minimumWidth: styleSectionSeparatorHeight
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.data.interface.invoice.views[viewId].appearance[flagId] ?
                                  appSettings.data.interface.invoice.views[viewId].appearance[flagId].toString() : "0"
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.interface.invoice.views[viewId].appearance[flagId] = Number(text)
                                appSettings.signalItemsVisibilityChanged++
                            }
                            focus = false
                        }

                    }

                    StyledTextField {
                        property string flagId: "invoce_max_visible_items_without_scrolling"
                        property string viewId: appSettings.view_id_long
                        validator: IntValidator{bottom: 0; top: 1024;}
                        horizontalAlignment: Qt.AlignRight
                        Layout.minimumWidth: styleSectionSeparatorHeight
                        Layout.alignment: Qt.AlignHCenter
                        text: appSettings.data.interface.invoice.views[viewId].appearance[flagId] ?
                                  appSettings.data.interface.invoice.views[viewId].appearance[flagId].toString() : "0"
                        onEditingFinished: {
                            if (modified) {
                                appSettings.data.interface.invoice.views[viewId].appearance[flagId] = Number(text)
                                appSettings.signalItemsVisibilityChanged++
                            }
                            focus = false
                        }

                    }

                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Item columns")
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Row")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_row_number"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_row_number"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_row_number"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Number")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_number"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_number"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_number"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: addLicenseRequirementText(qsTr("Item date"), "show_invoice_item_column_date")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_date"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_date"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_date"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Quantity")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_quantity"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_quantity"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_quantity"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Unit")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_unit"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_unit"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_unit"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: addLicenseRequirementText(qsTr("Discount"), "show_invoice_item_column_discount")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_discount"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_discount"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_item_column_discount"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                GridLayout {
                    columns: 4
                    columnSpacing: styleColumnSpacing
                    rowSpacing: styleRowSpacing
                    Layout.topMargin: styleSectionSeparatorHeight

                    StyledLabel{
                        text: qsTr("Totals")
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.bottomMargin: styleRowSpacing
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_base)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_short)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: appSettings.getViewTitle(appSettings.view_id_long)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Discount")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_discount"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_discount"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_discount"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Rounding")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_rounding"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Deposit")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_deposit"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_deposit"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_deposit"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledLabel{
                        text: qsTr("Summary")
                        Layout.fillWidth: true
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_base
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_short
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledSwitch {
                        flagId: "show_invoice_summary"
                        viewId: appSettings.view_id_long
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: styleSectionSeparatorHeight / 2
                Layout.bottomMargin: styleSectionSeparatorHeight / 2
                height: 1
                color: Stylesheet.buttonColor
            }

            ColumnLayout {
                width: scrollView.availableWidth
                height: scrollView.availableHeight

                StyledLabel{
                    text: qsTr("Tools")
                    font.bold: true
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    visible: appSettings.isInternalVersion()

                    StyledLabel{
                        text: qsTr("Edit current settings")
                        Layout.fillWidth: true
                    }

                    StyledButton {
                        text: qsTr("Edit settings")
                        Layout.minimumWidth: styleButtonMinWidth
                        onClicked: {
                            dlgEditSettings.text = JSON.stringify(appSettings.data, null, "   ")
                            dlgEditSettings.format = "json";
                            dlgEditSettings.isModified = false
                            dlgEditSettings.visible = true
                        }
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Restore default settings")
                        Layout.fillWidth: true
                    }

                    StyledButton {
                        text: qsTr("Restore settings")
                        Layout.minimumWidth: styleButtonMinWidth
                        onClicked: restoreSettingsConfirmationDialog.visible = true
                    }
                }

                RowLayout {
                    StyledLabel{
                        text: qsTr("Clear settings")
                        Layout.fillWidth: true
                    }

                    StyledButton {
                        text: qsTr("Clear settings")
                        Layout.minimumWidth: styleButtonMinWidth
                        onClicked: clearSettingsConfirmationDialog.visible = true
                    }
                }
            }

        }
    }

    DlgEditSource {
        id: dlgEditSettings
        height: root.height - 50 * Stylesheet.pixelScaleRatio
        width: root.width - 200 * Stylesheet.pixelScaleRatio
        modality: Qt.WindowModal
        font.family: "Courier"

        onAccepted: {
            try {
                let newSettings = JSON.parse(text)
                appSettings.setSettings(newSettings)
                visible = false
            } catch (err) {
                errorMessageDialog.text = err.message()
                errorMessageDialog.visible = true
            }
        }
    }

    SimpleMessageDialog {
        id: errorMessageDialog
        visible: false
    }

    SimpleMessageDialog {
        id: restoreSettingsConfirmationDialog
        visible: false
        text: qsTr("Are you sure you want to restore the default settings?")
        standardButtons: Dialog.RestoreDefaults | Dialog.Cancel
        onReset: {
            appSettings.resetSettings()
            visible = false
        }
    }

    SimpleMessageDialog {
        id: clearSettingsConfirmationDialog
        visible: false
        text: qsTr("Are you sure you want to clear the settings?")
        standardButtons: Dialog.RestoreDefaults | Dialog.Cancel
        onReset: {
            appSettings.clearSettings()
            visible = false
        }
    }

    function addLicenseRequirementText(text, fieldId) {
        if (!appSettings.meetInvoiceFieldLicenceRequirement(fieldId)) {
            return text + " (" + qsTr("Advanced plan") + ")"
        }
        return text
    }

    function meetLicenceRequirement(fieldId) {
        return appSettings.meetInvoiceFieldLicenceRequirement(fieldId)
    }

}
