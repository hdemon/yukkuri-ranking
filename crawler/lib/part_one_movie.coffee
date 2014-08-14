require 'source-map-support'
fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Crawler = require './crawler'
Util = require './util'
knex = require('knex')(require '../config/database')
bookshelf = require('bookshelf')(knex)
Model = require './models'

crawler = new Crawler.RSS
  rssUrl: "http://www.nicovideo.jp/tag"
  searchWord: "ゆっくり実況プレイpart1リンク"

newPartOneMovies = []

PO = {}
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
      console.log "fetch: #{movieInfo.video_id}"
      if PO.shouldTerminate movieInfo, latestMovieInfo
        console.log "Reached to the movie that is scraped last time"
        console.log "Terminated crawling part one movie successfully"
        newPartOneMovies
      else
        newPartOneMovies.push movieInfo
        PO.crawl latestMovieInfo
    .catch (error) ->
      if error.message == "Reached to the last page"
        console.log "Terminated crawling part one movie successfully"
        Promise.resolve newPartOneMovies
      else
        Promise.reject error

PO.save = (newPartOneMovies, transacting) ->
  PartOneMovies = bookshelf.Collection.extend
    model: Model.PartOneMovie

  Promise.all (PartOneMovies.forge newPartOneMovies).map (model) ->
    model.save null, {transacting}

  # (PartOneMovies.forge newPartOneMovies).invoke('save', [null, {transacting}])

PO.shouldTerminate = (movieInfo, latestMovieInfo) ->
  (movieInfo.published <= latestMovieInfo.published) || _.isEmpty movieInfo

PO.removeMovie = (movie) ->
  new Promise (resolve, reject) ->
    request
      url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/#{movie.id}?rev=#{movie.value.rev}"
      method: "DELETE"
    , (err, message, response) ->
      console.log err if err
      resolve()

PO.removeMovies = (movies) ->
  Promise.all movies.map (movie) -> PO.removeMovie movie

PO.crawlLatests = (transacting) ->
  console.log "start crawling part one movies"

  Promise.resolve()
    .then -> (new Model.PartOneMovie).fetchLatest().attributes || { published: 0, video_id: "0" }
    .then PO.crawl
    .then (partOneMovies) ->
      PO.save partOneMovies, transacting
      console.log "save"
    .catch (error) ->
      console.error "Stop at crawling part one movie"
      console.error error
      Promise.reject error

module.exports = PO
