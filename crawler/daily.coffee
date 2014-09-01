Task = require './lib/task'
Model = require './lib/models'
Promise = require 'ypromise'
knex = require('knex')(require './config/database')

Promise.resolve()
  # .then -> Model.PartOneMovie.removeRecently(5) # for test
  .then Task.PartOneMovie.crawlLatests
  # .then ->
  #   console.log "Start crawling part one movies"
  #   Task.PartOneMovie.fetchLatest().then Task.PartOneMovie.crawl
  # .then (movies) ->
  #   console.log "Start retrieving new series mylists"
  #   Task.SeriesMylist.getNewOnes movies
  # .then (partOneMovies, seriesMylists) ->
  #   Task.PartOneMovie.save partOneMovies
  #   Task.SeriesMylist.save seriesMylists
  # .catch (error) ->
  #   console.trace error
  #   console.error "Stop crawling, and rollback transaction."
  #   Promise.reject error
