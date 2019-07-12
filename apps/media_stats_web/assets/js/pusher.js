import socket from "./socket"
import Tracker from "./tracker"

class Pusher {
    constructor(options) {
        if (typeof options.app_key !== 'string') {
            throw "app_key is required"
        }

        const app_key = options.app_key

        this.tracker = new Tracker();
        this.socket = socket.init("/socket/application", {app_key: app_key});
        this.socket.connect();
        this.channel = this.socket.channel("rt:top-links:" + app_key, () => {
          return {
            limit: 10,
            tracker: this.tracker.get()
           }
        });

        this.channel
              .join()
              .receive("error", reason => console.log("error!", reason));

        this._handle()
    }

    _handle() {
        let {current_url} = this.tracker.get();


        if (current_url) {
            this._push(current_url)
        }
    }

    _push(link) {
        this.channel
            .push("push_link", {link: link})
            .receive("error", reason => console.log("push_link error", reason))
    }
}

let instance = null;

let pusher = {
    init: (app_key) => {
        if (instance === null) {
            instance = new Pusher(app_key)
        }
    }
};

export default pusher