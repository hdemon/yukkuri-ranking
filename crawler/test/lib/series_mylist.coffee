sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
fs = require 'fs'
nock = require 'nock'
Task = require '../../lib/task.coffee'

describe "retrieveSequentially", ->
  beforeEach (done) ->
    part_one_movie_infos = require "../fixture/part_one_movie/part_one_movies.json"
    # mylist described at sm24062951
    @mock1 = nock('http://www.nicovideo.jp').get("/mylist/44506319?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/44506319.xml")
    @mock2 = nock('http://www.nicovideo.jp').get("/mylist/39009529?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/39009529.xml")
    # mylist described at sm24059073
    @mock3 = nock('http://www.nicovideo.jp').get("/mylist/45062154?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/45062154.xml")
    @mock4 = nock('http://www.nicovideo.jp').get("/mylist/40202854?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/40202854.xml")
    # mylist described at sm24046423
    @mock5 = nock('http://www.nicovideo.jp').get("/mylist/45046494?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/45046494.xml")
    @mock6 = nock('http://www.nicovideo.jp').get("/mylist/39654546?rss=2.0").reply(200, fs.readFileSync "./test/fixture/part_one_movie/39654546.xml")

    Task.SeriesMylist.retrieveSequentially(part_one_movie_infos)
      .then (@returned) => done()

  it "should return hash of first(sm24040823) movie info", ->
    expect(@returned).to.include 44506319, 40202854, 45046494
    expect(@returned).not.to.include 39009529, 45062154, 39654546
