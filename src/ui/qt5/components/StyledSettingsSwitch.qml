// See the License for the specific language governing permissions and
// limitations under the License.
import QtQuick 2.15
import QtQuick.Controls 2.15

import "." 1.0

StyledSwitch {
    required property string flagId
    required property string viewId
    checked: appSettings.getInvoiceFieldVisible(flagId, viewId)
    onToggled: appSettings.setInvoiceFieldVisible(flagId, viewId, checked)
}
