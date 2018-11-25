/*
* Copyright (c) 2018 Dirli <litandrej85@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*/

namespace WeatherApplet {
    [GtkTemplate (ui = "/com/github/dirli/budgie-weather/settings.ui")]
    public class AppletSettings : Gtk.Grid {
        Settings? settings = null;
        Settings? gweather_settings = null;
        [GtkChild]
        private Gtk.SpinButton? spinbutton_update_interval;
        [GtkChild]
        private Gtk.Switch? switch_icon;
        [GtkChild]
        private Gtk.Switch? switch_temp;
        [GtkChild]
        private Gtk.Button? button_update_now;
        [GtkChild]
        private GWeather.LocationEntry? gweather_location_entry;

        public AppletSettings(Settings? settings) {
            this.settings = settings;
            gweather_settings = this.settings.get_child("gweather");
            init_generic_settings();
            init_gweather_settings();
        }

        private void init_gweather_settings() {
            gweather_location_entry.changed.connect (location_entry_changed);
            var city_name = gweather_settings.get_string("city-name");
            var latitude = gweather_settings.get_double("latitude");
            var longitude = gweather_settings.get_double("longitude");
            if (city_name != "") {
                gweather_location_entry.set_location(new GWeather.Location.detached(city_name, null, latitude, longitude));
            }
        }

        private void init_generic_settings() {
            settings.bind("update-interval", spinbutton_update_interval, "value", SettingsBindFlags.DEFAULT);
            settings.bind("show-icon", switch_icon, "active", SettingsBindFlags.DEFAULT);
            settings.bind("show-temp", switch_temp, "active", SettingsBindFlags.DEFAULT);

            button_update_now.clicked.connect (() => {
                settings.set_boolean("update-now", true);
                settings.set_boolean("update-now", false);
            });
        }

        private void location_entry_changed() {
            GWeather.Location? location = gweather_location_entry.get_location ();
            double latitude, longitude;
            string city_name;

            if (location != null) {
                location.get_coords(out latitude, out longitude);
                city_name = location.get_city_name ();
                gweather_settings.set_string("city-name", city_name);
                gweather_settings.set_double("latitude", latitude);
                gweather_settings.set_double("longitude", longitude);
            } else {
                gweather_settings.reset("city-name");
                gweather_settings.reset("latitude");
                gweather_settings.reset("longitude");
            }
        }
    }
}
