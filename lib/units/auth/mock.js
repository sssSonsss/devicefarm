/**
* Copyright © 2019-2024 contains code contributed by Orange SA, authors: Denis Barbaron - Licensed under the Apache license 2.0
**/

var http = require('http')

var express = require('express')
var cookieSession = require('cookie-session')
var bodyParser = require('body-parser')
var serveStatic = require('serve-static')
var csrf = require('@dr.pogodin/csurf')
var Promise = require('bluebird')
var cors = require('cors')
var basicAuth = require('basic-auth')

var logger = require('../../util/logger')
var requtil = require('../../util/requtil')
var jwtutil = require('../../util/jwtutil')
var pathutil = require('../../util/pathutil')
var path = require('path')
var urlutil = require('../../util/urlutil')
var lifecycle = require('../../util/lifecycle')

const dbapi = require('../../db/api')

module.exports = function(options) {
  var log = logger.createLogger('auth-mock')
  var app = express()
  var server = Promise.promisifyAll(http.createServer(app))

  lifecycle.observe(function() {
    log.info('Waiting for client connections to end')
    return server.closeAsync()
      .catch(function() {
        // Okay
      })
  })

  // BasicAuth Middleware
  var basicAuthMiddleware = function(req, res, next) {
    function unauthorized(res) {
      res.set('WWW-Authenticate', 'Basic realm=Authorization Required')
      return res.send(401)
    }

    var user = basicAuth(req)

    if (!user || !user.name || !user.pass) {
      return unauthorized(res)
    }

    if (user.name === options.mock.basicAuth.username &&
        user.pass === options.mock.basicAuth.password) {
      return next()
    }
    else {
      return unauthorized(res)
    }
  }

  app.set('view engine', 'pug')
  app.set('views', pathutil.resource('auth/mock/views'))
  app.set('strict routing', true)
  app.set('case sensitive routing', true)

  app.use(cors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-XSRF-TOKEN']
  }))

  app.use(cookieSession({
    name: options.ssid
  , keys: [options.secret]
  // FIX: Remove domain to allow sharing cookies across localhost ports
  // OLD: domain: 'localhost' - restricts to specific port
  // NEW: No domain - allows sharing between ports 7105, 7120, 3700
  , secure: false
  , sameSite: 'lax'
  }))
  app.use(bodyParser.json())
  app.use(csrf({
    cookie: false,
    value: function (req) {
      return req.get('X-XSRF-TOKEN') || req.body._csrf
    }
  }))
  app.use('/static/bower_components',
    serveStatic(pathutil.resource('bower_components')))
  app.use('/static/auth/mock', serveStatic(pathutil.resource('auth/mock')))
  app.use('/static/app/build', express.static(path.resolve(__dirname, '../../../static/app/build')))

  app.use(function(req, res, next) {
    res.cookie('XSRF-TOKEN', req.csrfToken(), {
      // FIX: Remove domain to allow sharing XSRF token across localhost ports
      // OLD: domain: 'localhost' - restricts to specific port
      // NEW: No domain - allows sharing between ports 7105, 7120, 3700
      secure: false,
      sameSite: 'lax'
    })
    next()
  })

  if (options.mock.useBasicAuth) {
    app.use(basicAuthMiddleware)
  }

  app.disable('x-powered-by')

  app.get('/', function(req, res) {
    res.redirect('/auth/mock/')
  })

  app.get('/auth/contact', function(req, res) {
    dbapi.getRootGroup().then(function(group) {
      res.status(200)
        .json({
          success: true
        , contact: group.owner
        })
    })
    .catch(function(err) {
      log.error('Unexpected error', err.stack)
      res.status(500)
        .json({
          success: false
        , error: 'ServerError'
        })
      })
  })

  app.get('/auth/mock/', function(req, res) {
    res.render('index')
  })

  app.post('/auth/api/v1/mock', requtil.validators.mockLoginValidator, function(req, res) {
    var log = logger.createLogger('auth-mock')
    log.setLocalIdentifier(req.ip)
    switch (req.accepts(['json'])) {
      case 'json':
        requtil.validate(req)
          .then(function() {
            return dbapi.checkUserBeforeLogin(req.body)
          })
          .then(function(isValidCredential) {
            if (!isValidCredential) {
              return Promise.reject('InvalidCredentialsError')
            }
            return isValidCredential
          })
          .then(function() {
            log.info('Authenticated "%s"', req.body.email)
            var token = jwtutil.encode({
              payload: {
                email: req.body.email
              , name: req.body.name
              }
            , secret: options.secret
            , header: {
                exp: Date.now() + 24 * 3600
              }
            })
            res.status(200)
              .json({
                success: true
              , redirect: urlutil.addParams(options.appUrl, {
                  jwt: token
                })
              })
          })
          .catch(requtil.ValidationError, function(err) {
            res.status(400)
              .json({
                success: false
              , error: 'ValidationError'
              , validationErrors: err.errors
              })
          })
          .catch(function(err) {
            if (err === 'InvalidCredentialsError') {
              log.warn('Authentication failure for "%s"', req.body.email)
              res.status(400)
                .json({
                  success: false
                , error: 'InvalidCredentialsError'
                })
            }
            else {
              log.error('Unexpected error', err.stack)
              res.status(500)
                .json({
                  success: false
                , error: 'ServerError'
                })
            }
          })
        break
      default:
        res.send(406)
        break
    }
  })

  server.listen(options.port)
  log.info('Listening on port %d', options.port)
}
