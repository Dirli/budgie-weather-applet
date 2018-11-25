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

namespace WeatherApplet.Providers {
    public delegate void WeatherUpdated(WeatherInfo? info);

    public class LibGWeather {
        public static void get_current_weather_info (float latitude, float longitute, string city_name, WeatherUpdated callback) {
            GWeather.Location loc = new GWeather.Location.detached(city_name, null, latitude, longitute);
            GWeather.Info gweather_info = new GWeather.Info(loc);

            gweather_info.updated.connect(() => {
                WeatherInfo info = get_weather_info_from_gweather_info(gweather_info);
                long update_time;

                gweather_info.get_value_update(out update_time);

                if (update_time == 0) {
                    callback(null);
                } else {
                    callback(info);
                }
            });
            gweather_info.update();
        }

        private static WeatherInfo get_weather_info_from_gweather_info (GWeather.Info gweather_info) {
            WeatherInfo info = new WeatherInfo();
            double wind_speed;
            GWeather.WindDirection wind_direction;

            info.city_name = gweather_info.get_location_name();
            info.icon_name = gweather_info.get_icon_name();
            info.symbolic_icon_name = gweather_info.get_symbolic_icon_name();
            info.humidity = gweather_info.get_humidity();
            info.sky = gweather_info.get_sky();
            info.sunrise = gweather_info.get_sunrise();
            info.sunset = gweather_info.get_sunset();
            info.temp = (int)int.parse(gweather_info.get_temp());
            info.temp_min = (int)int.parse(gweather_info.get_temp_min());
            info.temp_max = (int)int.parse(gweather_info.get_temp_max());

            gweather_info.get_value_wind (GWeather.SpeedUnit.MS, out wind_speed, out wind_direction);
            string abbr = _("m/s");
            info.wind = "%.1f %s".printf(wind_speed, abbr);

            switch (wind_direction) {
                case GWeather.WindDirection.N:
                case GWeather.WindDirection.NNE:
                case GWeather.WindDirection.NNW:
                    info.wind += ", ↓";
                    break;
                case GWeather.WindDirection.NE:
                    info.wind += ", ↙";
                    break;
                case GWeather.WindDirection.ENE:
                case GWeather.WindDirection.E:
                case GWeather.WindDirection.ESE:
                    info.wind += ", ←";
                    break;
                case GWeather.WindDirection.SE:
                    info.wind += ", ↖";
                    break;
                case GWeather.WindDirection.SSE:
                case GWeather.WindDirection.S:
                case GWeather.WindDirection.SSW:
                    info.wind += ", ↑";
                    break;
                case GWeather.WindDirection.SW:
                    info.wind += ", ↗";
                    break;
                case GWeather.WindDirection.WSW:
                case GWeather.WindDirection.W:
                case GWeather.WindDirection.WNW:
                    info.wind += ", →";
                    break;
                case GWeather.WindDirection.NW:
                    info.wind += ", ↘";
                    break;
            }

            info.l_update_t = gweather_info.get_update().split ("/")[1];

            return info;
        }
    }
}
