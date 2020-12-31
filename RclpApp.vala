errordomain RclpError {
    CLOUD_NOT_RUN
}

namespace Rclp {
    public class App : Gtk.Application {
        private const string APP_ID = "app.rclp.app.linux.RclpApp";
        private const int RCLP_PASTE_INTERVAL = 10000;
        private const string[] RCLP_COMMAND = {
            "n", "exec", "lts", "rclp", "-p"
        };
        private const string NOTIFICATION_ICON = "dialog-information";

        private bool was_activated = false;
        private string currentPasteValue = "";

        public App () {
            Object(application_id: APP_ID,
                   flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate () {
            // make sure to run the rest only once and for the primary instance
            if (this.was_activated) {
                return;
            }
            this.was_activated = true;

            Notify.init ("rclp client for Linux");

            Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
            window.set_default_size (400, 400);
            window.title = "rclp";

            Gtk.Label label = new Gtk.Label ("Hello, GTK");
            window.add (label);
            window.show_all ();

            // setup a timer to call rclp
            debug ("setting up a timer");
            var time = new TimeoutSource (RCLP_PASTE_INTERVAL);
            time.set_callback (() => {
                debug ("calling rclp!");
                var newPasteValue = "";
                try {
                    newPasteValue = run_rclp_paste ();
                } catch (RclpError error) {
                    warning ("Failed to run rclp, stopping it");
                    show_notification("rclp not updated", "failed to update");
                    return Source.REMOVE;
                }

                debug (@"rclp: current=$(currentPasteValue), new=$(newPasteValue)");
                var previousPasteValue = currentPasteValue;
                currentPasteValue = newPasteValue;

                if (previousPasteValue != currentPasteValue) {
                    show_notification("New paste value",
                                      "rclp detected a new paste value!");
                }

                return Source.CONTINUE;
            });
            time.attach ();
        }

        private string run_rclp_paste () throws RclpError {
            var pastedValue = "";
            try {
                string[] spawn_env = Environ.get ();
                var current_dir = Environment.get_current_dir ();
                string rclp_stdout;
                string rclp_stderr;
                int rclp_status;

                Process.spawn_sync (current_dir,
                                    RCLP_COMMAND,
                                    spawn_env,
                                    SpawnFlags.SEARCH_PATH,
                                    null,
                                    out rclp_stdout,
                                    out rclp_stderr,
                                    out rclp_status);

                debug ("stdout: %s", rclp_stdout);
                debug ("stderr: %s", rclp_stderr);
                debug ("status: %d", rclp_status);

                pastedValue = rclp_stdout.strip ();
            } catch (SpawnError e) {
                warning ("error when running rclp: %s", e.message);
                throw new RclpError.CLOUD_NOT_RUN ("Failed to run rclp");
            }

            return pastedValue;
        }


        private void show_notification (string title, string content) {
            try {
                var notification = new Notify.Notification (title,
                                                            content,
                                                            NOTIFICATION_ICON);
                notification.show ();
            } catch (Error e) {
                warning ("error when showing a notification: %s", e.message);
            }
        }

        public static int main (string[] args) {
            var app = new App ();
            return app.run (args);
        }
    }
}
