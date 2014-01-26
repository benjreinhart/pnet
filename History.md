0.1.1 / 2014-01-26
==================

* Minor cleanups
* Fix bug with try/catch block catching exceptions thrown from the callback function

0.1.0 / 2013-12-28
==================

* Added more options to CLI
* Changed signature of CLI to accept an argument as the method; removed `-m` option
* Added tests
* Added a module to parse out setlists HTML to JavaScript objects
* Changed `pnet#get`'s signature to accept `(method, params, callback)`
* Changed the signature of the callback function to `pnet#get` to receive `(err, url, parsedJSONResponse)`
* Added a method, `apikey`, which is a getter/setter for getting and setting the API key to be used with requests
* Removed `pnet#buildPhishNetUrl` method
* Updated README
* Much more robust error handling
* A **poop-ton** of other minor changes to support all the bigger changes

0.0.2 / 2013-12-15
==================

* Minor readme updates
* Fix unhandled error in the CLI

0.0.1 / 2013-12-15
==================

* Initial commit
