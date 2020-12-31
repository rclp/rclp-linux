# rclp-linux

**This app is heavily in development, and is not stable for daily use.**

rclp-linux is a rclp client for Linux.


## how to build

```
$ meson build --prefix=/usr
$ cd build
$ ninja
```

Execute `rclp-linux` built as result of the build process for testing.


## debugging

To show all debug messages:
```
$ G_MESSAGES_DEBUG=all rclp-linux
```

To visually inspect GTK widgets:
```
$ GTK_DEBUG=interactive rclp-linux
```
