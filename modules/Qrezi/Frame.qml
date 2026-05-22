import QtQuick
import "qrezi_tools.js" as Tools

Item {

   readonly property variant qrezi_style: Tools.qrezi_style()

   property Item background: null
   onBackgroundChanged: { if (background) background.parent = background_holder }

   Item {
      id: background_holder
      anchors.fill: parent
   }

   width:   qrezi_style.slide_width
   height:  qrezi_style.slide_height
}
