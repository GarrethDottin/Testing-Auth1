
module.exports = class Settings extends require('./model')

	defaults: 
		countries_set: true

	initialize: () ->

		try 
			@sync_values 'user', ['country', 'uid', 'email', 'email_verified', 'name', 'address', 'dob', 'occupation', 'phone', 'phone_code', 'phone_verified', 'config', 'countries', 'phone_verified', 'fiat', 'state', 'email_login', 'user_verified', 'has_social_network', 'id_selfie_scanned', 'id_selfie_verified', 'id_scanned', 'id_scan_verified', 'payments_config', 'fiat_remaining', 'fiat_remaining_week', 'wallets']
		catch e 
			app.trigger 'error', e

		@events()

	events: () ->

		@on 'change:fiat', @save_fiat
		@on 'change:country', @save_country
		@on 'change:state', @save_state

	save_fiat: () ->

		$('.messenger-shown').remove()

		dfd = $.post '/private/user/update/fiat',
			user_uid: @get('uid')
			fiat: @get('fiat')
		dfd.done (data) =>
			if not data['error']
				app.notify 'success', 'Successfully updated your default currency.'
			else
				app.notify 'error', app.generic_error
		dfd.fail (data) =>
			app.notify 'error', app.generic_error

	save_country: () ->

		$('.messenger-shown').remove()

		dfd = $.post '/private/user/update/country',
			user_uid: @get('uid')
			country: @get('country')
		dfd.done (data) =>
			if not data['error']
				app.notify 'success', 'Successfully updated your country.'
			else
				app.notify 'error', app.generic_error
		dfd.fail (data) =>
			app.notify 'error', app.generic_error

	save_state: () ->

		$('.messenger-shown').remove()

		dfd = $.post '/private/user/update/state',
			user_uid: @get('uid')
			state: @get('state')
		dfd.done (data) =>
			if not data['error']
				app.notify 'success', 'Successfully updated your state.'
			else
				app.notify 'error', app.generic_error
		dfd.fail (data) =>
			app.notify 'error', app.generic_error

