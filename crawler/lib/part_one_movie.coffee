fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Crawler = require './crawler'
Util = require './util'

auth = JSON.parse fs.readFileSync "./auth.json"

crawler = new Crawler.RSS
  rssUrl: "http://www.nicovideo.jp/tag"
  searchWord: "ゆっくり実況プレイpart1リンク"

newPartOneMovies = []

PO = {}
PO.getAllPartOneMovieMeta = ->
  new Promise (resolve, reject) ->
    request "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/_all_docs?include_docs=true", (err, message, response) ->
      console.log err if err
      resolve (JSON.parse response).rows

PO.getLatestMovieInfo = ->
  PO.getAllPartOneMovieMeta()
    .then (partOneMovies) ->
      sorted = if _.isEmpty partOneMovies
        nullDoc = { doc: { published: 0 } }
        [nullDoc]
      else
        (_.sortBy partOneMovies, (element) -> element.doc.published)
      sorted.pop().doc

PO.crawl = (latestMovieInfo) ->
  newPartOneMovies = [] unless newPartOneMovies?
  crawler.nextMovie()
    .then (movieInfo) =>
      if PO.shouldTerminate movieInfo, latestMovieInfo
        console.log "Reached to the movie that is scraped last time"
        console.log "Terminated crawling part one movie successfully"
      else
        newPartOneMovies.push movieInfo
        PO.crawl latestMovieInfo
    .catch (error) ->
      if error == "Reached to the last page"
        console.log error
        console.log "Terminated crawling part one movie successfully"
        return Promise.resolve()
      else
        console.error "Stop at crawling part one movie"
        Promise.reject error

PO.shouldTerminate = (movieInfo, latestMovieInfo) ->
  (movieInfo.published <= latestMovieInfo.published) || _.isEmpty movieInfo

PO.crawlLatests = ->
  console.log "start crawling part one movies"

  Promise.resolve()
    .then PO.getLatestMovieInfo
    .then PO.crawl
    .catch (error) ->
      console.error "Stop at crawling part one movie"
      Promise.reject error

module.exports = PO