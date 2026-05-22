import QtQuick
import "qrezi_tools.js" as Tools

Item {

   readonly property variant qrezi_style: Tools.qrezi_style()

   width:   qrezi_style.slide_width
   height:  qrezi_style.slide_height
}
