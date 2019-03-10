namespace WeatherApplet.Providers {
    public class OWM : Object {
        private static Json.Parser parser;

        public static Json.Object? get_owm_data (string url) {
            string text = "";
            parser = new Json.Parser ();
            text = get_forecast (url);
            if (text == "") {
                return null;
            }

            Json.Object forecast_obj = new Json.Object ();
            forecast_obj = parser.get_root ().get_object ();

            return forecast_obj;
        }

        private static string get_forecast (string url) {
            try {
                var session = new Soup.Session ();
                var message = new Soup.Message ("GET", url);

                session.send_message (message);

                string text = (string) message.response_body.flatten ().data;
                parser.load_from_data (text, -1);
                Json.Node? node = parser.get_root ();

                if (node != null) {
                    var cod = parser.get_root ().get_object ().get_int_member ("cod");
                    if (cod == 200) {return text;}
                }

                return "";
            } catch (Error e) {
                warning (e.message);
                return "";
            }
        }
    }
}
