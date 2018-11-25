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

        private bool fast_check = true;
        private uint _counter = 5;
        private uint counter {
            get {
                if (_counter > 0) {
                    _counter -= 1;
                } else {
                    fast_check = false;
                }
                return this._counter;
            }
            set {
                this._counter = value;
                this.fast_check = true;
            }
        }

        private Settings? settings;
        private Settings? gweather_settings;
        private ILogindManager? logind_manager;

        public Applet(string uuid) {
            Object(uuid: uuid);

            settings_schema = "com.github.dirli.budgie-weather-applet";
            settings_prefix = "/com/github/dirli/budgie-weather-applet";
            settings = get_applet_settings(uuid);
            settings.changed.connect(on_settings_change);
            gweather_settings = settings.get_child("gweather");

            weather_icon = new Gtk.Image ();

            temp = new Gtk.Label ("-");
            temp.set_ellipsize (Pango.EllipsizeMode.END);
            temp.set_alignment(0, 0.5f);
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
                    this.manager.show_popover(event_box);
                }

                return Gdk.EVENT_STOP;
            });

            new GWeather.LocationEntry(GWeather.Location.get_world());

            update();

            try {
                logind_manager = Bus.get_proxy_sync (BusType.SYSTEM, LOGIND_BUS_NAME, LOGIND_BUS_PATH);
                if (logind_manager != null) {
                    logind_manager.prepare_for_sleep.connect((start) => {
                        if (!start) {
                            new Thread<int>("", () => {
                                Thread.usleep(10000000);
                                counter = 5;
                                update();
                                return 0;
                            });
                        }
                    });
                }
            } catch (IOError e) {
                print(e.message);
            }

            popover.get_child().show_all();
            show_all();
            on_settings_change("show-icon");
            on_settings_change("show-temp");
        }

        private unowned bool update() {
            DateTime last_update = new DateTime.from_unix_local(settings.get_int64("last-update"));
            DateTime now = new DateTime.now();

            main_grid.update_header (now.format ("%d %B"));

            last_update = last_update.add_minutes(settings.get_int("update-interval"));

            if (last_update.compare(now) <= 0 || fast_check) {
                settings.set_int64("last-update", now.to_unix());
                new Thread<int>("", () => {
                    string city_name = gweather_settings.get_string("city-name");
                    float latitude = (float)gweather_settings.get_double("latitude");
                    float longitude = (float)gweather_settings.get_double("longitude");
                    Providers.LibGWeather.get_current_weather_info(latitude, longitude, city_name, update_gui_with_weather_info);
                    return 0;
                });
            }

            return true;
        }

        public void update_gui_with_weather_info (WeatherInfo? info) {
            if (info != null) {
                temp.label = "%d°".printf(info.temp);
                weather_icon.set_from_icon_name(info.symbolic_icon_name, Gtk.IconSize.SMALL_TOOLBAR);

                main_grid.update_view (info);

                if (fast_check) {
                    fast_check = false;
                    reset_update_timer(true);
                }
            } else {
                temp.label = " - ";
                weather_icon.clear();

                if (fast_check) {
                    uint counter_val = counter;
                    if (counter_val == 0 || counter_val == 4) {
                        reset_update_timer(true);
                    }
                }
            }
        }

        public override void update_popovers(Budgie.PopoverManager? manager){
            this.manager = manager;
            manager.register_popover(event_box, popover);
        }

        protected void on_settings_change(string key) {
            if (key == "update-interval") {
                reset_update_timer(false);
            } else if (key == "show-icon") {
                weather_icon.set_visible(settings.get_boolean("show-icon"));
            } else if (key == "show-temp") {
                temp.set_visible(settings.get_boolean("show-temp"));
            } else if (key == "update-now") {
                if (settings.get_boolean("update-now")) {
                    fast_check = true;
                    update();
                }
            }

            queue_resize();
        }

        private void reset_update_timer(bool force_update) {
            if (force_update) {
                this.settings.set_int64("last-update", 0);
            }

            if (this.source_id > 0) {
                Source.remove(this.source_id);
            }

            uint interval;
            if (this.fast_check) {
                interval = 20 * 1000;
            } else {
                interval = this.settings.get_int("update-interval");
                interval = interval * 60000;
            }

            if (interval > 0) {
                this.source_id = GLib.Timeout.add_full(GLib.Priority.DEFAULT, interval, update);
            }
        }

        public override bool supports_settings() {
            return true;
        }

        public override Gtk.Widget? get_settings_ui() {
            return new AppletSettings(this.get_applet_settings(uuid));
        }
    }

    void print(string? message) {
        if (message == null) message = "";
        stdout.printf ("Budgie-Weather: %s\n", message);
    }
}

[ModuleInit]
public void peas_register_types(TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(WeatherApplet.Plugin));
}
