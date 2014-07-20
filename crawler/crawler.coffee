fs = require 'fs'
request = require 'request'
Promise = require 'bluebird'
_ = require 'lodash'
Crawler = require './lib/crawler'

crawler = new Crawler.RSS
  rssUrl: "http://www.nicovideo.jp/tag"
  searchWord: "ゆっくり実況プレイpart1リンク"

auth = JSON.parse fs.readFileSync "./auth.json"

latestMovieInfo = null

getLatestMovieInfo = ->
  new Promise (resolve, reject) ->
    request "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/_all_docs?include_docs=true", (err, message, response) ->
      console.log err if err
      stored = (JSON.parse response).rows
      resolve latestMovieInfo = (_.last (_.sortBy stored, (element) -> element.doc.published)).doc

crawl = ->
  crawler.nextMovie().then (movieInfo) =>
    until shouldTerminate movieInfo
      store movieInfo
      crawl()
    console.log "terminated"

shouldTerminate = (movieInfo) ->
  (movieInfo.published <= latestMovieInfo.published) || _.isEmpty movieInfo

store = (movieInfo) ->
  request
    url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/"
    method: "POST"
    headers:
      "Content-type": "application/json"
    body: JSON.stringify movieInfo
  , (err, message, response) ->
    console.log movieInfo
    console.log err if err
    console.log response

getLatestMovieInfo().then crawl
