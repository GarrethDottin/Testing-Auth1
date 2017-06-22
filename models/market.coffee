
module.exports = class Market extends require('./model')

	defaults: 
		action: 'buy'
		crypto: 'btc'
		fiat: 'usd'

	initialize: () ->

		try 
			@sync_values 'user', ['accounts', 'countries', 'country', 'fiat', 'fiat_symbol', 'payments_config', 'country_config', 'fiat_remaining', 'percent_remaining', 'current_action', 'bank_accounts', 'credit_cards', 'has_payment_method', 'user_verified']
			@sync_values 'tickers', ['quote', 'data']
		catch e 
			app.trigger 'error', e

		@on 'change:payments_config', @set_market
		@set_market()

	set_market: () ->
		payments_config = @get('payments_config')
		if payments_config?
			@set('market', payments_config['market'])


