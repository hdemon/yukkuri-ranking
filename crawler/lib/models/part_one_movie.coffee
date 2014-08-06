Promise = require 'ypromise'
_ = require 'lodash'
knex = require('knex')(require '../../config/database')
bookshelf = require('bookshelf')(knex)

PartOneMovie = bookshelf.Model.extend
  tableName: 'part_one_movies'
  fetchLatest: ->
    PartOneMovie.query (qb) ->
      qb.orderBy 'published_at', 'ASC'
    .fetch()

  removeRecently: (num) ->
    PartOneMovie.query (qb) ->
      qb.orderBy('published_at', 'ASC').limit num
        .delete()

module.exports = PartOneMovie
