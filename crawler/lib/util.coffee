fs = require 'fs'
request = require 'request'
Promise = require('ypromise')
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

Util.sleep = (second) ->
  new Promise (resolve) -> setTimeout (-> resolve()), second

Util.runSequentially = (promises) ->
  results = []
  promises.reduce (previous, current) ->
    previous.then(current).then (result) ->
      results.push result
      results
  , Promise.resolve()

Util.while = (func, condition) ->
  resultArray = []
  _loop = ->
    func()
      .then (result) ->
        resultArray.push result
        if condition.apply this, [result]
          _loop()
        else
          Promise.resolve resultArray
      .catch Promise.reject
  _loop()

module.exports = Util
