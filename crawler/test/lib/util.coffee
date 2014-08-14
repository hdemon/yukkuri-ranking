sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
Util = require '../../lib/util.coffee'

describe "Util", ->
  describe "combination", ->
    beforeEach (done) ->
      @result = Util.combination [1, 2, 3, 4]
      done()

    it "should return combination of array input", ->
      expect(@result).to.deep.equal [ [ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 3, 1 ], [ 3, 2 ], [ 2, 1 ] ] # todo: fix to correct assertion
