data_dir = join_paths(meson.source_root(), 'data')

shared_library('budgieweatherapplet',
    'WeatherApplet.vala',
    'Services/Parser.vala',
    'Services/Utils.vala',
    'Widgets/AppletSettings.vala',
    'Widgets/Popover.vala',
    'Providers/OWM.vala',
    'WeatherInfo.vala',
    'ILogindManager.vala',
    'Constants.vala',
    dependencies: [
        dep_gtk3,
        dep_glib,
        dep_peas,
        dep_budgie,
        dep_json_glib,
        dep_libsoup,
        dep_gweather,
    ],
    c_args: [
        '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
    ],
    link_args : ['-lm'],
    install: true,
    install_dir: LIB_INSTALL_DIR,
)
