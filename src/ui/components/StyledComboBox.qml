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

import "../../base/utils.js" as Utils

ComboBox {
    id: control
    implicitHeight: 28 * Stylesheet.pixelScaleRatio
    indicator.width: 20 * Stylesheet.pixelScaleRatio
    indicator.height: 20 * Stylesheet.pixelScaleRatio

    property int popupMinWidth: 0
    property int popupAlign: Qt.AlignLeft
    property bool modified: false
    property bool displayTextIncludesKey: true
    property string lastFilterText: ""

    signal editingFinished(text: string)
    signal textEdited(text: string)

    property ListModel filteredModel
    property var unfilteredModel: null
    property bool filterRunning: false
    property bool filterEnabled: false

    onActivated: {
        textField.ensureVisible(0)
    }

    onTextEdited: function(text) {
        if (!popup.visible) {
            popup.open()
        }

        if (filterEnabled) {
            filterModelTimer.restart()
        }
    }

    background: Rectangle {
        color: Stylesheet.baseColor
        border.width: 1
        border.color: "#bdbebf"
        radius: 2.0 * Stylesheet.pixelScaleRatio
    }

    contentItem: StyledTextField {
        id: textField
        readOnly: !control.editable
        text: control.displayText

        onEditingFinished: {
            control.modified = modified
            control.editingFinished(text)
        }

        onTextEdited: {
            control.textEdited(text)
            control.updateCurrentIndex(text)
        }

        onFocusChanged: {
            if (focus) {
                popup.open()
                updateCurrentIndex(displayText)
            }
        }
    }

    popup: Popup {
        x: popupAlign === Qt.AlignRight ? (width > control.width ? control.width - width : 0) : 0
        y: control.height - 1 * Stylesheet.pixelScaleRatio
        width: !control.model || control.model.count === 0 ? 0 : Math.max(control.width, popupMinWidth)
        padding: 1 * Stylesheet.pixelScaleRatio

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: Math.min(200 * Stylesheet.pixelScaleRatio, contentHeight)
            model: control.popup.visible ? control.delegateModel : null
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: Stylesheet.baseColor
            border.color: "#354793"
            radius: 2 * Stylesheet.pixelScaleRatio
        }

        onOpened: {
            updateCurrentIndex(displayText)
        }
    }

    delegate: ItemDelegate {
        text: displayTextIncludesKey ? key + "\t" + descr : descr
        width: listView.width
        font.bold: control.currentIndex === index
        highlighted: control.highlightedIndex === index
    }

    Timer {
        id: filterModelTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (filterEnabled) {
                if (!filterRunning) {
                    filterModel()
                } else {
                    restart()
                }
            }
        }
    }

    function updateCurrentIndex(text) {
        let index = findPartialKey(text)
        if (index >= 0) {
            currentIndex = index
            listView.positionViewAtIndex(index, ListView.Beginning)
        } else {
            currentIndex = -1
            listView.positionViewAtIndex(0, ListView.Beginning)
        }
    }

    function filterModel() {
        if (!filterEnabled)
            return

        filterRunning = true

        let text = control.editText

        if (!text.toLowerCase().startsWith(lastFilterText)) {
            if (unfilteredModel) {
                model = unfilteredModel
                unfilteredModel = null
            }
        }
        lastFilterText = text

        if (!text || findPartialKey(text) >= 0) {
            if (unfilteredModel) {
                model = unfilteredModel
                unfilteredModel = null
            }
        } else {
            if (!unfilteredModel) {
                unfilteredModel = model
            }
            filteredItemsModel.clear()
            for (let i = 0; i < unfilteredModel.count; ++i) {
                let obj = unfilteredModel.get(i);
                if (Utils.textMatchSearch(obj.descr, text)) {
                    filteredItemsModel.append(obj)
                } else if (obj.search && Utils.textMatchSearch(obj.search, text)) {
                    filteredItemsModel.append(obj)
                }
            }
            model = filteredItemsModel
         }

        filterRunning = false
    }

    function findKey(key) {
        if (!model || !key || key.length === 0) {
            return -1;
        }

        for (let i = 0; i < model.count; ++i) {
            let obj = model.get(i);
            if (obj.key === key) {
                return i;
            }
        }
        return -1;
    }

    function findPartialKey(key) {
        if (!model || !key || key.length === 0) {
            return 0;
        }

        for (let i = 0; i < model.count; ++i) {
            let obj = model.get(i);
            if (obj.key.startsWith(key)) {
                return i;
            }
        }
        return -1;
    }

}
