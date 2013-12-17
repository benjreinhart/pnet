fs = require 'fs'
{extend} = require 'underscore'

getDefaultsPath = ->
  process.env.HOME + '/.pnet'

exports.get = get = ->
  try
    JSON.parse(fs.readFileSync getDefaultsPath(), {encoding: 'utf8'})
  catch e
    {}

exports.set = (options = {}) ->
  contents = JSON.stringify (extend get(), options), null, 4
  fs.writeFileSync getDefaultsPath(), contents
