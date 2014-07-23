chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')
fs = require 'fs'
nock = require 'nock'
Util = require '../../lib/util.coffee'
chai.use(sinonChai)


describe "combination", ->
  beforeEach (done) ->
    @returned = Util.combination [1, 2, 3, 4]
    done()

  it "should return hash of first(sm24040823) movie info", ->
    expect(@returned).to.deep.equal [ [ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 3, 1 ], [ 3, 2 ], [ 2, 1 ] ] # todo: fix to correct assertion
