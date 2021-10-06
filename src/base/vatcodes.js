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

function vatCodeGet(id) {

    if (id) {
        var tableVatCodes = vatCodesTableGet();
        if (tableVatCodes) {
            var vatCodeRow = tableVatCodes.findRowByValue("RowId", id);
            if (vatCodeRow) {
                var vatCode = {
                    'rate': vatCodeRow.value("VatPercentage"),
                    'code': vatCodeRow.value("RowId")
                };
                return vatCode;
            }
        }
    }

    return null;
}

function vatCodesGet() {
    var table = vatCodesTableGet()
    var items = [];
    for (var i = 0; i < table.rowCount; ++i) {
        var id = table.value(i, "RowId")
        if (id) {
            items.push(
                        {
                            'rate': table.value(i, "VatPercentage"),
                            'code': table.value(i, "RowId")
                        })
        }
    }
    return items;
}

function vatCodesTableGet() {
    return Banana.document.table("VatCodes");
}



