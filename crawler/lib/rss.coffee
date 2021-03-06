request = require 'request'
Promise = require('ypromise')
_ = require 'lodash'
$ = require 'cheerio'

class RSS
  constructor: (args) ->
    @page = 0
    @movieStack = []

    @rssUrl = args.rssUrl
    @searchWord = args.searchWord

  nextMovie: ->
    if @movieStack.length <= 0
      @page += 1
      @scrapePage(@page)
        .then (array) =>
          return Promise.reject new Error "Reached to the last page" if _.isEmpty array
          @movieStack = array
          @movieStack.shift()
        .catch (error) -> Promise.reject error
    else
      Promise.resolve @movieStack.shift()

  scrapePage: (page) ->
    @getRss(page).then (xml) => (@splitToMovie xml).map (text) => @parseMovieInfo text

  getRss: (page) ->
    new Promise (resolve, reject) =>
      request "#{@rssUrl}/#{@searchWord}?page=#{page}&sort=f&rss=2.0", (err, response, body) ->
        resolve body

  splitToMovie: (xml) -> _.toArray $.load(xml)("item").map -> $(@).html()

  parseMovieInfo: (xml) ->
    video_id: xml.match(/\<link\>http:\/\/www\.nicovideo\.jp\/watch\/(sm|nm)\d{1,}/g)[0].replace /\<link\>http:\/\/www\.nicovideo\.jp\/watch\//g, ''
    published_at: Date.parse $.load(xml)("pubDate").text()
    description: ($.load(xml)("description").html().match(/\<p\sclass=\"nico-description\"\>.+(?=\<\/p\>)/g) || [''])[0].replace(/\<p\sclass=\"nico-description\"\>/g, '')

module.exports = RSS
