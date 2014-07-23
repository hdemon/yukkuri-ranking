Task = require './lib/task'
Promise = require 'ypromise'

Promise.resolve()
  .then Task.PartOneMovie.crawlLatests
  .then (result) -> console.log result
  .catch (error) -> console.trace error
