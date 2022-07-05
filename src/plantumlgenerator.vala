/*
 * plantumlgenerator.vala
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

    public class PlantUMLGenerator {

        // [Signal (run_last=true, type_none=true)]
        public signal void png_created ();

        private static GLib.Settings settings = new GLib.Settings ("com.github.tudo75.xed-plantuml-plugin");
        private static string PLANTUML_JAR_FILEPATH;
        private QueueElement element;
        
        public PlantUMLGenerator (QueueElement element) {

            PLANTUML_JAR_FILEPATH = settings.get_string ("plantuml-file-path");

            this.element = element;

            Thread<QueueElement?> thread = new Thread<QueueElement> ("PlantUMLGenerator " + GLib.Path.get_basename(this.element.source_path), this.run);

            thread.join ();
        }

        public QueueElement run () {
            string src_path = this.element.source_path;
            
            try {
                Process.spawn_command_line_sync ("java -jar " + PLANTUML_JAR_FILEPATH + " -tpng -quiet -nbthread auto " + src_path);
            
                foreach (var extension in PlantUMLManager.SUPPORTED_SOURCE_FILE_EXTENSIONS) {
                    if (src_path.has_suffix (extension)) {
                        this.element.png_path = src_path.substring (0, src_path.length - extension.length) + ".png";
                        break;
                    }
                }

                //Thread.usleep (10000);
                this.png_created ();
            } catch (GLib.SpawnError e) {
                print ("PlantUMLGenerator => run error: " + e.message + "\n");
            }

            Thread.exit (null);
            
            return this.element;
        }

        public QueueElement get_element (){
            return this.element;
        }
    }
}