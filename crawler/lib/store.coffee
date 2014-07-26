fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Util = require './util'
auth = require './auth'

Store = {}
Store.inCouchDB = (movieInfo) ->
  request
    url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/"
    method: "POST"
    headers:
      "Content-type": "application/json"
    body: JSON.stringify _.omit movieInfo, 'description'
  , (err, message, response) ->
    console.log err if err

Store.inMainDB = (movieInfo) ->
  console.log movieInfo

Store.newMovies = (newPartOneMovies=[], newSeriesMylists=[]) ->
  console.log "Start to store new movies"
  promises = []
  promises.concat newPartOneMovies.map (movieInfo) -> Store.inCouchDB movieInfo
  promises.concat newSeriesMylists.map (movieInfo) -> Store.inMainDB movieInfo
  Promise.all promises

module.exports = Store
