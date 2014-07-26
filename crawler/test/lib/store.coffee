chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')
fs = require 'fs'
nock = require 'nock'
Store = require '../../lib/store.coffee'
chai.use(sinonChai)

fixture = JSON.parse fs.readFileSync "./test/fixture/part_one_movie/part_one_movies.json"

describe "newMovies", ->
  beforeEach (done) ->
    sinon.spy Store, 'inCouchDB'
    sinon.spy Store, 'inMainDB'

    Store.newMovies [{}, {}], [{}, {}, {}]
    done()

  afterEach (done) ->
    Store.inCouchDB.restore()
    Store.inMainDB.restore()
    done()

  it "should call inCouchDB and inMainDB methods", ->
    expect(Store.inCouchDB.callCount).to.be.equal 2
    expect(Store.inMainDB.callCount).to.be.equal 3

describe "inCouchDB", ->
describe "inMainDB", ->
