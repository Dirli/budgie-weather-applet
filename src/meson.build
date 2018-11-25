data_dir = join_paths(meson.source_root(), 'data')
gresource_file = join_paths(data_dir, 'plugin.gresource.xml')

# Compile the assets into the binary
bwa_resources = gnome.compile_resources(
    'bwa-resources',
    gresource_file,
    source_dir: data_dir,
)

bwa_sources = [
    'WeatherApplet.vala',
    'Widgets/AppletSettings.vala',
    'Widgets/Popover.vala',
    'Providers/LibGWeather.vala',
    'WeatherInfo.vala',
    'ILogindManager.vala',
    bwa_resources,
]

bwa_deps = [
    dep_gtk3,
    dep_glib,
    dep_peas,
    dep_budgie,
    dep_json_glib,
    dep_libsoup,
    dep_gweather,
]

shared_library('budgieweatherapplet',
    bwa_sources,
    dependencies: bwa_deps,
    c_args: [
        '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
    ],
    install: true,
    install_dir: LIB_INSTALL_DIR,
)
