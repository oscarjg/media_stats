import Cookies from "js-cookie"

const COOKIE_NAME =  "media-stats-tracker"

export default class Tracker {
    constructor() {
        this.id          = null
        this.current_url = null
        this.referer_url = null

        this._create_user_cookie()
        this._handle()
    }

    get() {
        return {
            id: this.id,
            current_url: this.current_url,
            referer_url: this.referer_url
        }
    }

    reset() {
        this._set_current_url(null)
        this._set_referer_url(null)
    }

    _handle() {
        let cookie_id = this._get_id_from_cookie()
        let last_current_url = this._get_current_from_cookie()

        if (last_current_url) {
            this._set_referer_url(last_current_url)
        }

        this._set_current_url(this._get_browser_url())
        this._set_id(cookie_id)
    }

    _set_referer_url(url) {
        this.referer_url = url

        Cookies.set(COOKIE_NAME, this.get())
    }

    _set_current_url(url) {
        this.current_url = url
        Cookies.set(COOKIE_NAME, this.get())
    }

    _set_id(id) {
        this.id = id
        Cookies.set(COOKIE_NAME, this.get())
    }

    _create_user_cookie() {
        let data = this._get_cookie_data()

        if (!data) {
            Cookies.set(COOKIE_NAME, {})
        }
    }

    _get_current_from_cookie() {
        let data = this._get_cookie_data()

        if (!data) {
            return null
        }

        return data.current_url || null
    }

    _get_referer_from_cookie() {
        let data = Cookies.get(COOKIE_NAME)

        if (!data) {
            return null
        }

        return data.referer_url || null
    }

    _get_id_from_cookie() {
        let data = this._get_cookie_data()

        if (!data || !data.id) {
            return this._generate_id()
        }

        return data.id
    }

    _get_browser_url() {
        return window.location.href
    }

    _get_cookie_data() {
        return Cookies.getJSON(COOKIE_NAME)
    }

    _generate_id() {
        var dt = new Date().getTime()
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c=='x' ? r :(r&0x3|0x8)).toString(16);
        })

        return uuid
    }
}