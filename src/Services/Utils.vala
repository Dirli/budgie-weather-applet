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

namespace WeatherApplet.Utils {
    private static string update_location () {
        string uri = "https://location.services.mozilla.com/v1/geolocate?key=test";
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", uri);
        session.send_message (message);

        if (message.status_code == 200) {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root = parser.get_root ().get_object ();
                double? latitude = null, longitude = null;
                foreach (string name in root.get_members ()) {
                    if (name == "location") {
                        var mycoords = root.get_object_member ("location");
                        longitude = mycoords.get_double_member ("lng");
                        latitude = mycoords.get_double_member ("lat");
                        break;
                    }
                }

                if (latitude != null && longitude != null) {
                    return get_idplace ("%.5f".printf (longitude), "%.5f".printf (latitude));
                }
            } catch (Error e) {
                warning (e.message);
            }
        } else {
            code_handler (message.status_code);
        }

        return "";
    }

    public static string get_idplace (string lon, string lat) {
        string uri = "?lat=" + lat + "&lon=" + lon + "&APPID=" + Constants.API_KEY;
        uri = Constants.OWM_API_ADDR + "weather" + uri;

        Soup.Session session = new Soup.Session ();
        Soup.Message message = new Soup.Message ("GET", uri);
        session.send_message (message);

        if (message.status_code == 200) {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);

                var root = parser.get_root ().get_object ();

                return root.get_int_member ("id").to_string ();
            } catch (Error e) {
                warning (e.message);
            }
        } else {
            code_handler (message.status_code);
        }

        return "";
    }

    public static void code_handler (uint status_code) {
        string msg;

        if (status_code == 2) {
            msg = "Check internet connection";
        } else if (status_code == 403) {
            msg = _("You may be making too many requests to the server");
        } else if (status_code >= 400 && status_code < 500) {
            msg = _("Data not available, possibly incorrect api key");
        } else if (status_code >= 500 && status_code < 600) {
            msg = _("Service is unavailable");
        } else {
            msg = _("An error occurred while receiving the forecast");
        }

        warning ("Data not received. Status Code: %u\n", status_code);
    }

    // public static bool save_cache (string path_json, string data) {
    //     try {
    //         var path = File.new_for_path (Environment.get_user_cache_dir () + "/" + Constants.EXEC_NAME);
    //         if (!path.query_exists ()) {
    //             path.make_directory ();
    //         }
    //         var fcjson = File.new_for_path (path_json);
    //         if (fcjson.query_exists ()) {
    //             fcjson.delete ();
    //         }
    //         var fcjos = new DataOutputStream (fcjson.create (FileCreateFlags.REPLACE_DESTINATION));
    //         fcjos.put_string (data);
    //     } catch (Error e) {
    //         warning (e.message);
    //         return false;
    //     }
    //     return true;
    // }

    // public static void clear_cache () {
    //     try {
    //         string cache_path = Environment.get_user_cache_dir () + "/" + Constants.EXEC_NAME;
    //         string file_name;
    //         GLib.Dir dir = GLib.Dir.open (cache_path, 0);
    //         while ((file_name = dir.read_name ()) != null) {
    //             string path = GLib.Path.build_filename (cache_path, file_name);
    //             GLib.FileUtils.remove (path);
    //         }
    //     } catch (Error e) {
    //         warning (e.message);
    //     }
    // }

    public static string temp_format (string units, double temp) {
        string tempformat = "%.0f".printf(temp);

        tempformat += "\u00B0";
        switch (units) {
            case "imperial":
                tempformat += "F";
                break;
            case "metric":
            default:
                tempformat += "C";
                break;
        }
        return tempformat;
    }

    public static string time_format (GLib.DateTime datetime) {
        string timeformat = "";
        var syssetting = new Settings ("org.gnome.desktop.interface");
        if (syssetting.get_string ("clock-format") == "12h") {
            timeformat = datetime.format ("%I:%M");
        } else {
            timeformat = datetime.format ("%R");
        }

        return timeformat;
    }

    public static string wind_format (string units, double? speed = null, double? deg = null) {
        if (speed == null) {
            return "no data";
        }

        string windformat = "%.1f ".printf(speed);
        switch (units) {
            case "imperial":
                windformat += _("mph");
                break;
            case "metric":
            default:
                windformat += _("m/s");
                break;
        }

        if (deg != null) {
            double degrees = Math.floor((deg / 22.5) + 0.5);
            string[] arr = {"N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"};
            int index = (int)(degrees % 16);

            switch (arr[index]) {
                case "N":
                case "NNE":
                case "NNW":
                    windformat += ", ↓";
                break;
                case "NE":
                    windformat += ", ↙";
                break;
                case "ENE":
                case "E":
                case "ESE":
                    windformat += ", ←";
                break;
                case "SE":
                    windformat += ", ↖";
                break;
                case "SSE":
                case "S":
                case "SSW":
                    windformat += ", ↑";
                break;
                case "SW":
                    windformat += ", ↗";
                break;
                case "WSW":
                case "W":
                case "WNW":
                    windformat += ", →";
                break;
                case "NW":
                    windformat += ", ↘";
                break;
            }
        }
        return windformat;
    }

    public static string get_icon_name (string code) {
        string str_icon = "";
        switch (code) {
            case "01d":
                str_icon = "weather-clear";
                break;
            case "01n":
                str_icon = "weather-clear-night";
                break;
            case "02d":
                str_icon = "weather-few-clouds";
                break;
            case "02n":
                str_icon = "weather-few-clouds";
                break;
            case "03d":
                str_icon = "weather-few-clouds";
                break;
            case "03n":
                str_icon = "weather-few-clouds-night";
                break;
            case "04d":
                str_icon = "weather-overcast";
                break;
            case "04n":
                str_icon = "weather-overcast";
                break;
            case "09d":
                str_icon = "weather-showers-scattered";
                break;
            case "09n":
                str_icon = "weather-showers-scattered";
                break;
            case "10d":
                str_icon = "weather-showers";
                break;
            case "10n":
                str_icon = "weather-showers";
                break;
            case "11d":
                str_icon = "weather-storm";
                break;
            case "11n":
                str_icon = "weather-storm";
                break;
            case "13d":
                str_icon = "weather-snow";
                break;
            case "13n":
                str_icon = "weather-snow";
                break;
            case "50d":
                str_icon = "weather-fog";
                break;
            case "50n":
                str_icon = "weather-fog";
                break;
            default :
                str_icon = "dialog-error";
                break;
        }
        return str_icon;
    }

    public static string pressure_format (int val) {
        string lang = Gtk.get_default_language ().to_string ().substring (0, 2);
        string presformat;
        switch (lang) {
            case "ru":
                double transfor_val = val * 0.750063755419211;
                presformat = "%.0f mm Hg".printf(transfor_val);
                break;
            default:
                presformat = "%d hPa".printf(val);
                break;

        }
        return presformat;
    }
}
