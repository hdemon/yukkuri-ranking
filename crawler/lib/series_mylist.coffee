fs = require 'fs'
request = require 'request'
Promise = require 'ypromise'
_ = require 'lodash'
Levenshtein = require 'levenshtein'
Crawler = require './crawler'
Util = require './util'

SM = {}
SM.getNewOnes = (newPartOneMovies) ->
  promises = newPartOneMovies.map (movie) -> -> SM.retrieveNewSeriesMylist movie
  results = []
  promises.reduce (previous, current) ->
    previous.then(current).then (result) -> results.push result
  , Promise.resolve()

SM.getAverageLevenshtein = (mylistId) ->
  new Crawler.MylistRSS(mylistId).allMovies()
    .then (movieInfos) ->
      titles = movieInfos.map (movieInfo) -> movieInfo.title
      averageLevenshtein = Util.average ((Util.combination titles).map (combination) -> (new Levenshtein combination[0], combination[1]).distance)
      console.log { mylistId: mylistId, averageLevenshtein }
      { mylistId: mylistId, averageLevenshtein }
    .catch (error) -> console.trace error

SM.retrieveNewSeriesMylist = (newPartOneMovie) ->
  promises = SM.retrieveMylistsIds(newPartOneMovie).map (mylistId) -> -> SM.getAverageLevenshtein(mylistId)
  results = []
  promises.reduce (previous, current) ->
    previous.then(current).then (result) -> results.push result
  , Promise.resolve()

SM.retrieveMylistsIds = (newPartOneMovie) ->
  (newPartOneMovie.description.match(/mylist\/\d{1,}/g) || []).map (string) -> string.replace /mylist\//g, ''

SM.retrieveSequentially = (newPartOneMovies) ->
  console.log "Start retrieving new series mylists"

  Promise.resolve newPartOneMovies
    .then SM.getNewOnes
    .then (result) -> console.log result
    .catch (error) ->
      console.error "Stop at retrieving new series mylist"
      Promise.reject error

module.exports = SM
