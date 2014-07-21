fs = require 'fs'
request = require 'request'
Promise = require 'bluebird'
Levenshtein = require 'levenshtein'
_ = require 'lodash'

Util = {}
Util.average = (array) ->
  (_.reduce array, ((memo, num) -> memo + num ), 0) / array.length

Util.combination = (array) ->
  result = []
  until array.length <= 0
    current = array.pop()
    result = result.concat array.map (element) -> [current, element]
  result

module.exports = Util
