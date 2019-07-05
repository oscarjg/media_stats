// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = {
    init(endpoint, params) {
        let socket_endpoint = process.env.SOCKET_ENDPOINT

        if (process.env.SOCKET_ENDPOINT_PORT) {
          socket_endpoint += ":" + process.env.SOCKET_ENDPOINT_PORT
        }

        return new Socket("//" + socket_endpoint + endpoint, {
          params: params,
          logger: (kind, msg, data) => {
            if (process.env.ENVIRONMENT !== "prod") {
              console.log(`${kind}:${msg}`, data)
            }
          }
        })
    }
}

export default socket
