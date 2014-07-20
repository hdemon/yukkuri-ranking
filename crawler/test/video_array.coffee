chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')
fs = require 'fs'
nock = require 'nock'
VideoArray = require '../lib/video_array.coffee'
chai.use(sinonChai)


describe "nextMovie", ->
  beforeEach (done) ->
    @fixture = fs.readFileSync("test/fixture/video_array.xml")
    @mock = nock('http://i.nicovideo.jp')
      .get("/v3/video.array?v=sm24040823,sm24013515")
      .reply(200, @fixture)

    @crawler = new VideoArray ['sm24040823', 'sm24013515']

    @crawler.nextMovie().then (movieInfo) =>
      @returned = movieInfo
      @mock.done()
      done()

  it "should return hash of latest movie info", ->
    expect(@returned).to.deep.equal { id: "sm24040823", published: 1405774813000 }
