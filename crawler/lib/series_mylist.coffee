fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Levenshtein = require 'levenshtein'
Crawler = require './crawler'
Util = require './util'

SM = {}
SM.getNewOnes = (movies) ->
  promises = movies.map (movie) ->
    -> (SM.getAverageLevenshteinValues movie).then (levenshteinCollection) ->
      (_.min levenshteinCollection, (hash) -> hash.average).mylistId

  Promise.resolve _.compact Util.runSequentially promises

SM.getAverageLevenshtein = (mylistId) ->
  new Crawler.MylistRSS(mylistId).allMovies()
    .then (movieInfos) ->
      titles = movieInfos.map (movieInfo) -> movieInfo.title
      average = Util.average (Util.combination titles).map (combination) -> (new Levenshtein combination[0], combination[1]).distance
      { mylistId, average }
    .catch (error) -> console.trace error

SM.getAverageLevenshteinValues = (movie) ->
  Util.runSequentially SM.retrieveMylistsIds(movie).map (mylistId) ->
    -> (Util.sleep 500).then -> SM.getAverageLevenshtein mylistId

SM.retrieveMylistsIds = (movie) ->
  (movie.description.match(/mylist\/\d{1,}/g) || []).map (string) -> Number string.replace /mylist\//g, ''

SM.retrieveSequentially = (movies) ->
  console.log "Start retrieving new series mylists"

  Promise.resolve movies
    .then SM.getNewOnes
    .catch (error) ->
      console.error "Stop at retrieving new series mylist"
      Promise.reject error

module.exports = SM
