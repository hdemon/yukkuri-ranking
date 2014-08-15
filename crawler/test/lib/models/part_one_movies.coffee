sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
PartOneMovie = require '../../../lib/models/part_one_movie.coffee'
knex = require('knex')(require '../../../config/database')

describe "Model.PartOneMovie", ->
  describe "fetchLatest", ->
    beforeEach (done) ->
      knex('part_one_movies').insert({published_at: new Date, video_id: 'sm1', description: 'description'})
        .insert({published_at: (new Date + 1), video_id: 'sm2', description: 'description'})
        .insert({published_at: (new Date + 2), video_id: 'sm3', description: 'description'})
        .then -> done()
        .catch (error) ->
          console.error error

    afterEach (done) ->
      knex('part_one_movies').delete().then -> done()

    it 'should store info', ->
      model = new PartOneMovie
      model.fetchLatest().then (model) ->
        expect(model.get 'video_id').to.be.equal 'sm3'
