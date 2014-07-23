fs = require 'fs'
request = require 'request'
Promise = require('ypromise')
Levenshtein = require 'levenshtein'
_ = require 'lodash'
Crawler = require './lib/crawler'
Util = require './lib/util'

auth = JSON.parse fs.readFileSync "./auth.json"

getAllPartOneMovieMeta = ->
  new Promise (resolve, reject) ->
    request "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/_all_docs?include_docs=true", (err, message, response) ->
      console.log err if err
      resolve (JSON.parse response).rows

crawlPartOneMovie = ->
  console.log "start crawling part one movies"

  crawler = new Crawler.RSS
    rssUrl: "http://www.nicovideo.jp/tag"
    searchWord: "ゆっくり実況プレイpart1リンク"

  latestMovieInfo = null
  newPartOneMovies = []

  getLatestMovieInfo = ->
    getAllPartOneMovieMeta()
      .then (partOneMovies) ->
        sorted = if _.isEmpty partOneMovies
          nullDoc = { doc: { published: 0 } }
          [nullDoc]
        else
          (_.sortBy partOneMovies, (element) -> element.doc.published)
        latestMovieInfo = sorted.pop().doc

  crawl = ->
    crawler.nextMovie()
      .then (movieInfo) =>
        if shouldTerminate movieInfo
          console.log "Reached to the movie that is scraped last time"
          console.log "Terminated crawling part one movie successfully"
        else
          newPartOneMovies.push movieInfo
          crawl()
      .catch (error) ->
        if error = "Reached to the last page"
          console.log error
          console.log "Terminated crawling part one movie successfully"
          return Promise.resolve()
        else
          console.error "Stop at crawling part one movie"
          Promise.reject error

  shouldTerminate = (movieInfo) ->
    (movieInfo.published <= latestMovieInfo.published) || _.isEmpty movieInfo

  getLatestMovieInfo()
    .then(crawl)
    .then -> Promise.resolve newPartOneMovies
    .catch (error) ->
      console.error "Stop at crawling part one movie"
      Promise.reject error

retrieveNewSeriesMylists = (newPartOneMovies) ->
  console.log "Start retrieving new series mylists"

  getNewSeriesMylists = ->
    promises = newPartOneMovies.map (movie) -> -> retrieveNewSeriesMylist movie
    results = []
    promises.reduce (previous, current) ->
      previous.then(current).then (result) -> results.push result
    , Promise.resolve()

  getAverageLevenshtein = (mylistId) ->
    new Crawler.MylistRSS(mylistId).allMovies()
      .then (movieInfos) ->
        titles = movieInfos.map (movieInfo) -> movieInfo.title
        averageLevenshtein = Util.average ((Util.combination titles).map (combination) -> (new Levenshtein combination[0], combination[1]).distance)
        { mylistId: mylistId, averageLevenshtein }

  retrieveNewSeriesMylist = (newPartOneMovie) ->
    promises = retrieveMylistsIds(newPartOneMovie).map (mylistId) -> -> getAverageLevenshtein(mylistId)
    results = []
    promises.reduce (previous, current) ->
      previous.then(current).then (result) -> results.push result
    , Promise.resolve()

  retrieveMylistsIds = (newPartOneMovie) ->
    (newPartOneMovie.description.match(/mylist\/\d{1,}/g) || []).map (string) -> string.replace /mylist\//g, ''

  Promise.resolve()
    .then getNewSeriesMylists
    .then (newSeriesMylists) -> Promise.resolve newSeriesMylists, newPartOneMovies
    .catch (error) ->
      console.error "Stop at retrieving new series mylist"
      Promise.reject error

storeNewMovies = (newPartOneMovies=[], newSeriesMylists=[])->
  console.log "Start to store new movies"

  storeInCouchDB = (movieInfo) ->
    request
      url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/"
      method: "POST"
      headers:
        "Content-type": "application/json"
      body: JSON.stringify _.omit movieInfo, 'description'
    , (err, message, response) ->
      console.log err if err

  storeInMainDB = (movieInfo) ->
    console.log movieInfo

  newPartOneMovies.forEach (movieInfo) -> storeInCouchDB movieInfo
  newSeriesMylists.forEach (movieInfo) -> storeInMainDB movieInfo

removeAllPartOneMovieDocs = ->
  getAllPartOneMovieMeta().then (partOneMovies) ->
    removeMovies (_.sortBy partOneMovies, (element) -> element.doc.published).reverse()

removeRecentPartOneMovieDocs = (number) ->
  getAllPartOneMovieMeta().then (partOneMovies) ->
    removeMovies (_.sortBy partOneMovies, (element) -> element.doc.published).reverse().slice 0, number

removeInvalidPartOneMovieDocs = ->
  getAllPartOneMovieMeta().then (partOneMovies) ->
    removeMovies (_.filter partOneMovies, (element) -> _.isUndefined element.doc.published)

removeMovie = (movie) ->
  new Promise (resolve, reject) ->
    request
      url: "https://#{auth.user}:#{auth.password}@hdemon.cloudant.com/yukkuri-ranking/#{movie.id}?rev=#{movie.value.rev}"
      method: "DELETE"
    , (err, message, response) ->
      console.log err if err
      resolve()

removeMovies = (movies) ->
  Promise.all movies.map (movie) -> removeMovie movie


resetPartOneMovies = ->
  Promise.resolve()
    .then removeAllPartOneMovieDocs
    .then crawlPartOneMovie
    .then storeNewMovies
    .catch (error) => console.trace error


Promise.resolve()
  .then -> removeRecentPartOneMovieDocs(5) # for test
  .then removeInvalidPartOneMovieDocs
  .then crawlPartOneMovie
  .then retrieveNewSeriesMylists
  .then storeNewMovies
  .catch (error) => console.trace error
