import socket from "./socket"
import Tracker from "./tracker"

class Pusher {
    constructor(app_key) {
        this.tracker = new Tracker()
        this.socket = socket.init("/socket/application", {app_key: app_key})
        this.socket.connect()
        this.channel = this.socket.channel("rt:top-links:" + app_key, () => {
          return {
            limit: 10,
            tracker: this.tracker.get()
           }
        })

        this.channel
              .join()
              .receive("error", reason => console.log("error!", reason))

        this._handle()
    }

    _handle() {
        let {current_url, referer_url} = this.tracker.get()
        let links = {
            links_to_push: [],
            links_to_drop: [],
        }

        if (current_url === referer_url) {
            return
        }

        if (current_url) {
            links.links_to_push = [current_url]
        }

        if (referer_url) {
            links.links_to_drop = [referer_url]
        }

        this._push(links)
    }

    _push(links) {
        this.channel
            .push("push_links", links)
            .receive("error", reason => console.log("push_link error", reason))
    }
}

let instance = null

let pusher = {
    init: (app_key) => {
        if (instance === null) {
            instance = new Pusher(app_key)
        }
    }
}

export default pusher