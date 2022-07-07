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
import QtQuick.Controls

import "."

CheckBox {
   id: control
   indicator: Rectangle {
             implicitWidth: 22 * Stylesheet.pixelScaleRatio
             implicitHeight: 22 * Stylesheet.pixelScaleRatio
             radius: 2 * Stylesheet.pixelScaleRatio
             x: control.leftPadding
             y: parent.height / 2 - height / 2
             border.color: "#bdbebf"

             Image {
                anchors.fill: parent
                source: "check-mark.png"
                visible: control.checked
             }
         }
}


