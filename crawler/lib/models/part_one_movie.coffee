Promise = require 'ypromise'
_ = require 'lodash'
knex = require('knex')(require '../../config/database')
bookshelf = require('bookshelf')(knex)

PartOneMovie = bookshelf.Model.extend
  tableName: 'part_one_movies'
  fetchLatest: ->
    @query (qb) ->
      qb.orderBy 'published_at', 'ASC'
    .fetch()

module.exports = PartOneMovie
