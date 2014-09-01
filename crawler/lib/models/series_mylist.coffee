Promise = require 'ypromise'
_ = require 'lodash'
knex = require('knex')(require '../../config/database')
bookshelf = require('bookshelf')(knex)

SeriesMylist = bookshelf.Model.extend
  tableName: 'series_mylists'

module.exports = SeriesMylist
