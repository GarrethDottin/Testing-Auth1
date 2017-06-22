
module.exports = class Tickers extends require('./model')

	url: SITE_URL + '/ticker/btc/all'

	defaults:
		TICKER_INTERVAL: 15000

	initialize: () ->
		try 
			@sync_values 'user', ['country', 'countries', 'fiat']
		catch e 
			app.trigger 'error', e

		@set_events()
		if @get('country')
			@start_ticker_poll()

	### Events ###
		
	set_events: () ->
		@on 'change:country', @start_ticker_poll
		@on 'change:data', @set_ticker
		@on 'change:fiat', @set_ticker

	### Setters ###

	set_ticker: () ->
		data = @get('data')
		if data?
			fiat = @get('fiat')
			quote = data['btc' + fiat]
			@set('quote', quote)
			@trigger('change:quote')

	### General ###

	start_ticker_poll: () ->
		@fetch()
		if @ticker_interval?
			clearInterval @ticker_interval
		@ticker_interval = setInterval(() =>
			@fetch().done (resp) =>
				if not resp['error']
					@trigger('change:data')
		@get('TICKER_INTERVAL'))

