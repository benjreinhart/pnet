Setlist = require './pnet/setlist'
{omit} = (underscore = require 'underscore')
request = require 'request'

SETLIST_METHODS = [
  "pnet.shows.setlists.get"
  "pnet.shows.setlists.latest"
  "pnet.shows.setlists.random"
  "pnet.shows.setlists.recent"
  "pnet.shows.setlists.tiph"
]

# Also acts as `clone`
safeExtend = do ({extend} = underscore) ->
  -> extend {}, arguments...

pnetConfig = safeExtend(require('../config').pnet)
pnetDefaults = safeExtend(pnetConfig.api.defaults)

pnet = module.exports = {}

pnet.get = (method, params = {}, callback) ->
  method = normalizeMethod(method)

  if error = getParamErrors(method, params)?[0]
    error = new Error(error.param + ' ' + error.message)
    process.nextTick(callback.bind null, error)
    return undefined

  url = urlFor method, params

  request.get url, (err, response, body) ->
    if err? || !(200 <= +response.statusCode < 300)
      callback(err ? new Error "Response returned status code #{response.statusCode}")
    else
      try
        callback(null, url, parseResponseBody(method, body))
      catch e
        callback(e)
  undefined

pnet.apikey = (key) ->
  return pnetDefaults.apikey unless arguments.length

  if key is null || key is undefined
    pnetDefaults = omit(pnetDefaults, 'apikey')
  else
    pnetDefaults.apikey = key


###########
# PRIVATE #
###########

normalizeMethod = (method = '') ->
  if !/^pnet\./.test(method)
    method = "pnet.#{method}"
  method

urlFor = (method, params = {}) ->
  params = safeExtend pnetDefaults, params, {method}
  pnetConfig.api.baseUrl + '?' + ("#{key}=#{value}" for own key, value of params).join '&'

getParamErrors = (method, params = {}) ->
  errors = []

  if !pnetConfig.api.methods[method]?
    errors.push(param: 'method', message: 'must be a valid phish.net API method')

  if params.showdate? && !/^\d{4}-\d{2}-\d{2}$/.test(params.showdate)
    errors.push(param: 'showdate', message: 'must be in the format YYYY-MM-DD')

  (errors.length && errors) || null

parseResponseBody = (method, body) ->
  parsed = JSON.parse(body)

  if parsed.success? && parsed.success is 0
    throw (new Error parsed.reason ? "Request failed with success code 0")

  if method in SETLIST_METHODS
    parsed = for show in parsed
      safeExtend show, Setlist.parse(show.setlistdata)

  parsed
