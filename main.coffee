_       = require 'underscore'
async   = require 'async'
request = require 'request'

_username = ""
_password = ""
club      = 152
day       = "01/25"

urls =
  root: "https://www.newyorksportsclubs.com"
  loginToken: "/login"
  login:      "/login_check"
  classes:    "/classes/"

getUrl = (key, params) ->
  url = urls.root + urls[key]
  if params
    url += "?"
    toAppend = ("#{encodeURIComponent k}=#{encodeURIComponent v}" for k, v of params)
    console.log {toAppend}
    url += toAppend.join "&"
  url

async.auto
  _csrf_token: (n) ->
    request getUrl("loginToken"), (err, response, body) ->
      csrfToken = _.chain(body?.split('\n') or [])
        .filter (l) -> l?.match 'csrf'
        .first()
        .value()
        .match(/value="(.+)"/)?[1]
      n err, csrfToken
  login: ["_csrf_token", ({ _csrf_token }, n) ->
    form = { _username, _password, _csrf_token }
    request.post getUrl("login"), { form }, n
  ]
  classes: ["login", (n) ->
    params =
      xhr: 1
      page: 1
      "class_filter[club][]": club
      "class_filter[day]": day
    async.waterfall [
      async.apply request, getUrl("classes", params)
      (response, body) ->
        console.log {body}
    ], n
  ]
, (err) ->
  console.log 'fin', err

