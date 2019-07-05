import socket from "./socket"
import Application from "./application"
import Pusher from "./pusher"

let Dashboard = {
    init_all_sockets() {
        let applications = document.querySelectorAll("[data-app-id]")

        if (applications.length === 0) {
            return
        }

        for (let index=0; index < applications.length; index++) {
            const app_key = applications[index].getAttribute("data-app-id")
            const _socket = socket.init("/socket/application", {app_key: app_key})

            Application.init(_socket, applications[index], app_key)
        }
    }
}

export default Dashboard