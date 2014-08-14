sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
fs = require 'fs'
PO = require '../../lib/part_one_movie.coffee'
knex = require('knex')(require '../../config/database_test')
fixture = JSON.parse fs.readFileSync "./test/fixture/part_one_movie/part_one_movies.json"

describe "save", ->
  context "when no error has caused during transaction", ->
    beforeEach (done) ->
      knex('part_one_movies').delete()
      .then ->
        knex.transaction (transacting) ->
          array = [{video_id: "sm1", published_at: new Date}]
          PO.save(array, transacting)
        .then ->
          done()

    it "should save data into db", ->
      knex.select().table('part_one_movies')
        .then (collection) ->
          expect(collection.length).to.eql 1

  context "when some error have caused during transaction", ->
    beforeEach (done) ->
      knex('part_one_movies').delete()
      .then ->
        knex.transaction (transacting) ->
          array = [{video_id: "sm1", published_at: new Date}]
          throw new Error
          PO.save(array, transacting)
        .then ->
          done()
        .catch ->
          done()

    it "should save no data into db", ->
      knex.select().table('part_one_movies')
        .then (collection) ->
          expect(collection.length).to.eql 0

  afterEach (done) ->
    knex('part_one_movies').delete().then -> done()
