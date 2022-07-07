/*
 * plantumlmanager.vala
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

    public class PlantUMLManager {
        
        public static string[] SUPPORTED_SOURCE_FILE_EXTENSIONS = {".puml", ".plantuml", ".uml"};
        private PlantUMLController controller;
        private Xed.TabState active_tab_state;
        private Xed.Window _window;

        public PlantUMLManager (Xed.Window window) {
            this._window = window;            
            Xed.Panel bottom = window.get_bottom_panel ();
            PlantUMLNotebook notebook = new PlantUMLNotebook ();

            controller = new PlantUMLController (notebook);

            this.track_tab_changes (window);
            foreach (var doc in window.get_documents ()) {
                this.track_document_changes (doc);
            }

            this.track_page_changes (window, notebook);
            notebook.show_all ();
            bottom.add_item (notebook, _("PlantUML"), "system-software-install");
            bottom.set_size_request (-1, 150);
        }

        public void track_tab_changes (Xed.Window window) {
            window.active_tab_changed.connect (this.on_active_tab_changed);
            window.active_tab_state_changed.connect (this.on_active_tab_state_changed);
            window.tab_removed.connect (this.on_tab_removed);
        }

        public void track_document_changes (Xed.Document document) {
            document.saved.connect (this.on_document_saved);
        }

        public void on_document_saved (Xed.Document document) {
            string path = document.get_uri_for_display ();
            if (this.is_plantuml_file (path)) {
                controller.file_saved (path);
            }
        }

        public void on_active_tab_changed (Xed.Window window, Xed.Tab tab) {
            string path = tab.get_document ().get_uri_for_display ();
            if (this.is_plantuml_file (path)) {
                controller.set_active_file (path);
            }
            active_tab_state = tab.get_state ();
        }
        
        public void on_active_tab_state_changed (Xed.Window window) {
            Xed.Tab tab = window.get_active_tab ();
            Xed.TabState new_tab_state = tab.get_state ();
            if (new_tab_state == Xed.TabState.STATE_NORMAL) {
                if ( (this.active_tab_state == Xed.TabState.STATE_LOADING) ||
                     (this.active_tab_state == Xed.TabState.STATE_SAVING)) {
                        Xed.Document doc = tab.get_document ();
                        string path = doc.get_uri_for_display ();

                        if (this.is_plantuml_file (path) && !controller.is_present (path)) {
                            controller.add_file (path);
                            controller.set_active_file (path);
                            this.track_document_changes (doc);
                        }
                }
            }
            this.active_tab_state = new_tab_state;
        }
        
        public void on_tab_removed (Xed.Window window, Xed.Tab tab) {
            string path = tab.get_document ().get_uri_for_display ();
            if (is_plantuml_file (path)) {
                controller.remove_file (path);
            }
        }

        public bool is_plantuml_file (string filepath) {
            foreach (var extension in PlantUMLManager.SUPPORTED_SOURCE_FILE_EXTENSIONS) {
                if (filepath.has_suffix (extension)) {
                    return true;
                }
            }
            return false;
        }

        public void track_page_changes (Xed.Window window, Gtk.Notebook notebook) {
            window.active_tab_changed.connect (this.on_active_tab_changed);
            notebook.switch_page.connect (this.on_page_changed);
        }

            
        public void on_page_changed (Gtk.Notebook notebook, Gtk.Widget page, uint page_num) {
            PlantUMLPicture picture = (PlantUMLPicture) page;
            string src_path = picture.get_src_path ();
            Xed.Tab tab = this._window.get_tab_from_location (GLib.File.new_for_path (src_path));
            this._window.set_active_tab (tab);
        }
    }
}