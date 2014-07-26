fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Levenshtein = require 'levenshtein'
Crawler = require './crawler'
Util = require './util'

SM = {}
SM.getNewOnes = (newPartOneMovies) ->
  promises = newPartOneMovies.map (movie) ->
    -> (SM.getAverageLevenshteinValues movie).then (levenshteinCollection) ->
      (_.min levenshteinCollection, (hash) -> hash.average).mylistId
  results = []
  promises.reduce (previous, current) ->
    previous.then(current).then (result) ->
      results.push result
      results
  , Promise.resolve()

SM.getAverageLevenshtein = (mylistId) ->
  new Crawler.MylistRSS(mylistId).allMovies()
    .then (movieInfos) ->
      titles = movieInfos.map (movieInfo) -> movieInfo.title
      average = Util.average ((Util.combination titles).map (combination) -> (new Levenshtein combination[0], combination[1]).distance)
      { mylistId, average }
    .catch (error) -> console.trace error

SM.getAverageLevenshteinValues = (newPartOneMovie) ->
  promises = SM.retrieveMylistsIds(newPartOneMovie).map (mylistId) -> -> SM.getAverageLevenshtein mylistId
  results = []
  promises.reduce (previous, current) ->
    previous.then(current).then (result) ->
      results.push result
      results
  , Promise.resolve()

SM.retrieveMylistsIds = (newPartOneMovie) ->
  (newPartOneMovie.description.match(/mylist\/\d{1,}/g) || []).map (string) -> Number string.replace /mylist\//g, ''

SM.retrieveSequentially = (newPartOneMovies) ->
  console.log "Start retrieving new series mylists"

  Promise.resolve newPartOneMovies
    .then SM.getNewOnes
    .catch (error) ->
      console.error "Stop at retrieving new series mylist"
      Promise.reject error

module.exports = SM
