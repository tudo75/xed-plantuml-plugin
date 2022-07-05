# xed-plantuml-plugin
Porting of the Gedit PlantUML plugin to Xed

## Requirements
First of all the system must support threads.

To compile some libraries are needed:

* meson
* ninja-build
* valac
* libpeas-1.0-dev
* libpeas-gtk-1.0
* libglib2.0-dev
* libgtk-3-dev
* libgee-0.8-dev
* libgtksourceview-4-dev
* libxapp-dev
* xed-dev

To install on Ubuntu based distros:

    sudo apt install meson ninja-build build-essential valac cmake libgtk-3-dev libpeas-dev xed-dev libxapp-dev libgee-0.8-dev libgtksourceview-4-dev

## Install
Clone the repository:

    git clone https://github.com/tudo75/xed-plantuml-plugin.git
	cd xed-plantuml-plugin

And from inside the cloned folder:
	meson setup build --prefix=/usr
    ninja -v -C build com.github.tudo75.xed-plantuml-plugin-gmo
    ninja -v -C build
    ninja -v -C build install

## Uninstall
To uninstall and remove all added files, go inside the cloned folder and:

	sudo ninja -v -C build uninstall
    sudo rm /usr/share/locale/en/LC_MESSAGES/com.github.tudo75.xed-plantuml-plugin.mo
    sudo rm /usr/share/locale/it/LC_MESSAGES/com.github.tudo75.xed-plantuml-plugin.mo

## Instructions
Plugin must be enabled from Edit -> Preferences -> Plugins -> PlantUML

And in the same place, after you have downloaded PlantUML jar library from 
https://github.com/plantuml/plantuml
you have to set the path for it. 


## Credits
Based on this Gedit Plugin

https://github.com/ruudbeukema/gedit-plugin-plantuml