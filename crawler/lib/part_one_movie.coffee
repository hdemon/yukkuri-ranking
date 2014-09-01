require 'source-map-support'
fs = require 'fs'
request = require 'request'
EventEmitter = require('events').EventEmitter
Promise = require 'ypromise'
_ = require 'lodash'
Crawler = require './crawler'
Util = require './util'
knex = require('knex')(require '../config/database')
bookshelf = require('bookshelf')(knex)
Levenshtein = require 'levenshtein'
Model = require './models'

crawler = new Crawler.RSS
  rssUrl: "http://www.nicovideo.jp/tag"
  searchWord: "ゆっくり実況プレイpart1リンク"

event = new EventEmitter()

PO = {}

PO.getLatestMovieInfo = ->
  PO.getAllPartOneMovieMeta()
    .then (partOneMovies) ->
      sorted = if _.isEmpty partOneMovies
        nullDoc = { doc: { published: 0 } }
        [nullDoc]
      else
        _.sortBy partOneMovies, (element) -> element.doc.published
      sorted.pop().doc
    .catch Promise.reject

PO.crawl = (latestMovieInfo) ->
  Util.while (-> crawler.nextMovie()), (movieInfo={}) -> PO.shouldContinue(movieInfo, latestMovieInfo)
    .then (array) ->
      console.log "Reached to the movie that is scraped last time"
      console.log "Terminated crawling part one movie successfully"
      array
    .catch Promise.reject

PO.shouldContinue = (movieInfo, latestMovieInfo) ->
  return true if _.isEmpty movieInfo
  movieInfo.published_at >= latestMovieInfo.published_at.getTime()

PO.removeMovies = (movies) ->
  Promise.all movies.map (movie) -> PO.removeMovie movie

PO.fetchLatest = ->
  (new Model.PartOneMovie).fetchLatest().then (model) -> (model.attributes || model.endPoint().attributes)

PO.retrieveSeriesMylists = (movies) ->
  promises = movies.map (movie) ->
    ->
      Promise.resolve(movie)
        .then PO.retrieveMylistIds
        .then PO.fetchSeriesMylists
        .then PO.getAverageLevenshteins
        .then PO.minLevenshtein

  Util.runSequentially(promises).then PO.rejectEmptyValue

PO.fetchSeriesMylists = (mylistIdArray) ->
  promises = _.map mylistIdArray, (mylistId) -> (-> PO.fetchSeriesMylist mylistId)
  Util.runSequentially promises

PO.rejectEmptyValue = (array) ->
  _.reject array, (value) -> _.isEmpty value

PO.getMinLevenshtein = (hash) ->
  _.min hash, hash.average

PO.fetchSeriesMylist = (mylistId) ->
  new Crawler.MylistRSS(mylistId).allMovies()

PO.getAverageLevenshteins = (mylistsInfo) ->
  _.map mylistsInfo, (mylistInfo) ->
    return if mylistInfo.meta.description.match(/このマイリストは非公開に設定されています。/)
    {mylistInfo, average: PO.getAverageLevenshtein mylistInfo}

PO.getAverageLevenshtein = (mylistInfo) ->
  titles = mylistInfo.movies.map (movieInfo) -> movieInfo.title
  (Util.average (Util.combination titles).map (combination) -> (new Levenshtein combination[0], combination[1]).distance) || 0

PO.retrieveMylistIds = (movieInfo) ->
  (movieInfo.description.match(/mylist\/\d{1,}/g) || []).map (string) -> Number string.replace /mylist\//g, ''

PO.saveSeriesMylist = (mylistsInfo) ->
  console.log mylistsInfo

PO.crawlLatests = (transacting) ->
  console.log "start crawling part one movies"

  Promise.resolve()
    .then PO.fetchLatest
    .then PO.crawl
    .then PO.retrieveSeriesMylists
    .then PO.saveSeriesMylist
    .catch (error) ->
      console.error "Stop at crawling part one movie"
      console.trace error.stack
      Promise.reject error

module.exports = PO
