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

import "./components" 1.0

Item {
    id: dialog

    property bool isModified: false
    property bool isReadOnly: false

    property alias text: sourceTextArea.text
    property bool error: false
    property string errorMessage: ""
    property int errorLine: -1

    property string format: ""

    signal revertRequested()

    function clearError() {
        error = false
        errorMessage = ""
        errorLine = -1
    }

    function setError(msg, line) {
        error = true
        errorMessage = msg
        errorLine = line
    }

    Item {
        focus: true // to enable key events handling
        anchors.fill: parent

        ColumnLayout {
            focus: true // to enable key events handling
            anchors.fill: parent
            anchors.margins: Stylesheet.defaultMargin

            StyledLabel {
                id: labelError
                visible: error
                text: qsTr("Line: ") + errorLine + ", " + errorMessage
            }

            StyledScrollableTextArea {
                id: sourceTextArea
                Layout.fillHeight: true
                Layout.fillWidth: true
                readOnly: isReadOnly
                onTextEdited: {
                    isModified = true
                }
            }

            RowLayout {
                Layout.bottomMargin: 5 * Stylesheet.pixelScaleRatio
                Layout.fillWidth: true

                SearchBar {
                    id: searchBar
                    Layout.fillWidth: true
                    textControl: sourceTextArea
                    visible: false
                }

                Item {
                    Layout.fillWidth: true
                    visible: !searchBar.visible
                }

                StyledButton {
                    text: qsTr("Revert")
                    Layout.leftMargin: 5 * Stylesheet.pixelScaleRatio
                    visible: isModified
                    onClicked: revertRequested()
                }
            }

            Shortcut {
                sequence: StandardKey.Find
                onActivated: {
                    searchBar.visible = true
                }
            }


        }
    }

    function showHelp() {
        Banana.Ui.showHelp("dlginvoicesource");
    }

}
