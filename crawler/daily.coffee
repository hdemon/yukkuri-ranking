Task = require './lib/task'
Promise = require 'ypromise'

Promise.resolve()
  .then -> Task.PartOneMovie.removeRecentPartOneMovieDocs(5) # for test
  .then Task.PartOneMovie.crawlLatests
  .catch (error) -> console.trace error
