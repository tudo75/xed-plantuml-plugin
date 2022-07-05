/*
 * plantumlnotebook.vala
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

    public class PlantUMLNotebook : Gtk.Notebook {

        public PlantUMLNotebook () {
            this.set_show_tabs (true);
            this.set_scrollable (false);

            this.set_tab_pos (Gtk.PositionType.BOTTOM);
            this.popup_enable ();

            this.size_allocate.connect (this.on_resize);
        }

        public void on_resize (Gtk.Widget widget, Gtk.Allocation allocation) {
            this.refresh_current_picture ();
        }

        public void add_picture (PlantUMLPicture picture, string src_path, string title) {
            int index = this.get_picture_exists (src_path);
            if ( index == -1) {
                picture.set_in_progress ();
                picture.generate_png (src_path);
                Gtk.Label label = new Gtk.Label (title);
                label.set_tooltip_text (src_path);
                this.append_page (picture, label);
                this.set_active_picture (src_path);
                this.refresh_current_picture ();
            }
        }

        public void remove_picture (string src_path) {
            int index = this.get_picture_exists (src_path);
            if (index >= 0) {
                this.remove_page (index);
            }
        }

        public void update (string src_path) {
            int index = this.get_picture_exists (src_path);
            if (index >= 0) {
                PlantUMLPicture picture = (PlantUMLPicture) this.get_nth_page (index);
                picture.set_in_progress ();
                picture.generate_png (src_path);
                this.set_active_picture (src_path);
                this.refresh_current_picture ();
            }
        }

        public PlantUMLPicture get_active_picture () {
            int page_num = this.get_current_page ();
            if (page_num >= 0) {
                PlantUMLPicture picture = (PlantUMLPicture) this.get_nth_page (page_num);
                return picture;
            }
            PlantUMLPicture pic = null;
            return pic;
        }

        public int set_active_picture (string src_path) {
            int index = this.get_picture_exists (src_path);
            if (index >= 0) {
                this.set_current_page (index);
                this.refresh_current_picture ();
            }
            return index;
        }

        public int get_picture_exists (string src_path) {
            int index = -1;
            for (int i = 0; i < this.get_n_pages (); i++) {
                PlantUMLPicture picture = (PlantUMLPicture) this.get_nth_page (i);
                if (src_path == picture.get_src_path ()) {
                    index = i;
                }
            }
            return index;
        }

        public void refresh_current_picture () {
            int page_num = this.get_current_page ();
            if (page_num >= 0) {
                PlantUMLPicture picture = (PlantUMLPicture) this.get_nth_page (page_num);
                picture.update (picture.get_png_path ());
            }
        }

        public void set_zoom_fit (bool zoom_fit_enable = false) {
            PlantUMLPicture picture = this.get_active_picture ();
            picture.set_zoom_fit (zoom_fit_enable);
            this.refresh_current_picture ();
        }

        public bool get_zoom_fit () {
            PlantUMLPicture picture = this.get_active_picture ();
            return picture.get_zoom_fit ();
        }
    }
}