/*
 * plantumlcontroller.vala
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

    public class PlantUMLController {

        private Gee.ArrayList<string> sources = new Gee.ArrayList<string> ();
        private PlantUMLNotebook _notebook;

        public PlantUMLController (PlantUMLNotebook notebook) {
            this._notebook = notebook;
        }

        public void add_file (string src_path) {
            if (!is_present (src_path)) {
                sources.add (src_path);
                PlantUMLPicture picture = new PlantUMLPicture (src_path);
                this._notebook.add_picture (picture, src_path, GLib.Path.get_basename(src_path));
                this._notebook.show_all ();
                picture.populate_popup.connect (this.on_picture_populate_popup);  
            }
        }

        public void remove_file (string src_path) {
            if (is_present (src_path)) {
                sources.remove (src_path);
                int page_index = this._notebook.get_picture_exists (src_path);
                PlantUMLPicture picture = (PlantUMLPicture) this._notebook.get_nth_page (page_index);
                this._notebook.remove_page (page_index);
                picture.destroy ();
                this._notebook.show_all ();
            }
        }

        public void set_active_file (string src_path) {
            if (is_present (src_path)) {
                this._notebook.set_current_page (this._notebook.get_picture_exists (src_path));
            } else {
                this.add_file (src_path);
            }
        }

        public void file_saved (string src_path) {
            if (is_present (src_path)) {
                this._notebook.update (src_path);
            } else {
                this.add_file (src_path);
            }
        }

        public bool is_present (string path) {
            return sources.contains (path);
        }

        public Gee.ArrayList<string> get_sources () {
            return sources;
        }

        private void on_picture_populate_popup (PlantUMLPicture picture, Gtk.Menu menu) {

            Gtk.MenuItem zoom_fit = new Gtk.MenuItem ();
            Gtk.Box zoom_fit_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            zoom_fit_box.pack_start (new Gtk.Image.from_icon_name ("zoom-fit-best-symbolic", Gtk.IconSize.MENU), false, false, 4);
            zoom_fit_box.pack_start (new Gtk.Label (_("Zoom fit")), false, false, 4);
            zoom_fit.add (zoom_fit_box);
            // zoom_fit.set_label (_("Zoom fit"));
            zoom_fit.activate.connect (() => {
                picture.set_zoom_fit (true);
                picture.update (picture.get_png_path ());
                this._notebook.show_all ();
            });
            menu.append (zoom_fit);

            Gtk.MenuItem zoom_in = new Gtk.MenuItem ();
            Gtk.Box zoom_in_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            zoom_in_box.pack_start (new Gtk.Image.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU), false, false, 4);
            zoom_in_box.pack_start (new Gtk.Label (_("Zoom in")), false, false, 4);
            zoom_in.add (zoom_in_box);
            // zoom_in.set_label (_("Zoom in"));
            zoom_in.activate.connect (() => {
                picture.on_zoom ("IN");
                this._notebook.show_all ();
            });
            menu.append (zoom_in);

            Gtk.MenuItem zoom_out = new Gtk.MenuItem ();
            Gtk.Box zoom_out_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            zoom_out_box.pack_start (new Gtk.Image.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU), false, false, 4);
            zoom_out_box.pack_start (new Gtk.Label (_("Zoom out")), false, false, 4);
            zoom_out.add (zoom_out_box);
            // zoom_out.set_label (_("Zoom out"));
            zoom_out.activate.connect (() => {
                picture.on_zoom ("OUT");
                this._notebook.show_all ();
            });
            menu.append (zoom_out);

            menu.append (new Gtk.SeparatorMenuItem ());

            Gtk.MenuItem close_picture = new Gtk.MenuItem ();
            Gtk.Box close_picture_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            close_picture_box.pack_start (new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU), false, false, 4);
            close_picture_box.pack_start (new Gtk.Label (_("Close")), false, false, 4);
            close_picture.add (close_picture_box);
            // close_picture.set_label (_("Close"));
            close_picture.activate.connect (this.on_close_picture);
            close_picture.set_sensitive (this._notebook.get_n_pages () > 0);
            menu.append (close_picture);
        }

        private void on_close_picture () {
            if (this._notebook.get_n_pages () > 1) {
                int cur_page = this._notebook.get_current_page ();
                PlantUMLPicture picture = (PlantUMLPicture) this._notebook.get_nth_page (cur_page);
                this.remove_file (picture.get_src_path ());
            }
        }
    }
}