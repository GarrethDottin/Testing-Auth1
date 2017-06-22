
module.exports = class User extends require('./model')
		
	start: () ->
		@events()

		@set_country () =>
			@set_fiat()
			@set_occupation()
			# @set_intercom()
			# @set_raven()
			@set_snapper()
			@parse_social_objs()
			@has_social_network()
			@is_payment_method()
			@set_fiat_remaining()
			@set_methods()
			@has_payment_method()
			@set_onboarding()
			if @get('country') is 'us'
				@set_synpase_banks()

	events: () ->

		@on 'change:fiat', @set_fiat

	set_country: (cb) ->

		if @get('country')?
			return cb()

		@set('temp_country', true)

		country_data = app.basil.get('country_data')
		if country_data?
			code = country_data['code']
			code = code.toLowerCase()
			@set('country', code)
			@set('countries', country_data['countries'])
			return cb()
		else
			dfd = $.get '/location'
			dfd.done (data) =>
				if data['error']
					@set('country', 'us')
					app.trigger 'error', data
					return cb()
				@set('country', data['code'].toLowerCase())
				@set('countries', data['countries'])
				return cb()
			dfd.fail (data) =>
				@set('country', 'us')
				app.trigger 'error', data
				return cb()

	set_fiat: () ->
		try

			default_currency = @get('fiat')

			if default_currency?
				countries = @get('countries')
				country_config = @find_with_attr countries, 'currency_code', default_currency
				fiat = default_currency
				fiat_symbol = country_config['fiat_symbol']
			else
				countries = @get('countries')
				country = @get('country')
				fiat = countries[country]['currency_code']
				fiat_symbol = countries[country]['fiat_symbol']
		catch e 
			fiat = 'usd'
			fiat_symbol = 'US$'
			app.trigger 'error', e

		@set('fiat', fiat)
		@set('fiat_symbol', fiat_symbol)

	set_occupation: () ->
		occupation =  @get('meta')?['occupation_id']
		if occupation?
			@set('occupation', @get('meta')['occupation_id'])

	parse_social_objs: () ->

		facebook_object = @get 'facebook_object'
		linkedin_object = @get 'linkedin_object'
		google_object = @get 'google_object'
		name = @get 'name'

		if not _.isEmpty(facebook_object)
			profile_picture = facebook_object['avatar'] + '?type=large'
			if name is ''
				@set('name', facebook_object['firstname'] + ' ' + facebook_object['lastname'])
		else if not _.isEmpty(google_object)
			profile_picture = google_object['avatar']
			profile_picture = profile_picture.split('?')
			profile_picture = profile_picture[0] + '?sz=150'
			if name is ''
				@set('name', google_object['firstname'] + ' ' + google_object['lastname'])
		else if not _.isEmpty(linkedin_object)
			profile_picture = linkedin_object['avatar'] + '?type=large'
			if name is ''
				@set('name', linkedin_object['firstname'] + ' ' + linkedin_object['lastname'])

		@set 'profile_picture', profile_picture

	set_fiat_remaining: () ->
		
		try

			market = @get('payments_config')['market']
			fiat_totals = @get 'fiat_totals'

			fiat_remaining = market['limits']['day']['normal'] - fiat_totals['daily']
			if not @get('user_verified')
				fiat_remaining = 0
			@set 'fiat_remaining', fiat_remaining

			fiat_remaining_week = market['limits']['week']['normal'] - fiat_totals['weekly']
			if not @get('user_verified')
				fiat_remaining = 0
			@set 'fiat_remaining_week', fiat_remaining_week

			percent_remaining = (fiat_remaining/market['limits']['day']['normal']) * 100
			percent_remaining = math.round percent_remaining, 2
			if isNaN(percent_remaining)
				percent_remaining = 0
		catch e 
			app.trigger 'error', e

		@set('percent_remaining', (percent_remaining || 0))

	has_social_network: () ->

		fb = @get 'facebook_object'
		gp = @get 'google_object'
		li = @get 'linkedin_object'

		if not _.isEmpty(fb) or not _.isEmpty(gp) or not _.isEmpty(li)
			@set 'has_social_network', true
		else
			@set 'has_social_network', false

	has_payment_method: () ->

		has_payment_method = false
		bank_accounts = @get 'bank_accounts'

		if bank_accounts?
			if bank_accounts.length
				has_payment_method = true
			else
				has_payment_method = false
		else
			has_payment_method = false

		has_verified_payment_method = false

		if bank_accounts?
			for bank in bank_accounts
				if bank['verified']
					has_verified_payment_method = true
					break

		@set 'has_payment_method', has_payment_method
		@set 'has_verified_payment_method', has_verified_payment_method

	is_payment_method: () ->

		if @get('payment_method')?
			@set 'payment_method_enabled', true
		else
			@set 'payment_method_enabled', false

	set_raven: () ->

		Raven?.setUser(
			email: @get 'email'
			uid: @get 'uid'
		)

	set_snapper: () ->

		if $(window).width() < 767
			@set('snapper', true)
		else
			@set('snapper', false)

	set_methods: () ->

		methods = @get 'methods'
		try
			@set 'bank_accounts', methods['bank'] || []
			@set 'credit_cards', methods['ccard'] || []
		catch e 
			app.trigger 'error', e

	get_user: (cb) ->

		dfd = $.post '/private/user/initialize'
		dfd.done (data) ->
			if not data['error']
				user = data['data']
				cb null, user
			else
				cb new Error 'User init failed'		

	set_intercom: () ->

		if app.ENV isnt 'localhost'
			try
				window.Intercom('boot',
					app_id: "y4udu031"
					name: @get('name')
					email: @get('email')
					user_id: @get('uid')
					created_at: parseInt(@get('date_created')/1000)
				)
			catch e 
				app.trigger 'error', e

	set_onboarding: () ->

		if not @get('onboarding_step')?
			@set('onboarding_step', 0)
		if not @get('onboarding_skipped')?
			@set('onboarding_skipped', 0)

	set_synpase_banks: () ->

		bank_accounts = @get 'bank_accounts'
		synapse_banks =  @get 'synapse_banks'

		if bank_accounts? and synapse_banks?

			for bank in bank_accounts
				bank_name = bank['pp_info']?['bank_name']
				for sbank in synapse_banks['banks']
					if sbank['bank_name'] is bank_name
						bank['sbank'] = sbank
						break

		@set 'bank_accounts', bank_accounts or []


