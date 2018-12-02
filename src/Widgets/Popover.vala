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
    public class Widgets.Popover : Gtk.Grid {
        private Gtk.Label date_header;
        private Gtk.Label temp_b;
        private Gtk.Label city;
        private Gtk.Label humidity;
        private Gtk.Label l_update_t;
        private Gtk.Label sunrise_t;
        private Gtk.Label sunset_t;
        private Gtk.Label sky;
        private Gtk.Image weather_icon_b;
        private Gtk.Label wind;

        public Popover() {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 10;
            row_spacing = 6;

            date_header = new Gtk.Label ("-");
            date_header.halign = Gtk.Align.CENTER;

            weather_icon_b = new Gtk.Image ();

            city = new Gtk.Label("-");
            city.set_ellipsize (Pango.EllipsizeMode.END);
            city.set_alignment(0, 0.5f);
            city.halign = Gtk.Align.END;

            humidity = new Gtk.Label("-");
            humidity.halign = Gtk.Align.END;

            sky = new Gtk.Label("-");

            wind = new Gtk.Label("-");
            wind.halign = Gtk.Align.END;

            Gtk.Label sunrise = new Gtk.Label(_("Sunrise"));
            Gtk.Label sunset = new Gtk.Label(_("Sunset"));
            sunrise_t = new Gtk.Label("-");
            sunset_t = new Gtk.Label("-");

            Gtk.Label l_update_l = new Gtk.Label(_("Last update"));
            l_update_t = new Gtk.Label("-");

            temp_b = new Gtk.Label ("-");
            temp_b.halign = Gtk.Align.END;

            Gtk.Separator separator1 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            Gtk.Separator separator2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            Gtk.Separator separator3 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            attach (date_header, 0, 0, 3, 1);
            attach (separator1, 0, 1, 3, 1);
            attach (weather_icon_b, 0, 2, 2, 4);
            attach (city, 2, 2, 1, 1);
            attach (temp_b, 2, 3, 1, 1);
            attach (wind, 2, 4, 1, 1);
            attach (humidity, 2, 5, 1, 1);
            attach (sky, 0, 6, 3, 1);
            attach (separator2, 0, 7, 3, 1);
            attach (sunrise, 0, 8, 2, 1);
            attach (sunrise_t, 2, 8, 1, 1);
            attach (sunset, 0, 9, 2, 1);
            attach (sunset_t, 2, 9, 1, 1);
            attach (separator3, 0, 10, 3, 1);
            attach (l_update_l, 0, 11, 2, 1);
            attach (l_update_t, 2, 11, 1, 1);
        }

        public void update_header (string date) {
            date_header.set_label (date);
        }

        public void update_view (WeatherInfo info) {
            city.label = info.city_name;
            humidity.label = info.humidity;
            sky.label = info.sky;
            sunset_t.label = info.sunset;
            sunrise_t.label = info.sunrise;
            temp_b.label = "%d° C".printf(info.temp);
            l_update_t.label = info.l_update_t;
            weather_icon_b.set_from_icon_name(info.icon_name, Gtk.IconSize.DIALOG);
            wind.label = info.wind;
        }
    }
}
