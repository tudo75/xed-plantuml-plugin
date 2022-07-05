/*
 * plantumlqueue.vala
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

    public struct QueueElement {
        public string source_path;
        public string png_path;
    }

    public class PlantUMLQueue : Gee.PriorityQueue<QueueElement?> {

        // [Signal (run_last=true, type_none=true)]
        public signal void element_added ();

        public void add_element (QueueElement element) {
            this.add (element);
            this.element_added ();
        }

        public bool is_empty () {
            if (this.capacity == this.remaining_capacity)
                return true;
            return false;
        }
    }
}