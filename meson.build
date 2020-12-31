project(
    'rclp-linux',
    'vala', 'c',
    version: '0.1.0'
)

executable(
    meson.project_name(),
    'RclpApp.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        dependency('gdk-pixbuf-2.0'),
        dependency('gio-2.0'),
        dependency('libnotify')
    ]
)
