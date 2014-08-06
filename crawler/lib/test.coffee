Task = require './task'
Promise = require 'ypromise'
request = require 'request'
_ = require 'lodash'
P = require './models/part_one_movie'

# Task.PartOneMovie.getAllPartOneMovieMeta().then (result) ->
#   console.log result

user = process.env.YR_CLOUDANT_USER
password = process.env.YR_CLOUDANT_PASSWORD

request "https://#{user}:#{password}@hdemon.cloudant.com/yukkuri-ranking/_all_docs?include_docs=true", (err, message, response) ->
  console.log err if err
  a =  _.map (JSON.parse response).rows, (row) -> row.doc
  _.each a, (e) ->
    console.log e.video_id
    console.log e.published
    p = new P({
      video_id: e.video_id
      published_at: e.published
    })
    p.save()
