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
    public class Plugin : GLib.Object, Budgie.Plugin {
        public Budgie.Applet get_panel_widget(string uuid) {return new Applet(uuid);}
    }

    public class Applet : Budgie.Applet {
        private Gtk.EventBox event_box;
        private Gtk.Label temp;
        private Gtk.Image weather_icon;

        private Widgets.Popover main_grid = null;

        public string uuid { public set; public get; }
        private uint source_id;

        Budgie.Popover? popover = null;
        unowned Budgie.PopoverManager? manager = null;

        private string idplace = "";
        private bool fast_check = true;
        private uint _counter = 5;
        private uint counter {
            get {
                if (_counter > 1) {
                    _counter -= 1;
                } else {
                    _counter = 0;
                    fast_check = false;
                }
                return _counter;
            }
            set {
                _counter = value;
                fast_check = true;
            }
        }

        private Settings settings;
        private ILogindManager? logind_manager;

        public Applet(string uuid) {
            Object(uuid: uuid);

            settings = new GLib.Settings ("com.github.dirli.budgie-weather-applet");
            init_idplace ();

            settings.changed.connect(on_settings_change);

            weather_icon = new Gtk.Image ();

            temp = new Gtk.Label ("-");
            temp.margin_start = temp.margin_end = 6;

            Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.pack_start (weather_icon, false, false, 0);
            box.pack_start (temp, false, false, 0);

            event_box = new Gtk.EventBox();
            event_box.add(box);
            add(event_box);

            main_grid = new Widgets.Popover ();

            popover = new Budgie.Popover (event_box);
            popover.add(main_grid);

            event_box.button_press_event.connect((e) => {
                if (e.button != 1) {
                    return Gdk.EVENT_PROPAGATE;
                }

                if (popover.get_visible()) {
                    popover.hide();
                } else {
                    manager.show_popover(event_box);
                }

                return Gdk.EVENT_STOP;
            });

            update();

            try {
                logind_manager = Bus.get_proxy_sync (BusType.SYSTEM, LOGIND_BUS_NAME, LOGIND_BUS_PATH);
                if (logind_manager != null) {
                    logind_manager.prepare_for_sleep.connect((start) => {
                        if (!start) {
                            new Thread<int>("", () => {
                                Thread.usleep(10000000);
                                counter = 5;

                                init_idplace ();

                                update();
                                return 0;
                            });
                        }
                    });
                }
            } catch (IOError e) {
                warning (e.message);
            }

            popover.get_child().show_all();
            show_all();
            on_settings_change("show-icon");
            on_settings_change("show-temp");
        }

        private void init_idplace () {
            if (settings.get_boolean ("auto-loc")) {
                settings.reset ("idplace");
                idplace = "";
            } else {
                idplace = settings.get_string ("idplace");
            }
        }

        private unowned bool update() {
            if (idplace == "") {
                if (settings.get_boolean ("auto-loc")) {
                    string new_idplace = Utils.update_location ();
                    if (new_idplace == "") {
                        if (fast_check) {
                            uint counter_val = counter;
                            if (counter_val == 0 || counter_val == 4) {
                                start_watcher ();
                            }
                        }

                        return true;
                    }

                    idplace = new_idplace;
                } else {
                    return false;
                }
            }

            string lang = Gtk.get_default_language ().to_string ().substring (0, 2);
            string units = settings.get_string ("units");
            string api_key = settings.get_string ("personal-key");

            if (api_key == "") {
                api_key = Constants.API_KEY;
            } else {
                api_key = api_key.replace ("/", "");
            }

            string uri_query = "?id=" + idplace + "&APPID=" + api_key + "&units=" + units + "&lang=" + lang;
            string uri = Constants.OWM_API_ADDR + "weather" + uri_query;
            Json.Object? today_obj = Providers.OWM.get_owm_data (uri);

            if (today_obj != null) {
                if (fast_check) {
                    fast_check = false;
                    start_watcher ();
                }

                DateTime now = new DateTime.now_local();
                settings.set_int64 ("last-update", now.to_unix ());
                main_grid.update_header (now.format ("%d %B"));
                WeatherInfo weather_info = WeatherApplet.Services.Parser.parse_forecast (today_obj, units);
                update_gui_with_weather_info (weather_info);
            } else if (fast_check) {
                uint counter_val = counter;
                if (counter_val == 0 || counter_val == 4) {
                    start_watcher ();
                }
            }

            return true;
        }

        public void update_gui_with_weather_info (WeatherInfo? info) {
            temp.label = info.temp;
            weather_icon.set_from_icon_name(info.icon_name + "-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            main_grid.update_view (info);
        }

        public override void update_popovers(Budgie.PopoverManager? manager){
            this.manager = manager;
            manager.register_popover(event_box, popover);
        }

        protected void on_settings_change(string key) {
            if (key == "update-interval") {
                start_watcher();
            } else if (key == "show-icon") {
                weather_icon.set_visible(settings.get_boolean("show-icon"));
            } else if (key == "show-temp") {
                temp.set_visible(settings.get_boolean("show-temp"));
            } else if (key == "update-now") {
                if (settings.get_boolean("update-now")) {
                    init_idplace ();
                    fast_check = true;
                    update();
                }
            }

            queue_resize();
        }

        private void start_watcher() {
            if (source_id > 0) {
                Source.remove(source_id);
            }

            uint interval;
            if (fast_check) {
                interval = 20;
            } else {
                interval = settings.get_int("update-interval") * 3600;
            }

            if (interval > 0) {
                source_id = GLib.Timeout.add_seconds(interval, update);
            }
        }

        public override bool supports_settings() {
            return true;
        }

        public override Gtk.Widget? get_settings_ui() {
            return new AppletSettings ();
        }
    }
}

[ModuleInit]
public void peas_register_types(TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(WeatherApplet.Plugin));
}
