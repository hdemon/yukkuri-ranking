chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')
fs = require 'fs'
nock = require 'nock'
Crawler = require '../lib/crawler.coffee'
chai.use(sinonChai)

describe "nextMovie", ->
  beforeEach (done) ->
    @fixture = fs.readFileSync("test/fixture/search_result.xml")
    @mock = nock('http://www.nicovideo.jp')
      .get("/tag/ゆっくり実況プレイpart1リンク?page=1&sort=f&rss=2.0")
      .reply(200, @fixture)

    @crawler = new Crawler.RSS
      rssUrl: "http://www.nicovideo.jp/tag"
      searchWord: "ゆっくり実況プレイpart1リンク"

    @crawler.nextMovie().then (movieInfo) =>
      @returned = movieInfo
      @mock.done()
      done()

  it "should return hash of latest movie info", ->
    expect(@returned.video_id).to.deep.equal "sm24040823"
    expect(@returned.published).to.deep.equal 1405774813000
    expect(@returned.description).to.be.a 'string'
