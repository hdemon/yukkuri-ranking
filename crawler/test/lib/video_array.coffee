sinon = require('sinon')
chai = require('chai').use(require 'sinon-chai')
expect = chai.expect
fs = require 'fs'
nock = require 'nock'
VideoArray = require '../../lib/video_array.coffee'

describe "VideoArray", ->
  describe "nextMovie", ->
    beforeEach (done) ->
      mock = nock('http://i.nicovideo.jp')
        .get("/v3/video.array?v=sm24040823,sm24013515")
        .reply(200, fs.readFileSync("test/fixture/video_array.xml"))

      crawler = new VideoArray ['sm24040823', 'sm24013515']

      crawler.nextMovie().then (movieInfo) =>
        @result = movieInfo
        mock.done()
        done()

    it "should return hash of movie info", ->
      expect(@result.video_id).to.equal "sm24040823"
      expect(@result.view_counter).to.equal 439
      expect(@result.tags).to.deep.equal [
          "ゲーム"
          "パワポケ11"
          "ゆっくり実況プレイ"
          "ハタ人間編"
          "裏サクセス"
          "ゆっくり実況プレイpart1リンク"
        ]
