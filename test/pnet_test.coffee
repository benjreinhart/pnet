URL = require 'url'
pnet = require '../'
sinon = require 'sinon'
request = require 'request'
{expect} = require 'chai'

parseQueryString = (qs) ->
  qs.split('&').reduce ((memo, pair) ->
    [key, value] = pair.split('=')
    memo[key] = value
    memo
  ), {}

describe 'pnet', ->
  afterEach ->
    request.get.restore?()
    pnet.apikey undefined

  describe '#get', ->
    stubs =
      august2013: require('./stubs/august_2013_shows')
      halloween2013: require('./stubs/2013-10-31')

    describe 'successful responses', ->
      beforeEach ->
        sinon.stub request, 'get', (url, cb) ->
          process.nextTick(cb.bind null, null, {statusCode: 200}, JSON.stringify(stubs.august2013))

      it 'make the request with a valid url', (done) ->
        pnet.get 'shows.query', {year: 2013, month: 8, apikey: 123456}, (err, _, results) ->
          expect(request.get.calledOnce).to.be.true

          # Asserts against what `request#get` was called with
          parsedUrl = URL.parse(request.get.firstCall.args[0])
          queryParams = parseQueryString(parsedUrl.query)

          expect(parsedUrl.protocol).to.equal 'https:'
          expect(parsedUrl.host).to.equal 'api.phish.net'
          expect(parsedUrl.pathname).to.equal '/api.js'
          expect(queryParams.method).to.equal 'pnet.shows.query'
          expect(queryParams.year).to.equal '2013'
          expect(queryParams.month).to.equal '8'
          expect(queryParams.apikey).to.equal '123456'

          done()

      it 'requests the resource and returns the requested URL and the parsed response body', (done) ->
        pnet.get 'shows.query', {year: 2013, month: 8, apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true

          # Asserts against the second callback argument
          parsedUrl = URL.parse(url)
          queryParams = parseQueryString(parsedUrl.query)

          expect(parsedUrl.protocol).to.equal 'https:'
          expect(parsedUrl.host).to.equal 'api.phish.net'
          expect(parsedUrl.pathname).to.equal '/api.js'
          expect(queryParams.method).to.equal 'pnet.shows.query'
          expect(queryParams.year).to.equal '2013'
          expect(queryParams.month).to.equal '8'
          expect(queryParams.apikey).to.equal '123456'

          expect(results).to.deep.equal(stubs.august2013)

          done()


    # SETLIST_METHODS = [
    #   "pnet.shows.setlists.get"
    #   "pnet.shows.setlists.latest"
    #   "pnet.shows.setlists.random"
    #   "pnet.shows.setlists.recent"
    #   "pnet.shows.setlists.tiph"
    # ]
    #
    # These methods return setlists in html, which have
    # to be parsed out. The following tests assert that
    # when the requesting method is in this list, then
    # the setlists are properly parsed out.
    #
    describe 'requesting setlist methods', ->
      responses =
        halloween2013: require('./stubs/2013-10-31_parsed_response')

      beforeEach ->
        sinon.stub request, 'get', (url, cb) ->
          process.nextTick(cb.bind null, null, {statusCode: 200}, JSON.stringify(stubs.halloween2013))

      it 'parses out the setlist when the requesting method is `get`', (done) ->
        method = 'shows.setlists.get'

        pnet.get method, {showdate: '2013-10-31', apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(results).to.deep.equal responses.halloween2013

          done()

      it 'parses out the setlist when the requesting method is `latest`', (done) ->
        method = 'shows.setlists.latest'

        pnet.get method, {apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(results).to.deep.equal responses.halloween2013

          done()

      it 'parses out the setlist when the requesting method is `random`', (done) ->
        method = 'shows.setlists.random'

        pnet.get method, {apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(results).to.deep.equal responses.halloween2013

          done()

      it 'parses out the setlist when the requesting method is `recent`', (done) ->
        method = 'shows.setlists.recent'

        pnet.get method, {apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(results).to.deep.equal responses.halloween2013

          done()

      it 'parses out the setlist when the requesting method is `tiph`', (done) ->
        method = 'shows.setlists.tiph'

        pnet.get method, {apikey: 123456}, (err, url, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(results).to.deep.equal responses.halloween2013

          done()


    describe 'error responses', ->
      it 'returns an error when something goes wrong', (done) ->
        sinon.stub request, 'get', (url, cb) ->
          process.nextTick(cb.bind null, (new Error 'Something went wrong'))

        pnet.get 'shows.query', {year: 2013, month: 8, apikey: 123456}, (err, _, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(err.message).to.equal 'Something went wrong'

          done()

      it 'returns an error if the response success code is 0', (done) ->
        sinon.stub request, 'get', (url, cb) ->
          process.nextTick(cb.bind null, null, {statusCode: 200}, '{"success": 0, "reason": "General API Error"}')

        pnet.get 'shows.setlists.get', { showdate: '2013-11-05', apikey: 123456}, (err, _, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(err.message).to.equal 'General API Error'

          done()

      it 'returns an error if the http status code is not in the 200-300 range', (done) ->
        sinon.stub request, 'get', (url, cb) ->
          process.nextTick(cb.bind null, null, {statusCode: 500}, '')

        pnet.get 'shows.setlists.get', { showdate: '2013-11-05', apikey: 123456}, (err, _, results) ->
          expect(request.get.calledOnce).to.be.true
          expect(err.message).to.equal 'Response returned status code 500'

          done()

    describe 'with invalid params results in an error', ->
      beforeEach ->
        sinon.spy request, 'get'

      it 'returns an error when the method is null', (done) ->
        pnet.get null, {}, (err, _, result) ->
          expect(err.message).to.equal 'method must be a valid phish.net API method'
          expect not request.get.called

          done()

      it 'returns an error when the method is not a valid phish.net API method', (done) ->
        pnet.get 'pnet.i.dont.exist', {}, (err, _, result) ->
          expect(err.message).to.equal 'method must be a valid phish.net API method'
          expect not request.get.called

          done()

      it 'returns an error when the showdate is incorrectly formatted', (done) ->
        pnet.get 'shows.setlists.get', {showdate: '2013-8-5'}, (err, _, result) ->
          expect(err.message).to.equal 'showdate must be in the format YYYY-MM-DD'
          expect not request.get.called

          done()

  describe '#apikey', ->
    beforeEach ->
      sinon.stub request, 'get', (url, cb) ->
        process.nextTick(cb.bind null, null, {}, '[{}]')

    it 'sets a default apikey', (done) ->
      expect(pnet.apikey()).to.be.undefined

      pnet.apikey 'myapikey'
      expect(pnet.apikey()).to.equal 'myapikey'

      pnet.get 'shows.query', {year: 2013, month: 8}, (err, _, results) ->
        expect(request.get.calledOnce).to.be.true
        parsedUrl = URL.parse(request.get.firstCall.args[0])
        expect(parseQueryString(parsedUrl.query).apikey).to.equal 'myapikey'

        done()

    it 'allows the default to be overriden', (done) ->
      expect(pnet.apikey()).to.be.undefined

      pnet.apikey 'myapikey'
      expect(pnet.apikey()).to.equal 'myapikey'

      pnet.get 'shows.query', {year: 2013, month: 8, apikey: 123}, (err, _, results) ->
        expect(request.get.calledOnce).to.be.true
        parsedUrl = URL.parse(request.get.firstCall.args[0])
        expect(parseQueryString(parsedUrl.query).apikey).to.equal '123'

        done()

    it 'is removed when passed undefined', (done) ->
      pnet.apikey 'key'
      pnet.apikey undefined

      pnet.get 'shows.query', {year: 2013, month: 8}, (err, _, results) ->
        expect(request.get.calledOnce).to.be.true
        parsedUrl = URL.parse(request.get.firstCall.args[0])

        # If the apikey property is set to null or undefined instead
        # of being removed from the defaults object, then it will be
        # added to the resulting query string as the string 'null'
        # or 'undefined'.
        #
        # This expectation ensures that it was properly removed when passed `undefined`
        expect(parseQueryString(parsedUrl.query).apikey).to.be.undefined

        done()

    it 'is removed when passed null', (done) ->
      pnet.apikey 'key'
      pnet.apikey null

      pnet.get 'shows.query', {year: 2013, month: 8}, (err, _, results) ->
        expect(request.get.calledOnce).to.be.true
        parsedUrl = URL.parse(request.get.firstCall.args[0])

        # If the apikey property is set to null or undefined instead
        # of being removed from the defaults object, then it will be
        # added to the resulting query string as the string 'null'
        # or 'undefined'.
        #
        # This expectation ensures that it was properly removed when passed `null`
        expect(parseQueryString(parsedUrl.query).apikey).to.be.undefined

        done()
