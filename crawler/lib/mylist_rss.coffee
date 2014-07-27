request = require 'request'
Promise = require('ypromise')
_ = require 'lodash'
$ = require 'cheerio'
Util = require './util'

class MylistRSS
  constructor: (@mylistId) ->

  allMovies: -> @scrapeRss @mylistId

  scrapeRss: (mylistId) ->
    @getRss(mylistId)
      .then (@xml) =>
        Promise.resolve((@splitToMovie @xml).map (text) => @parseMovieInfo text)
      .catch (error) =>
        console.trace error
        console.error "Error caused during parse the following xml"
        console.trace @xml

  getRss: (mylistId) ->
    new Promise (resolve, reject) =>
      request "http://www.nicovideo.jp/mylist/#{mylistId}?rss=2.0", (err, response, body) =>
        if body.match /\<h1\>短時間での連続アクセスはご遠慮ください\<\/h1\>/g
          console.log "Aceessed too much"
          @retry mylistId
        else
          resolve body

  retry: (mylistId) ->
    @retryCount += 0
    new Error "Terminated because of excess retry count" if @retryCount >= 10
    console.log "Retry after 10 seconds"
    Util.sleep(10000).then => @getRss mylistId

  splitToMovie: (xml) ->
    _.toArray $.load(xml)("item").map -> $(@).html()

  parseMovieInfo: (xml) ->
    _$ = $.load(xml)
    video_id: xml.match(/\<link\>http:\/\/www\.nicovideo\.jp\/watch\/(sm|nm)?\d+/g)[0].replace /\<link\>http:\/\/www\.nicovideo\.jp\/watch\//g, ''
    title: _$("title").text()
    published: Date.parse _$("pubDate").text()
    description: _$("description").html().match(/\<p\sclass=\"nico-description\"\>.+(?=\<\/p\>)/g)[0].replace(/\<p\sclass=\"nico-description\"\>/g, '')

module.exports = MylistRSS
