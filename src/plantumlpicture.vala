/*
 * plantumlpicture.vala
 *
 * Copyright 2021 Nicola Tudino
 *
 * This file is part of xed-plantuml-plugin.
 *
 * xed-plantuml-plugin is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * xed-plantuml-plugin is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with xed-plantuml-plugin.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

namespace PlantUMLPlugin {

    public class PlantUMLPicture : Gtk.Box {

        // [Signal (run_last=true, type_none=true)]
        public signal void populate_popup (Gtk.Menu menu);

        private string src_path;
        private string png_path;
        private bool is_zoomed_to_fit = false;
        private bool is_grabbed = false;
        private bool is_in_progress = false;
        private Gtk.Image picture;
        private Gtk.ScrolledWindow scrolled_window;
        private Gtk.Spinner spinner;
        private Gtk.Box spinner_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        private double pixbuf_scale_factor = 1;

        public PlantUMLPicture (string src_path) {
            this.src_path = src_path;

            this.set_orientation (Gtk.Orientation.VERTICAL);

            this.picture = new Gtk.Image ();
            
            Gtk.EventBox event_box = new Gtk.EventBox ();
            event_box.add (this.picture);
            
            event_box.enter_notify_event.connect (this.on_enter_picture);
            event_box.leave_notify_event.connect (this.on_leave_picture);
            event_box.button_press_event.connect (this.on_grab_picture);
            event_box.button_release_event.connect (this.on_release_picture);

            this.scrolled_window = new Gtk.ScrolledWindow (null, null);
            this.scrolled_window.add (event_box);
            this.pack_start (this.scrolled_window, true, true, 0);

            this.spinner = new Gtk.Spinner ();
            this.spinner.set_size_request (32, 32);
            this.spinner_area.pack_start (spinner, false, false, 5);
            this.spinner_area.pack_start (new Gtk.Label (_("Generating picture")), false, false, 5);
            this.pack_start (this.spinner_area, false, false, 2);
            this.spinner_area.hide ();
        }

        public void generate_png (string src_path) {
            QueueElement element = QueueElement ();
            element.source_path = src_path;
            element.png_path = "";
            PlantUMLGenerator generator = new PlantUMLGenerator (element);
            
            this.png_path = generator.get_element ().png_path;
        }

        public bool on_enter_picture (Gtk.Widget event_box, Gdk.EventCrossing event) {
            Gdk.Cursor cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.HAND1);
            event_box.get_window ().set_cursor (cursor);
            return true;
        }

        public bool on_leave_picture (Gtk.Widget event_box, Gdk.EventCrossing event) {
            event_box.get_window ().set_cursor (null);
            return true;
        }

        public bool on_grab_picture (Gtk.Widget event_box, Gdk.EventButton event) {
            this.is_grabbed = true;
            if (event.button == 3) {
                this.grab_focus ();
                this.make_popup (event);
                return true;
            }
            return true;
        }

        public bool on_release_picture (Gtk.Widget event_box, Gdk.EventButton event) {
            this.is_grabbed = false;
            return true;
        }

        public void on_zoom (string direction) {
            if (this.png_path != null && !this.is_in_progress) {
                try {
                    this.set_zoom_fit (false);

                    Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file(png_path);
                    
                    int w = pixbuf.get_width ();
                    int h = pixbuf.get_height ();

                    if (direction == "IN") {
                        pixbuf_scale_factor = pixbuf_scale_factor  * 1.2;
                    } else if (direction == "OUT") {
                        pixbuf_scale_factor = pixbuf_scale_factor  * 0.8;
                    }
                    w = (int) (w * pixbuf_scale_factor);
                    h = (int) (h * pixbuf_scale_factor);
                    pixbuf = pixbuf.scale_simple (w, h, Gdk.InterpType.BILINEAR);

                    this.picture.clear ();
                    this.picture.set_from_pixbuf (pixbuf);
                } catch (GLib.Error e) {
                    print ("on_zoom error: " + e.message + "\n");
                }
            }
        }

        public void set_zoom_fit (bool zoom_fit_enable = false) {
            this.is_zoomed_to_fit = zoom_fit_enable;
            if (zoom_fit_enable) {
                this.pixbuf_scale_factor = 1;
            }
        }

        public bool get_zoom_fit () {
            return this.is_zoomed_to_fit;
        }

        public void set_in_progress () {
            this.is_in_progress = true;
            this.spinner_area.show ();
            this.spinner.start ();
        }

        public void update (string png_path) {
            this.png_path = png_path;
            this.is_in_progress = false;
            this.spinner.stop ();
            this.spinner_area.hide ();
            this.refresh_picture ();
        }

        public void refresh_picture () {
            if (this.png_path != null && !this.is_in_progress) {
                try {
                    Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file(png_path);
                    if (this.is_zoomed_to_fit) {
                        pixbuf = this.zoom_fit (pixbuf);
                    } else {
                        int w = (int) (pixbuf.get_width () * pixbuf_scale_factor);
                        int h = (int) (pixbuf.get_height () * pixbuf_scale_factor);
                        pixbuf = pixbuf.scale_simple (w, h, Gdk.InterpType.BILINEAR);
                    }

                    this.picture.clear ();
                    this.picture.set_from_pixbuf (pixbuf);
                } catch (GLib.Error e) {
                    print ("refresh_picture error: " + e.message + "\n");
                }
            }
        }

        public string get_src_path () {
            return this.src_path;
        }

        public string get_png_path () {
            return this.png_path;
        }

        public Gdk.Pixbuf zoom_fit (Gdk.Pixbuf pixbuf) {
            Gtk.Widget parent = (Gtk.Widget) this.picture.get_parent ();

            int par_w = parent.get_allocated_width ();
            int par_h = parent.get_allocated_height ();
            int pix_w = pixbuf.get_width ();
            int pix_h = pixbuf.get_height ();
            if (pix_w > par_w || pix_h > par_h) {
                int sf_w = par_w / pix_w;
                int sf_h = par_h / pix_h;
                int sf = (sf_w > sf_h)? sf_h : sf_w;
                int sc_w = pix_w * sf;
                int sc_h = pix_h * sf;
                if (sc_w > 0 && sc_h > 0) {
                    return pixbuf.scale_simple (sc_w, sc_h, Gdk.InterpType.BILINEAR);
                } else {
                    return pixbuf;
                }
            }
            
            return pixbuf;
        }

        public Gdk.Pixbuf get_picture_pixbuf () {
            return this.picture.get_pixbuf ();
        }
        
        private Gtk.Menu create_menu () {
            // Popup menu
            var menu = new Gtk.Menu ();

            this.populate_popup (menu);

            menu.show_all ();
            return menu;            
        }
        
        private void make_popup (Gdk.Event trigger_event) {
            var menu = this.create_menu ();
            menu.attach_to_widget (this, null);

            if (trigger_event != null) {
                menu.popup_at_pointer (trigger_event);
            } else {
                menu.popup_at_widget (this,
                            Gdk.Gravity.NORTH_WEST,
                            Gdk.Gravity.SOUTH_WEST,
                            null
                        );
                menu.select_first (true);
            }
        }
    }
}