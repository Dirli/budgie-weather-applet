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

namespace WeatherApplet.Providers {
    public class OWM : Object {
        private static Json.Parser parser;

        public static Json.Object? get_owm_data (string url) {
            parser = new Json.Parser ();
            string text = get_forecast (url);

            if (text == "") {
                return null;
            }

            Json.Object forecast_obj = new Json.Object ();
            forecast_obj = parser.get_root ().get_object ();

            return forecast_obj;
        }

        private static string get_forecast (string url) {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);
            session.send_message (message);

            if (message.status_code == 200) {
                try {
                    string text = (string) message.response_body.flatten ().data;
                    parser.load_from_data (text, -1);
                    Json.Node? node = parser.get_root ();

                    if (node != null) {
                        var cod = parser.get_root ().get_object ().get_int_member ("cod");

                        if (cod == 200) {
                            return text;
                        }

                    }
                } catch (Error e) {
                    warning (e.message);
                }
            } else {
                Utils.code_handler (message.status_code);
            }

            return "";
        }
    }
}
