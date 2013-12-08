// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE
 
  Copyright (C) 2013 Mario Guerriero <mario@elementaryos.org>
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as
  published    by the Free Software Foundation.
 
  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License along
  with this program.  If not, see <http://www.gnu.org/licenses>
 
  END LICENSE
***/

namespace Snap.Widgets {
 
    public class Camera : Gtk.DrawingArea {
        
        public enum ActionType {
            PHOTO = 0,
            VIDEO;
        }       
                
        public const int WIDTH = 640;
        public const int HEIGHT = 480;
        
        private ActionType type;
        
        private Gst.Element? camerabin = null;
        
        public class Camera () {
            this.set_size_request (WIDTH, HEIGHT); // FIXME
            
            this.realize.connect (() => {
               //this.get_window ().ensure_native ();
            });
           
            this.camerabin = Gst.ElementFactory.make ("camerabin","camera");
            this.camerabin.bus.add_watch (0,(bus,message) => {
                if (Gst.Video.is_video_overlay_prepare_window_handle_message (message))
                    (message.src as Gst.Video.Overlay).set_window_handle ((uint*) Gdk.X11Window.get_xid (this.get_window()));
                return true;
            });
            
            var preview_caps = Gst.Caps.from_string ("video/x-raw, format=\"rgb\", width = (int) %d, height = (int) %d".printf (WIDTH, HEIGHT));
            this.camerabin.set ("preview-caps", preview_caps);
            
            this.show_all ();
            this.play ();
        }
        
        public void set_action_type (ActionType type) {
            this.type = type;
        }
       
        public void play () {
            this.camerabin.set_state (Gst.State.PLAYING);  
        }
       
        public void stop () {
            this.camerabin.set_state (Gst.State.NULL);  
        }
    }
}
