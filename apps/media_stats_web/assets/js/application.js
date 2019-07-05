import {Presence} from "phoenix"

let Application = {
    init(socket, element, app_key) {
        if (!element) {
            return
        }

        socket.connect()

        let channel = socket.channel("rt:top-links:" + app_key, () => {
          return {limit: 10}
        })

        let presence = new Presence(channel)

        presence.onLeave((id, current, leftPres) => {
            if (typeof leftPres.metas !== 'undefined') {
                let metas   = leftPres.metas[0]

                if (typeof metas.params.tracker !== 'undefined') {
                    let tracker = metas.params.tracker
                    let links = {
                        links_to_push: [],
                        links_to_drop: [
                            tracker.current_url
                        ],
                    }

                    channel.push("push_links", links)
                }
            }
        })

        presence.onSync((id, current, join, leave) => {
          let list = presence.list()

          if (typeof list[0] !== 'undefined') {
            this.updateActiveUsers(app_key, this.calculateUniqueUsers(list[0].metas))
          }
        })

        channel.on("pushed_links", resp => {
            this.renderTopLinks(element, resp)
        })

        channel.join()
              .receive("ok", resp => {
                this.renderTopLinks(element, resp)
              })
              .receive("error", reason => console.log("error!", reason))


    },
    renderTopLinks(element, resp) {
        let containerEl = element.firstElementChild
        let template    = document.createElement("ul")
        template.className = "list-group"

        resp.top_links.forEach((obj) => {
            let url   = Object.keys(obj)[0]
            let count = Object.values(obj)[0].count

            template.innerHTML += `
                <li class="list-group-item">${url} <span class="float-right badge badge-primary badge-pill">${count}</span></li>
            `
        })

        containerEl.replaceWith(template)
    },
    updateActiveUsers(app_key, counter) {
        let el = document.querySelectorAll('[data-rt-active-users="'+app_key+'"]')

        if (el.length === 1) {
            el = el[0]
            el.innerHTML=counter
        }
    },
    calculateUniqueUsers(metas) {
        const metasWithTracker = metas.filter((meta) => {
            const params = this._getObjectProperty(meta, "params")

            if (params !== false) {
                const tracker = this._getObjectProperty(params, "tracker")

                 if (tracker !== false) {
                    const id = this._getObjectProperty(tracker, "id")

                    if (id !== false) {
                        return true;
                    }
                 }
            }

            return false;
        })

        const metasIdentifiers = metasWithTracker.map((meta) => {
            return meta.params.tracker.id
        })

        const distinctIdentifiers = [...new Set(metasIdentifiers)]

        return distinctIdentifiers.length
    },
    _getObjectProperty(object, prop) {
        return object.hasOwnProperty(prop) === true ? object[prop] : false
    }
}

export default Application