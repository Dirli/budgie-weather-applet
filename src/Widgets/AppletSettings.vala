/*
* Copyright (c) 2018-2019 Dirli <litandrej85@gmail.com>
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
    public class AppletSettings : Gtk.Grid {
        private GLib.Settings settings;

        private Gtk.SpinButton update_interval;
        private Gtk.Switch switch_auto_loc;
        private Gtk.Switch switch_icon;
        private Gtk.Switch switch_temp;
        private Gtk.Entry local_key;
        private Gtk.Button btn_update;
        private GWeather.LocationEntry? gweather_location_entry;

        public AppletSettings() {
            margin = 6;
            row_spacing = 10;
            settings = new GLib.Settings ("com.github.dirli.budgie-weather-applet");;

            init_ui ();

            string city_name = settings.get_string("city-name");
            double latitude = settings.get_double("latitude");
            double longitude = settings.get_double("longitude");

            if (city_name != "") {
                gweather_location_entry.set_location(new GWeather.Location.detached(city_name, null, latitude, longitude));
            }

            change_auto_loc ();
            init_settings ();
        }

        private void init_ui () {
            Gtk.Label loc_label = new Gtk.Label (_("Auto location"));
            switch_auto_loc = new Gtk.Switch ();
            switch_auto_loc.valign = Gtk.Align.CENTER;
            switch_auto_loc.halign = Gtk.Align.END;

            gweather_location_entry = new GWeather.LocationEntry (GWeather.Location.get_world());
            gweather_location_entry.placeholder_text = _("Search for new location") + ":";
            gweather_location_entry.width_chars = 30;

            Gtk.Label interval_label = new Gtk.Label (_("Update interval (h.)"));
            update_interval = new Gtk.SpinButton.with_range (1, 12, 1);
            update_interval.valign = Gtk.Align.CENTER;
            update_interval.halign = Gtk.Align.END;
            update_interval.set_width_chars (2);

            Gtk.Label label_icon = new Gtk.Label (_("Show icon"));
            switch_icon = new Gtk.Switch ();
            switch_icon.valign = Gtk.Align.CENTER;
            switch_icon.halign = Gtk.Align.END;

            Gtk.Label label_temp = new Gtk.Label (_("Show temperature"));
            switch_temp = new Gtk.Switch ();
            switch_temp.valign = Gtk.Align.CENTER;
            switch_temp.halign = Gtk.Align.END;

            Gtk.Label units_label = new Gtk.Label (_("Units"));
            Gtk.RadioButton button1 = new Gtk.RadioButton.with_label_from_widget (null, "metric");
            button1.margin_start = button1.margin_end = 15;
            button1.margin_bottom = 10;
            button1.toggled.connect (toggled_units);
            Gtk.RadioButton button2 = new Gtk.RadioButton.with_label_from_widget (button1, "imperial");
            button2.margin_start = button2.margin_end = 15;
            button2.margin_bottom = 10;
            button2.toggled.connect (toggled_units);

            if (settings.get_string("units") == "metric") {
                button1.set_active (true);
            } else {
                button2.set_active (true);
            }

            Gtk.Separator separator1 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            Gtk.Separator separator2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            button1.halign = button2.halign = Gtk.Align.START;
            button1.valign = button2.valign = Gtk.Align.CENTER;

            local_key = new Gtk.Entry ();
            local_key.hexpand = true;
            local_key.placeholder_text = _("Enter personal api key");

            btn_update = new Gtk.Button.with_label (_("Update now"));

            attach (loc_label,               0, 0, 1, 1);
            attach (switch_auto_loc,         1, 0, 1, 1);
            attach (gweather_location_entry, 0, 1, 2, 1);
            attach (interval_label,          0, 2, 1, 1);
            attach (update_interval,         1, 2, 1, 1);
            attach (label_icon,              0, 3, 1, 1);
            attach (switch_icon,             1, 3, 1, 1);
            attach (label_temp,              0, 4, 1, 1);
            attach (switch_temp,             1, 4, 1, 1);
            attach (separator1,              0, 5, 2, 1);
            attach (units_label,             0, 6, 2, 1);
            attach (button1,                 0, 7, 2, 1);
            attach (button2,                 0, 8, 2, 1);
            attach (separator2,              0, 9, 2, 1);
            attach (local_key,              0, 10, 2, 1);
            attach (btn_update,             1, 11, 1, 1);

            show_all ();
        }

        private unowned void toggled_units (Gtk.ToggleButton button) {
            if (button.get_active ()) {
                settings.set_string("units", button.label);
            }
        }

        private void change_auto_loc () {
            bool auto_loc_state = switch_auto_loc.get_active ();
            gweather_location_entry.set_sensitive (!auto_loc_state);

            if (auto_loc_state) {
                reset_state ();
            }
        }

        private void reset_state () {
            settings.reset ("city-name");
            settings.reset ("idplace");
            settings.reset ("latitude");
            settings.reset ("longitude");
        }

        private void init_settings () {
            settings.bind("update-interval", update_interval, "value", SettingsBindFlags.DEFAULT);
            settings.bind("auto-loc", switch_auto_loc, "active", SettingsBindFlags.DEFAULT);
            settings.bind("show-icon", switch_icon, "active", SettingsBindFlags.DEFAULT);
            settings.bind("show-temp", switch_temp, "active", SettingsBindFlags.DEFAULT);
            settings.bind("personal-key", local_key, "text", SettingsBindFlags.DEFAULT);

            btn_update.clicked.connect (() => {
                settings.set_boolean("update-now", true);
                settings.set_boolean("update-now", false);
            });

            switch_auto_loc.notify["active"].connect (change_auto_loc);
            gweather_location_entry.changed.connect (location_entry_changed);
        }

        private void location_entry_changed() {
            GWeather.Location? location = gweather_location_entry.get_location ();

            if (location != null) {
                double latitude, longitude;
                location.get_coords(out latitude, out longitude);
                string city_name = location.get_city_name ();

                new_location (latitude, longitude, city_name);
            } else {
                reset_state ();
            }
        }

        private void new_location (double latitude, double longitude, string city_name) {
            string new_idplace = Utils.get_idplace (longitude.to_string (), latitude.to_string ());

            settings.set_string("city-name", city_name);
            settings.set_double("latitude", latitude);
            settings.set_double("longitude", longitude);
            settings.set_string ("idplace", new_idplace);
        }
    }
}
