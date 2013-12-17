Path = require 'path'
config = require(Path.join __dirname, '..', 'config')
request = require 'request'
{extend} = require 'underscore'

pnetConfig = config.pnet

exports.buildPhishNetUrl = buildPhishNetUrl = (params = {}) ->
  params = extend pnetConfig.api.defaults, params
  queryParams = ("#{key}=#{value}" for own key, value of params).join '&'
  pnetConfig.api.baseUrl + '?' + queryParams

exports.get = (params, callback) ->
  url = buildPhishNetUrl(params)

  request.get url, (err, response, body) ->
    if err?
      err.url = url
      callback(err)
    else
      try
        parsed = JSON.parse(body)
        callback(null, parsed)
      catch e
        e.url = url
        callback(e)
  undefined
