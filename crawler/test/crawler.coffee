chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
sinonChai = require('sinon-chai')

chai.use(sinonChai)

fs = require 'fs'
nock = require 'nock'
Crawler = require '../lib/crawler.coffee'

describe "nextMovie", ->
  beforeEach (done) ->
    @fixture = fs.readFileSync("test/fixture/search_result.html")
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

  it "should return html scraped by anison.info", ->
    expect(@returned).to.deep.equal { id: "sm24040823", published: 1405774813000 }
