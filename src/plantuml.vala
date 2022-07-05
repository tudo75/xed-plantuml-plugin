/*
 * plantuml.vala
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

    /*
    * Register plugin extension types
    */
    [CCode (cname="G_MODULE_EXPORT peas_register_types")]
    [ModuleInit]
    public void peas_register_types (TypeModule module) 
    {
        var objmodule = module as Peas.ObjectModule;

        // Register my plugin extension
        objmodule.register_extension_type (typeof (Xed.AppActivatable), typeof (PlantUMLPlugin.PlantUMLApp));
        objmodule.register_extension_type (typeof (Xed.WindowActivatable), typeof (PlantUMLPlugin.PlantUMLWindow));
        // Register my config dialog
        objmodule.register_extension_type (typeof (PeasGtk.Configurable), typeof (PlantUMLPlugin.ConfigPlantUML));
    }

    /*
    * AppActivatable
    */
    public class PlantUMLApp : Xed.AppActivatable, Peas.ExtensionBase {


        public PlantUMLApp () {
            GLib.Object ();
        }

        public Xed.App app {
            owned get; construct;
        }

        public void activate () {
            // print ("PlantUMLApp activated\n");

        }

        public void deactivate () {
            // print ("PlantUMLApp deactivated\n");
        }
    }

    /*
    * WindowActivatable
    */
    public class PlantUMLWindow : Xed.WindowActivatable, Peas.ExtensionBase {
        
        private GLib.Settings settings = new GLib.Settings ("com.github.tudo75.xed-plantuml-plugin");
        private bool ENABLE_PLANTUML;
        private PlantUMLPlugin.PlantUMLManager manager = null;

        public PlantUMLWindow () {
            GLib.Object ();
        }

        public Xed.Window window {
            owned get; construct;
        }

        public void activate () {
            // print ("PlantUMLWindow activated\n");
            ENABLE_PLANTUML = this.settings.get_boolean ("enable-plantuml");
            
            if (Thread.supported () == false) {
                print ("Threads are NOT supported!\n");
            } else {
                if (ENABLE_PLANTUML) {
                    manager = new PlantUMLPlugin.PlantUMLManager (window);
                }
            }
        }

        public void deactivate () {
            // print ("PlantUMLWindow deactivated\n");
            manager = null;
        }

        public void update_state () {
            // print ("PlantUMLWindow update_state\n");
        }
    }

    /*
    * Plugin config dialog
    */
    public class ConfigPlantUML : Peas.ExtensionBase, PeasGtk.Configurable {

        private GLib.Settings settings = new GLib.Settings ("com.github.tudo75.xed-plantuml-plugin");
        private Gtk.Entry entry;
        private Gtk.Widget parent;
        private bool thread_support = false;

        public ConfigPlantUML () {
            GLib.Object ();
        }

        public Gtk.Widget create_configure_widget () {

            var label = new Gtk.Label ("");
            label.set_markup (_("<big>Xed PlantUML Plugin Settings</big>"));
            label.set_margin_top (10);
            label.set_margin_bottom (15);
            label.set_margin_start (10);
            label.set_margin_end (10);

            int grid_row = 0;

            Gtk.Grid main_grid = new Gtk.Grid ();
            main_grid.set_valign (Gtk.Align.START);
            main_grid.set_margin_top (10);
            main_grid.set_margin_bottom (10);
            main_grid.set_margin_start (10);
            main_grid.set_margin_end (10);
            main_grid.set_row_spacing (12);
            main_grid.set_column_spacing (12);
            main_grid.set_column_homogeneous (false);
            main_grid.set_row_homogeneous (false);
            main_grid.set_vexpand (true);
            main_grid.attach (label, 0, grid_row, 2, 1);
            grid_row++;

            if (Thread.supported () == false) {
                Gtk.Label thread_support_lbl = new Gtk.Label ("");
                thread_support_lbl.set_markup (_("<big><span foreground=\"#ff0044\">Thread not supported.PlantUML Plugin cannot be enabled!</span></big>"));
                thread_support_lbl.set_halign (Gtk.Align.START);
                main_grid.attach (thread_support_lbl, 0, grid_row, 2, 1);
                grid_row++;
            } else {
                thread_support = true;
            }

            Gtk.Label general_lbl = new Gtk.Label ("");
            general_lbl.set_markup (_("<b>General settings</b>"));
            general_lbl.set_halign (Gtk.Align.START);
            main_grid.attach (general_lbl, 0, grid_row, 1, 1);
            grid_row++;

            Gtk.CheckButton enable_plantuml = new Gtk.CheckButton.with_label (_("Enable PlantUML"));
            if (!thread_support) {
                enable_plantuml.set_active (thread_support);
                settings.set_value ("enable-plantuml", thread_support);
            } else {
                settings.bind ("enable-plantuml", enable_plantuml, "active", GLib.SettingsBindFlags.DEFAULT | GLib.SettingsBindFlags.GET_NO_CHANGES);
            }
            main_grid.attach (enable_plantuml, 1, grid_row, 1, 1);
            grid_row++;


            Gtk.Label plantuml_library_path_lbl = new Gtk.Label ("");
            plantuml_library_path_lbl.set_markup (_("<b>PlantUML library path</b>"));
            plantuml_library_path_lbl.set_halign (Gtk.Align.START);
            main_grid.attach (plantuml_library_path_lbl, 0, grid_row, 1, 1);
            grid_row++;

            entry = new Gtk.Entry ();
            Gtk.FileChooserButton file_chooser = new Gtk.FileChooserButton (
                    _("Select library"),
                    Gtk.FileChooserAction.OPEN);
            file_chooser.file_set.connect (() => {
                file_chooser.get_file ().get_path ();
            });

            Gtk.Button btn_chooser = new Gtk.Button.with_label (_("Select library"));
            btn_chooser.set_image (new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.DND));
            btn_chooser.set_always_show_image (true);
            btn_chooser.clicked.connect (() => {
                Gtk.FileChooserDialog dialog = new Gtk.FileChooserDialog (_("Select library"),
                                                                        null, 
                                                                        Gtk.FileChooserAction.OPEN,
                                                                        _("Cancel"),
                                                                        Gtk.ResponseType.CANCEL,
                                                                        _("Select"),
                                                                        Gtk.ResponseType.ACCEPT
                                                                    );                 
                dialog.set_show_hidden (true);
                dialog.set_local_only (true);

                Gtk.FileFilter filter = new Gtk.FileFilter ();
                filter.add_mime_type ("application/java-archive");
                dialog.set_filter (filter);
                
                int response = dialog.run ();
                if (response == Gtk.ResponseType.ACCEPT) {
                    entry.set_text (dialog.get_file ().get_path ());
                }
                dialog.destroy ();
            });
            btn_chooser.set_halign (Gtk.Align.START);
            main_grid.attach (btn_chooser, 1, grid_row, 1, 1);
            grid_row++;

            settings.bind ("plantuml-file-path", entry, "text", GLib.SettingsBindFlags.DEFAULT | GLib.SettingsBindFlags.GET_NO_CHANGES);
            entry.set_width_chars (70);
            entry.set_hexpand (true);
            entry.set_halign (Gtk.Align.START);
            main_grid.attach (entry, 1, grid_row, 1, 1);
            grid_row++;

            
            Gtk.Label plantuml_download_lbl = new Gtk.Label ("");
            plantuml_download_lbl.set_markup (_("<a href=\"https://github.com/plantuml/plantuml/releases/latest\">https://github.com/plantuml/plantuml/releases/latest</a>"));
            plantuml_download_lbl.set_halign (Gtk.Align.START);
            main_grid.attach (plantuml_download_lbl, 1, grid_row, 1, 1);
            grid_row++;

            
            parent = main_grid;
            return main_grid;
        }
    }
}