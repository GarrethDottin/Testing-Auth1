
module.exports = class Onboarding0 extends require('./model')

	defaults: 
		show_states: false
		show_operating: false
		show_not_onboarding: false
		show_onboarding: false
		countries_set: false

	initialize: () ->

		try 
			@sync_values 'user', ['country', 'state', 'name', 'address', 'dob', 'occupation', 'phone', 'config', 'countries', 'phone_verified', 'onboarding_step']
		catch e 
			app.trigger 'error', e

		if not @get('country')? or @get('country') is 'ca'
			@get_occupations()

	get_occupations: () ->

		dfd = $.post '/private/payment/processor/occupation/list',
			payment_method: 'bank_ca'
		dfd.done (data) =>
			@set('occupations', data['data'])

	check_continue: () ->

		total = 5
		completed = 0

		name = @get 'name'
		phone = @get 'phone'
		phone_verified = @get 'phone_verified'
		address = @get 'address'
		dob = @get 'dob'

		occupation = @get 'occupation'

		if name? and name isnt ''
			completed++

		if phone_verified? and phone_verified
			completed++

		if not _.isEmpty(address)
			completed++

		if not _.isEmpty(dob)
			completed++

		if @get('country') is 'ca'
			if not _.isEmpty(occupation)
				completed++
		else
			completed++

		return completed is total
