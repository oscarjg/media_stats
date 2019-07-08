import Cookies from "js-cookie"

const COOKIE_NAME =  "media-stats-tracker";

export default class Tracker {
    constructor() {
        this.id = null;
        this.current_url = null;
        this.app_version = null;

        this._handle_user_cookie();
        this._handle()
    }

    get() {
        return {
            id: this.id,
            app_version: this.app_version,
            current_url: this.current_url,
        }
    }

    setInitialCookie() {
      Cookies.set(COOKIE_NAME, {
        app_version: this._get_app_version(),
        id: this._get_id_from_cookie(),
      })
    }

    _handle_user_cookie() {
      let data = this._get_cookie_data();

      if (!data || !data.app_version || data.app_version < this._get_app_version()) {
        this.setInitialCookie()
      }
    }

    _handle() {
      this._set_current_url(this._get_browser_url());
    }

    _set_current_url(url) {
        this.current_url = url
    }

    _set_id(id) {
        this.id = id
    }

    _get_id_from_cookie() {
        let data = this._get_cookie_data();

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

    _get_app_version() {
      return process.env.APP_VERSION
    }

    _generate_id() {
      let dt = new Date().getTime()

      return'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c=='x' ? r :(r&0x3|0x8)).toString(16);
        });
    }
}