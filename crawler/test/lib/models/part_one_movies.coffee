chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')
PartOneMovie = require '../../../lib/models/part_one_movie.coffee'
chai.use(sinonChai)
knex = require('knex')(require '../../../config/database')


describe "fetchLatest", ->
  beforeEach (done) ->
    fixture = (published_at, video_id) -> {published_at, video_id}

    knex('part_one_movies').insert(fixture 2, 'sm1')
      .then knex('part_one_movies').insert(fixture 0, 'sm2')
      .then knex('part_one_movies').insert(fixture 1, 'sm3')
      .then -> done()

  afterEach (done) ->
    knex('part_one_movies').delete().then -> done()

  it 'should store info', ->
    model = new PartOneMovie
    model.fetchLatest().then (model) ->
      expect(model.get 'video_id').to.be.equal 'sm1'
