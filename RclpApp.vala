using Gtk;

namespace Rclp {
    public class App : Gtk.Application {
        private const string APP_ID = "app.rclp.app.linux.RclpApp";
        private const int RCLP_PASTE_INTERVAL = 10000;
        private const string[] RCLP_COMMAND = {
            "n", "exec", "lts", "rclp", "-p"
        };
        private const string NOTIFICATION_ICON = "dialog-information";

        private bool was_activated = false;

        public App () {
            Object(application_id: APP_ID,
                   flags: ApplicationFlags.FLAGS_NONE);
        }

        protected static bool run_rclp_paste () {
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

                print ("stdout:\n");
                print (rclp_stdout);
                print ("stderr:\n");
                print (rclp_stderr);
                print ("status: %d\n", rclp_status);
            } catch (SpawnError e) {
                print ("Error: %s\n", e.message);
                return false;
            }

            return true;
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
            stdout.printf ("setting up a timer\n");
            var time = new TimeoutSource (RCLP_PASTE_INTERVAL);
            time.set_callback (() => {
                stdout.printf ("calling rclp!\n");
                var result = run_rclp_paste ();
                stdout.printf (@"rclp result: $(result)\n");

                if (!result) {
                    show_notification("rclp not updated", "failed to update");
                }

                return result ? Source.CONTINUE : Source.REMOVE;
            });
            time.attach ();
        }

        private void show_notification (string title, string content) {
            try {
                var notification = new Notify.Notification (title,
                                                            content,
                                                            NOTIFICATION_ICON);
                notification.show ();
            } catch (Error e) {
                error ("Error: %s", e.message);
            }
        }

        public static int main (string[] args) {
            stdout.printf ("main\n");

            var app = new App ();
            return app.run (args);
        }
    }
}
