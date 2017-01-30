_       = require 'underscore'
async   = require 'async'
cheerio = require 'cheerio'
fs      = require 'fs'
Request = require 'request'

request = Request.defaults
  jar:                true
  baseUrl:            "https://www.newyorksportsclubs.com/"
  followAllRedirects: true

club = 152
day  = "01/25"

urls =
  loginToken: "/login"
  login:      "/login_check"
  classes:    "/classes/"

list = ({ parent }) ->
  { username, password } = parent
  console.info "list", username, password
  async.auto
    csrf_token: (n) ->
      request { uri: urls.loginToken }, (err, response, body) ->
        return n err if err
        csrfToken = cheerio.load(body)("[name=\"_csrf_token\"]").val()
        n err, csrfToken
    login: ["csrf_token", ({ csrf_token }, n) ->
      form = {}
      form["_#{k}"] = v for k, v of { csrf_token, username, password }
      request.post { uri: urls.login, form }, (err, res, body) ->
        n err, body
    ]
    classes: ["login", ({ login }, n) ->
      fs.writeFileSync "login.html", login
      params =
        xhr: 1
        page: 1
        "class_filter[club][]": club
        "class_filter[day]": day
      async.waterfall [
        async.apply request, { uri: urls.classes, qs: params }
        (response, body, n) ->
          console.log cheerio.load(body)
          fs.writeFile "index.html", body, n
      ], n
    ]
  , (err) ->
    console.log 'fin', err

schedule = ({ parent }) ->
  { username, password } = parent
  console.info "schedule", username, password

module.exports = { list, schedule }
