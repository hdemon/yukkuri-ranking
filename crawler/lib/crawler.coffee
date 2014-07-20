request = require 'request'
Promise = require 'bluebird'
_ = require 'lodash'
$ = require 'cheerio'

Crawler = {}
class Crawler.PartOneMovie
  constructor: (rssUrl) ->
    @page = 1
    @movieStack = []

  nextMovie: ->
    if @movieStack.length <= 0
      @page += 1 if @page != 1
      @scrapePage(@page).then (array) =>
        @movieStack = array
        @movieStack.shift()
    else
      new Promise(resolve, reject) => resolve @movieStack.shift()

  scrapePage: (page) ->
    @getRss(page).then (xml) => (@splitToMovie xml).map (text) => @parseMovieInfo text

  getRss: (page) ->
    new Promise (resolve, reject) ->
      request "http://www.nicovideo.jp/tag/ゆっくり実況プレイpart1リンク?page=#{page}&sort=f&rss=2.0", (err, response, body) ->
        resolve body

  splitToMovie: (xml) ->
    _.toArray $.load(xml)("item").map -> $(@).html()

  parseMovieInfo: (xml) ->
    id: xml.match(/\<link\>http:\/\/www\.nicovideo\.jp\/watch\/(sm|nm)\d{1,}/g)[0].replace /\<link\>http:\/\/www\.nicovideo\.jp\/watch\//g, ''
    published: Date.parse $.load(xml)("pubDate").text()

module.exports = Crawler
