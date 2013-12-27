fs = require 'fs'
Path = require 'path'
nopt = require 'nopt'
defaults = require './defaults'
{extend, omit} = require 'underscore'

PACKAGE_ROOT = Path.join __dirname, '..', '..', '..'

parseColonDelimitedPairs = (pairs = []) ->
  pairs.reduce ((memo, param) ->
    if param.indexOf(':') isnt -1
      [key, value] = param.split(':')
      memo[key] = value
    memo
  ), {}

options = do ->
  opts =
    configure: [String, Array]
    date: String
    output: String
    params: [String, Array]

  aliases =
    d: '--date'
    o: '--output'
    p: '--params'

  nopt opts, aliases, process.argv, 2

if options.help
  console.log "
  USAGE: pnet method [options]

  pnet shows.setlists.get -d 2013-10-31 -o ~/setlists/halloween_2013.json

  -d, --date              Specify a `showdate` param to be used in API call.
                          Shorthand for '-p showdate:YYYY-MM-DD'
  -o, --output            Output to file instead of STDOUT
  -p, --params            Specify colon-delimited key value pairs as arguments to
                          the phish.net API; i.e. '-p venueid:123456 -p year:2012'

  --configure             Specify colon-delimited key value pairs to be used as
                          defaults for all phish.net API calls through the CLI. i.e.
                          '--configure apikey=your-api-key --configure api:2.0'
  --defaults              Print the defaults that have been set via the --configure
                          flag and exit
  --list                  List the available phish.net API methods
  --help                  Display this message and exit
  --url-only              Print phish net API url and exit instead of
                          requesting the resource
  --version               Print current version of this package and exit
  "
  process.exit 0

if options.version
  console.log(require(PACKAGE_ROOT + '/package.json').version)
  process.exit 0

if options.defaults
  console.log (JSON.stringify defaults.get(), null, 4)
  process.exit 0

if options.configure
  defaults.set(parseColonDelimitedPairs(options.configure))
  process.exit 0

if options.list
  do ({documentation, methods} = require(PACKAGE_ROOT + '/config').pnet.api) ->
    publicize = (str) ->
      '\x1B[32m' + str + '\x1B[39m'

    protect = (str) ->
      '\x1B[31m' + str + '\x1B[39m'

    message = [
      "Documentation: #{documentation.baseUrl}\n"
      publicize('Public method')
      protect('Protected method') + '\n'
    ].concat for own method, status of methods
      line = (if status.protected then protect else publicize)(method)
      spaces = 45 - line.length
      while spaces--
        line += ' '
      line + documentation.baseUrl + "/#p=#{method}"

    console.log('\n  ' + message.join('\n  ') + '\n')

  process.exit 0

#############
# API calls #
#############

params = extend defaults.get(), parseColonDelimitedPairs(options.params)
method = options.argv.remain[0] ? params.method
params = omit params, "method"

if options.date
  params.showdate = options.date

(require PACKAGE_ROOT).get method, params, (err, url, resource) ->
  if err?
    console.error(err.message ? JSON.stringify(err))
    process.exit 1

  if options['url-only']
    console.log url
    process.exit 0

  stringified = JSON.stringify(resource, null, 4)

  if options.output?
    fs.writeFileSync options.output, stringified
  else
    console.log(stringified)

  process.exit 0
