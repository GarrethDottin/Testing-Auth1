
module.exports = class Nav extends require('./model')

	initialize: () ->

		try 
			@sync_values 'user', ['name', 'fiat_symbol']
			@sync_values 'tickers', ['quote']
		catch e 
			app.trigger 'error', e

	
