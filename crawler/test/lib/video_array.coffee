sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
fs = require 'fs'
nock = require 'nock'
VideoArray = require '../../lib/video_array.coffee'

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

  it "should return hash of first(sm24040823) movie info", ->
    expect(@returned.video_id).to.equal "sm24040823"
    expect(@returned.view_counter).to.equal 439
    expect(@returned.tags).to.deep.equal [
        "ゲーム"
        "パワポケ11"
        "ゆっくり実況プレイ"
        "ハタ人間編"
        "裏サクセス"
        "ゆっくり実況プレイpart1リンク"
      ]
