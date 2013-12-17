Path = require 'path'
config = require(Path.join __dirname, '..', 'config')
request = require 'request'

safeExtend = do ({extend} = require('underscore')) ->
  -> extend {}, arguments...

pnet = module.exports = {}

pnet.get = (method, params = {}, callback) ->
  if error = getParamErrors(method, params)?[0]
    error = new Error(error.param + ' ' + error.message)
    process.nextTick(callback.bind null, error)
    return undefined

  request.get (pnet.urlFor method, params), (err, response, body) ->
    if err? || !(200 <= +response.statusCode < 300)
      callback(err ? new Error "Response returned status code #{response.statusCode}")
    else
      try
        callback(null, parseResponseBody(body))
      catch e
        callback(e)
  undefined

do ({baseUrl, defaults} = config.pnet.api, {omit} = require('underscore')) ->
  defaults = safeExtend defaults

  pnet.apikey = (key) ->
    if arguments.length
      if key is null || key is undefined
        defaults = omit(defaults, 'apikey')
      else
        defaults.apikey = key
    else
      defaults.apikey

  pnet.urlFor = (method, params = {}) ->
    unless /^pnet\./.test(method)
      method = "pnet.#{method}"

    params = safeExtend defaults, params, {method}
    baseUrl + '?' + ("#{key}=#{value}" for own key, value of params).join '&'

getParamErrors = (method, params = {}) ->
  errors = []

  if !method?
    errors.push(param: 'method', message: 'must be a valid phish.net API method')

  if params.showdate? && !/^\d{4}-\d{2}-\d{2}$/.test(params.showdate)
    errors.push(param: 'showdate', message: 'must be in the format YYYY-MM-DD')

  (errors.length && errors) || null

parseResponseBody = (body) ->
  parsed = JSON.parse(body)

  if parsed.success? && parsed.success is 0
    throw (new Error parsed.reason ? "Request failed with success code 0")

  parsed
