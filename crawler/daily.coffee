Task = require './lib/task'
Promise = require 'ypromise'

tmp = {}

Promise.resolve()
  .then -> Task.PartOneMovie.removeRecentPartOneMovieDocs(5) # for test
  .then Task.PartOneMovie.crawlLatests
  .then (partOneMovies) -> tmp.partOneMovies = partOneMovies
  .then Task.SeriesMylist.retrieveSequentially
  .then (seriesMylists) -> [tmp.partOneMovies, seriesMylists]
  .then Task.Store.newMovies
  .catch (error) -> console.trace error
