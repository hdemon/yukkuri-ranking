request = require 'request'
Promise = require('ypromise')
_ = require 'lodash'
$ = require 'cheerio'

class VideoArray
  constructor: (@videoIds) ->
    @movieStack = []

  nextMovie: ->
    if @movieStack.length <= 0
      @scrape(@videoIds).then (array) =>
        @movieStack = array
        @movieStack.shift()
    else
      Promise.resolve @movieStack.shift()

  scrape: (videoIds) ->
    @getXml(videoIds).then (xml) => (@splitToMovie xml).map (text) => @parseMovieInfo text

  getXml: (videoIds) ->
    new Promise (resolve, reject) =>
      request "http://i.nicovideo.jp/v3/video.array?v=#{videoIds.join ','}", (err, response, body) ->
        resolve body

  splitToMovie: (xml) ->
    _.toArray $.load(xml)("video_info").map -> $(@).html()

  parseMovieInfo: (xml) ->
    _$ = $.load xml

    video_id: _$("video id").text()
    description: _$("description").text()
    thumbnail_url: _$("thumbnail_url").text()
    view_counter: Number _$("view_counter").text()
    mylist_counter: Number _$("mylist_counter").text()
    num_res: Number _$("thread num_res").text()
    main_category_key: _$("main_category_key").text()
    first_retrieve: _$("first_retrieve").text()
    tags: do ->
      _.toArray _$("tags tag_info tag").map -> $(@).text()

module.exports = VideoArray
