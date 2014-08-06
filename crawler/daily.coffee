Task = require './lib/task'
Model = require './lib/models'
Promise = require 'ypromise'

tmp = {}

Promise.resolve()
  # .then -> Model.PartOneMovie.removeRecently(5) # for test
  .then Task.PartOneMovie.crawlLatests
  .then Task.SeriesMylist.retrieveSequentially
  .then Task.Store.newMovies
  .catch (error) -> console.trace error
