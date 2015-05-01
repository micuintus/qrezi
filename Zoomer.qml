import QtQuick 2.2

Item {

   id: root

   width:  800
   height: 450

   default property alias items:  transformer.children

   property variant slides:         items
   property alias   current_frame:  transformer.current_frame
   property int     animation_time: 800


   function to_angle( rad )       { return 180 * rad / Math.PI }
   function to_rad( angle )       { return Math.PI * angle / 180 }
   function mod( x , m )          { return ( x%m + m ) % m }
   function bound_angle( angle )  { return mod( angle+180 , 360) - 180 }
   function hypotenuse( dx , dy ) { return Math.sqrt( dx*dx + dy*dy ) }


   Item {

      id: transformer

      anchors.fill: parent

      property variant current_frame:   canvas

      onCurrent_frameChanged: updateSlides()

      function get_rect(item) {
         var p00 = transformer.mapFromItem( item, 0, 0 )
         var p01 = transformer.mapFromItem( item, 0, item.height )
         var p11 = transformer.mapFromItem( item, item.width, item.height )

         return   { x:        p00.x
                  , y:        p00.y
                  , width:    p11.x-p00.x
                  , height:   p11.y-p00.y
                  , scale:    hypotenuse( p00.x - p01.x , p00.y - p01.y ) / item.height
                  , rotation: 180 - to_angle( Math.atan2( p00.x - p01.x , p00.y - p01.y ))
                  }
      }

      function updateSlides() {
         var s = current_frame
         var r = get_rect(current_frame)
         translator.x  =  -r.x + (root.width - r.width) / 2
         translator.y  =  -r.y + (root.height - r.height) / 2
         scaler.scale  =  1.0 / ( r.scale * Math.max( s.width / root.width, s.height / root.height ) )
         rotator.angle -= bound_angle( rotator.angle + r.rotation )
      }

      transform: [
         Translate {
            id: translator
            Behavior on x { NumberAnimation { duration: animation_time; easing.type: Easing.InOutCubic } id: xAni }
            Behavior on y { NumberAnimation { duration: animation_time; easing.type: Easing.InOutCubic } id: yAni }
         },
         Rotation {
            id: rotator
            origin.x: root.width/2
            origin.y: root.height/2
            Behavior on angle { NumberAnimation { duration: animation_time; easing.type: Easing.InOutCubic } id: rotAni }
         },
         Scale {
            id: scaler
            property real scale: 1
            xScale: scale
            yScale: scale
            origin.x: root.width/2
            origin.y: root.height/2
            Behavior on scale { NumberAnimation { duration: animation_time; easing.type: Easing.InOutCubic } id: scaleAni }
         }
      ]
   }



   MouseArea {
      anchors.fill: parent
      propagateComposedEvents: true

      property var  _canvas_pos:     Qt.point(0,0)
      property var  _mouse_pos:      Qt.point(0,0)
      property bool _started_moving: false

      onWheel: {
         scaleAni.enabled = false
         if (wheel.angleDelta.y < 0) scaler.scale /= 1. - 0.001 * wheel.angleDelta.y
         else                        scaler.scale *= 1. + 0.001 * wheel.angleDelta.y
         scaleAni.enabled = true
      }

      function item_at( item, p ) {
         var child = item.childAt( p.x, p.y )
         return child == null
                ? item
                : item_at( child, child.mapFromItem( item, p.x, p.y ) )
      }

      onClicked: {
         if ( ! _started_moving ) {
            var p = transformer.mapFromItem( this, mouse.x, mouse.y )
            var child = item_at( transformer, p )
            if ( child != null )  current_frame = child
            _started_moving = false
         }
      }

      onPressed: {
         _started_moving = false
         xAni.enabled = false
         yAni.enabled = false
         _canvas_pos = Qt.point( translator.x, translator.y ) 
         _mouse_pos = Qt.point( mouse.x, mouse.y )
         mouse.accepted = true
      }

      onReleased: {
         xAni.enabled = true
         yAni.enabled = true
      }

      onPositionChanged: {
         _started_moving = true
         var s = Math.sin( -to_rad( rotator.angle ))
         var c = Math.cos( -to_rad( rotator.angle ))
         var dx = mouse.x - _mouse_pos.x
         var dy = mouse.y - _mouse_pos.y
         translator.x = _canvas_pos.x + (c*dx - s*dy) / scaler.scale
         translator.y = _canvas_pos.y + (s*dx + c*dy) / scaler.scale
      }
   }

}
