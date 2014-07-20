request = require 'request'
Promise = require 'bluebird'
_ = require 'lodash'
$ = require 'cheerio'

class RSS
  constructor: (args) ->
    @page = 1
    @movieStack = []

    @rssUrl = args.rssUrl
    @searchWord = args.searchWord

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
    new Promise (resolve, reject) =>
      request "#{@rssUrl}/#{@searchWord}?page=#{page}&sort=f&rss=2.0", (err, response, body) ->
        resolve body

  splitToMovie: (xml) ->
    _.toArray $.load(xml)("item").map -> $(@).html()

  parseMovieInfo: (xml) ->
    id: xml.match(/\<link\>http:\/\/www\.nicovideo\.jp\/watch\/(sm|nm)\d{1,}/g)[0].replace /\<link\>http:\/\/www\.nicovideo\.jp\/watch\//g, ''
    published: Date.parse $.load(xml)("pubDate").text()

module.exports = RSS
