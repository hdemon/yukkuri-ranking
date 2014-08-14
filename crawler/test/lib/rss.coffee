sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
fs = require 'fs'
nock = require 'nock'
Crawler = require '../../lib/crawler.coffee'

describe "Crawler.RSS", ->
  describe "nextMovie", ->
    beforeEach (done) ->
      mock = nock('http://www.nicovideo.jp')
        .get("/tag/ゆっくり実況プレイpart1リンク?page=1&sort=f&rss=2.0")
        .reply(200, fs.readFileSync("test/fixture/search_result.xml"))

      crawler = new Crawler.RSS
        rssUrl: "http://www.nicovideo.jp/tag"
        searchWord: "ゆっくり実況プレイpart1リンク"

      crawler.nextMovie().then (movieInfo) =>
        @result = movieInfo
        mock.done()
        done()

    it "should return hash of latest movie info", ->
      expect(@result.video_id).to.deep.equal "sm24040823"
      expect(@result.published).to.deep.equal 1405774813000
      expect(@result.description).to.be.a 'string'
