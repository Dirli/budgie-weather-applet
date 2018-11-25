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

            date_header = new Gtk.Label ("-");
            date_header.margin = 6;
            date_header.halign = Gtk.Align.CENTER;
            date_header.valign = Gtk.Align.CENTER;

            weather_icon_b = new Gtk.Image ();

            city = new Gtk.Label("-");
            city.set_ellipsize (Pango.EllipsizeMode.END);
            city.set_alignment(0, 0.5f);
            city.margin = 6;

            humidity = new Gtk.Label("-");
            humidity.margin = 6;

            sky = new Gtk.Label("-");
            sky.margin = 6;

            wind = new Gtk.Label("-");
            wind.margin = 6;

            Gtk.Label sunrise = new Gtk.Label(_("Sunrise"));
            Gtk.Label sunset = new Gtk.Label(_("Sunset"));
            sunrise_t = new Gtk.Label("-");
            sunset_t = new Gtk.Label("-");

            Gtk.Label l_update_l = new Gtk.Label(_("Last update"));
            l_update_l.margin_top = 6;
            l_update_t = new Gtk.Label("-");
            l_update_t.margin_top = 6;

            temp_b = new Gtk.Label ("-");
            temp_b.margin_top = temp_b.margin_bottom = 10;

            attach (date_header, 0, 0, 3, 1);
            attach (weather_icon_b, 0, 1, 2, 3);
            attach (city, 5, 1, 1, 1);
            attach (temp_b, 5, 2, 1, 1);
            attach (wind, 5, 3, 1, 1);
            attach (humidity, 5, 4, 1, 1);
            attach (sky, 0, 5, 3, 1);
            attach (sunrise, 0, 6, 2, 1);
            attach (sunrise_t, 5, 6, 1, 1);
            attach (sunset, 0, 7, 2, 1);
            attach (sunset_t, 5, 7, 1, 1);
            attach (l_update_l, 0, 8, 2, 1);
            attach (l_update_t, 5, 8, 1, 1);
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
