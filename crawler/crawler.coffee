fs = require 'fs'
request = require 'request'
Promise = require 'bluebird'
_ = require 'lodash'
Crawler = require './lib/crawler'

auth = JSON.parse fs.readFileSync "./auth.json"

getAllPartOneMovieMeta = ->
  new Promise (resolve, reject) ->
    request "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/_all_docs?include_docs=true", (err, message, response) ->
      console.log err if err
      resolve (JSON.parse response).rows

crawlPartOneMovie = ->
  crawler = new Crawler.RSS
    rssUrl: "http://www.nicovideo.jp/tag"
    searchWord: "ゆっくり実況プレイpart1リンク"

  latestMovieInfo = null
  newPartOneMovies = []

  getLatestMovieInfo = ->
    getAllPartOneMovieMeta().then (partOneMovies) ->
      latestMovieInfo = (_.first (_.sortBy partOneMovies, (element) -> element.doc.published).reverse()).doc

  crawl = ->
    crawler.nextMovie().then (movieInfo) =>
      if shouldTerminate movieInfo
        console.log "terminated"
      else
        newPartOneMovies.push movieInfo
        crawl()

  shouldTerminate = (movieInfo) ->
    console.log movieInfo
    console.log latestMovieInfo
    (movieInfo.published <= latestMovieInfo.published) || _.isEmpty movieInfo

  new Promise (resolve, reject) -> getLatestMovieInfo().then(crawl).then -> resolve newPartOneMovies

retrieveNewSeriesMylist = (newPartOneMovies)->
  newPartOneMovies

storeNewMovies = (newPartOneMovies=[], newSeriesMylists=[])->
  storeInCouchDB = (movieInfo) ->
    request
      url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/"
      method: "POST"
      headers:
        "Content-type": "application/json"
      body: JSON.stringify _.omit movieInfo, 'description'
    , (err, message, response) ->
      console.log err if err

  storeInLocal = (movieInfo) ->

  # console.log newPartOneMovies
  # console.log newSeriesMylists
  newPartOneMovies.forEach (movieInfo) -> storeInCouchDB movieInfo
  newSeriesMylists.forEach (movieInfo) -> storeInLocal movieInfo

removeRecentPartOneMovieDocs = (number) ->
  getAllPartOneMovieMeta().then (partOneMovies) ->
    removeMovies (_.sortBy partOneMovies, (element) -> element.doc.published).reverse().slice 0, number

removeMovies = (movies) ->
  Promise.all movies.map (movie) ->
    new Promise (resolve, reject) ->
      request
        url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/#{movie.id}?rev=#{movie.value.rev}"
        method: "DELETE"
      , (err, message, response) -> resolve()

removeRecentPartOneMovieDocs(5) # for test
  .then crawlPartOneMovie
  .then retrieveNewSeriesMylist
  .then storeNewMovies
  .then storeNewMovies
