project(
    'com.github.rclp.rclp-linux',
    'vala',
    'c',
    version: '0.1.0'
)

executable(
    meson.project_name(),
    'src/Application.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        dependency('gdk-pixbuf-2.0'),
        dependency('gio-2.0'),
        dependency('granite'),
        dependency('libnotify')
    ],
    install: true
)

install_data(
    join_paths('data', 'rclp-linux.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications'),
    rename: meson.project_name() + '.desktop'
)

install_data(
    join_paths('data', 'rclp-linux.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
    rename: meson.project_name() + '.appdata.xml'
)
