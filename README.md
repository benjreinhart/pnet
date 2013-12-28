## pnet

pnet is an API client for the [phish.net API](http://api.phish.net/). It comes with sane defaults, a command line interface and a module interface.

### Install

`npm install pnet`

If you're planning on using the CLI, it's probably best to install it globally:

`npm install -g pnet`

## Module Interface

#### get(method, params, callback) → undefined

Performs a `GET` against the phish.net API with the specified `method` and `params`.

* `method` {String} - The phish.net API method. Preceeding 'pnet.' is optional.
* `params` {Object} - Params to be passed in the API call.
* `callback` {Function} - The function to be called when the request completes or errors out. The function will be passed three arguments, the first argument is an `Error` object if one has occurred or `null`. The second argument is the requested URL and the third is the parsed JSON response from the phish.net API.

#### apikey(key) → String or undefined

Sets a default phish.net API key. When called with no args, it returns the API key.

* `key` {String|undefined|null} - When passed a value other than `null` or `undefined`, it sets the default API key to `key`. When called with 0 arguments, it returns the value that was set or `undefined`. When called explicitly with `null` or `undefined`, it unsets the current value of the API key from the default params.

### Examples

```javascript
var pnet = require('pnet');
var method = 'pnet.shows.query';
var params = {
  year: 2013,
  month: 8
}

// Set default API key to be used
pnet.apikey("a1b2c3");
pnet.apikey(); // => "a1b2c3"

pnet.get(method, params, function(err, url, parsedJSONResource){
  // do stuff
});

// Remove default apikey
pnet.apikey(undefined); // or:  pnet.apikey(null);
pnet.apikey(); // => undefined
```

## Command Line Interface

```
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
```

### CLI Examples

```
> pnet -p method:pnet.shows.setlists.get -p showdate:2013-10-31 -o ~/shows/halloween_2013.json
```

The following is shorthand for the above (optional preceeding "pnet." for the method):

```
> pnet shows.setlists.get -d 2013-10-31 -o ~/shows/halloween_2013.json
```

Since you're likely to have defaults for your API calls (i.e. apikey, api version, format), you can configure pnet with defaults.

```
> pnet --configure apikey:123456 --configure format:json --configure api:2.0
```

The above command will write those defaults to a file at `~/.pnet` and will be used on subsequent API calls through the CLI. To list the defaults you have set, you can use the `defaults` flag.

```
> pnet --defaults
{
    "format": "json",
    "api": "2.0",
    "apikey": "123456"
}
```

The pnet CLI comes with its own set of defaults which can be found in `config.json` file in the root of this repository. The defaults are:

* API base URL: `https://api.phish.net/api.js`
* format: `json`
* api: `2.0`

If you want to print the phish.net request URL to STDOUT, you can provide the `--url-only` flag, i.e.

```
> pnet shows.setlists.get -d 2013-10-31 --url-only
https://api.phish.net/api.js?api=2.0&format=json&apikey=123456&method=pnet.shows.setlists.get&showdate=2013-10-31
```

Lastly, if you want to see all the methods phish.net exposes, just `--list` them:

![pnet --list](http://f.cl.ly/items/362S0J1H2q0c172x1h06/Screen%20Shot%202013-12-28%20at%203.45.17%20PM.png)

## License

[MIT](https://github.com/benjreinhart/pnet/blob/master/LICENSE.txt)