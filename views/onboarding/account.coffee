template = require '../../templates/onboarding/account_info'

module.exports = class AccountInfo extends Backbone.Marionette.ItemView
	id: 'onboarding-account'
	className: 'ha-onboarding'
	template: template

	modelEvents:
		'change:occupations': 'fieldsChanged'
		'change:show_states': 'fieldsChanged'
		'change:show_not_operating': 'fieldsChanged'
		'change:show_operating': 'fieldsChanged'
		'change:phone_code': 'fieldsChanged'
		'change:countries_set': 'fieldsChanged'
		'change:show_not_operating': 'fieldsChanged'
		'change:tweet_text': 'fieldsChanged'
		'change:phone_verified': 'fieldsChanged'
		'change:onboarding_step': 'fieldsChanged'
		'change:address_text': 'fieldsChanged'
		'change:step_number': 'fieldsChanged'

	events:
		'click .func__submit_phone': 'submit_phone'
		'click .func__verify_phone': 'verify_phone'
		'keyup': 'check_continue'
		'click .func__next': 'save_and_continue'
		'keyup .func__dob_val': 'check_dob_keyup'
		'focusout .func__dob_val': 'check_dob_focusout'
		'click .func__occupation_list .item': 'add_occupation'
		'focusout .func__name_val': 'check_name_focusout'
		'keyup .func__name_val': 'check_name_keyup'
		'input .func__personal_address': 'address_input'
		'click .func__occupation_list .item': 'add_occupation'

	initialize: ->

		search_address = require '../mixins/search_address'
		Cocktail.mixin(@, require('./mixins/shared'), search_address)

		@phone_set = false
		@name_set = false
		@dob_set = false
		@dob_regex = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)\d{2}$/
		@dob_error_message = 'Please format your birthday to mm/dd/yyyy.'

		@model.set 'step_percent', 50
		@model.set 'title', 'Account'
		@model.set 'step_number', 1

		@model.on 'change:country', $.proxy @set_country, @
		
		if @model.get('phone_verified')
			@phone_set = true

	fieldsChanged: () ->

		occ = @$('.ui.dropdown.occ').dropdown('get value')
		country = @$('.search.country.dropdown').dropdown('get value')
		states = @$('.search.states.dropdown').dropdown('get value')

		@render()

		if occ.length
			@$('.ui.dropdown.occ').dropdown('set selected', occ)
		if states.length
			@$('.search.states.dropdown').dropdown('set selected', states)
		if country.length
			@$('.search.country.dropdown').dropdown('set selected', country)

		@$('.ui.dropdown.occ').dropdown()
		@$('.search.country.dropdown').dropdown(onChange: $.proxy @country_dropdown_change, @)
		@$('.search.states.dropdown').dropdown(onChange: $.proxy @state_dropdown_change, @)

		@check_continue()

	onShow: () ->

		setTimeout(() =>
			@$('.ui.dropdown.occ').dropdown()
			@$('.search.country.dropdown').dropdown()
			@$('.search.states.dropdown').dropdown()
			@set_country()
			@set_state()
			if @phone_set is true
				@$('.func__phone_val').prop('disabled', 'disabled')
				@$('.func__submit_phone').addClass('disabled').text 'Verified'
			@set_occupation()
			@set_address()
			@check_continue()
		800)
		
	onDestroy: () ->

		$('.container.main').removeClass 'onboarding'
		app.off 'check:continue'

	set_occupation: () ->

		occupation = @model.get('occupation')
		if occupation?
			interval = setInterval(() =>
				occupation_name = $.trim @$('.ui.dropdown.occ [data-id="' + occupation + '"]').text()
				$('.ui.dropdown.occ').dropdown('set selected', occupation_name)
				if $('.ui.dropdown.occ').dropdown('get value').length
					clearInterval(interval)
			200)

	check_continue: () ->

		if @model.check_continue()
			@$('.func__next').removeClass('disabled')
		else
			@$('.func__next').addClass('disabled')

	submit_phone: (e) ->

		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$('.messenger-shown').remove()

		phone = $.trim(@$('.func__phone_val:visible').val())

		if phone is ''
			app.notify 'error', 'Please provide a phone number.'
			$button.removeClass('disabled').removeClass('loading')
			return

		phone = phone.replace(/\s/g, '')
		phone = phone.replace(/-/g, '')
		phone = phone.replace(/\(|\)/g, '')

		dfd = $.post SITE_URL + '/private/user/phone/submit',
			phone_code: @$('.func__phone_code').val()
			phone: phone

		dfd.done (data) =>
			if data['error']
				message = data['data'] or 'Error sending verification code. Please try again.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
				$button.removeClass('disabled').removeClass('loading')
			else
				@$('.func__number').text(@$('.func__phone_code').attr('value') + phone)
				@$('.func__verify').val('')
				@$('.func__verify_box').hide().removeClass('hidden').fadeIn('fast', () =>
					@$('.func__verify').focus()
				)
				$button.removeClass('disabled').removeClass('loading')
				@temp_phone = phone
				@check_continue()
		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')

	verify_phone: (e) ->

		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$('.messenger-shown').remove()

		code = $.trim(@$('.func__verify').val())
		if code is ''
			app.notify 'error', 'Please enter your verification code.'
			$button.removeClass('disabled').removeClass('loading')
			return

		dfd = $.post SITE_URL + '/private/user/phone/verify',
			uid: @model.get 'uid'
			code: code
		dfd.done (data) =>
			@check_continue()
			if data['error']
				app.notify 'error', data['data']
				app.trigger 'error', new Error(data['data'])
				$button.removeClass('disabled').removeClass('loading')
			else
				@$('.func__submit_phone').removeClass('loading').html('<i class="fa fa-check"></i>').addClass('disabled')
				@$('.func__verify_box').fadeOut('fast')
				@model.set 'phone', @temp_phone
				@model.set('phone_verified', true)
				@model.trigger('change')
				$button.removeClass('disabled').removeClass('loading')

			@check_continue()

		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			app.trigger 'error', new Error('Call to /private/user/phone/verify failed')
			$button.removeClass('disabled').removeClass('loading')

	save_and_continue: (e) ->

		$button = @$('.func__next')

		if $button.hasClass('disabled')
			@check_not_added()
			return

		$button.addClass('disabled').addClass('loading')

		if @check_not_added()
			$button.removeClass('disabled').removeClass('loading')
			return

		new Fingerprint2().get (result, components) =>
			data =
				name: @model.get 'name'
				address: @model.get 'address'
				dob: @model.get 'dob'
				occupation: @model.get 'occupation'
				country: @model.get('country')
				state: @model.get('state')
				device: result

			dfd = $.post SITE_URL + '/private/user/update/onboarding',
				completed: 0
				data: data

			dfd.done (data) =>
				console.log data
				if data['error']
					@check_not_added()
					app.notify 'error', data['data']
					$button.removeClass('disabled').removeClass('loading')
				else
					app.models['user'].set 'onboarding_step', 1
					slideup = (@$el.height() + 50)*-1
					@$el.velocity 'top': slideup + 'px', 300, () =>
						app.module('Onboarding').trigger 'next:onboarding'

			dfd.fail (data) =>
				if data.status is 401
					app.trigger '401'
					return
				$button.removeClass('disabled').removeClass('loading')
				app.notify 'error', app.generic_error
				app.trigger 'error', new Error('AccountInfoView - Call to /private/user/update/onboarding failed')
				@render()

	check_not_added: () ->

		$('.messenger-shown').remove()

		$name = @$('.func__name_val')
		$address = @$('.func__personal_address')

		name = @model.get 'name'
		address = @model.get 'address'
		phone = @model.get 'phone'
		phone_verified = @model.get 'phone_verified'

		errors = false

		if name is ''
			errors = true
			app.notify 'error', 'Please add your full name.'
			$name.addClass('error')
		if name.split(' ').length < 2
			errors = true
			app.notify 'error', 'Please add your first name and last name.'
			$name.addClass('error')
		if phone is ''
			errors = true
			app.notify 'error', 'Please add your phone number.'
		else if not $.parseJSON(phone_verified)
			errors = true
			app.notify 'error', 'Please verify your phone number.'

		dob = $.trim(@$('.func__dob_val').val())

		if dob is ''
			errors = true
			app.notify 'error', 'Please add your date of birth.'

		if not @dob_regex.test(dob)
			errors = true
			app.notify 'error', 'Please format your birthday to mm/dd/yyyy.'

		message = 'Please add your personal address.'

		address_errors = false

		if address['addressline1'] is ''
			errors = true
			address_errors = true
			app.notify 'error', message
			$address.addClass('error')
			return

		if address['city'] is ''
			errors = true
			address_errors = true
			app.notify 'error', message
			$address.addClass('error')

		if address['state_province_region'] is ''
			errors = true
			address_errors = true
			app.notify 'error', message
			$address.addClass('error')

		regex = /^[A-Za-z]{2}/
		$state_province_region = $('.func__state_province_region')
		if address['state_province_region'].length isnt 2 or not regex.test(address['state_province_region'])
			errors = true
			address_errors = true
			app.notify 'error',  'Please format your state/provice/region to XX (i.e. ON).'
			$state_province_region.addClass('error')
			$address.addClass('error')

		if address['zip_postal'] is ''
			errors = true
			address_errors = true
			app.notify 'error',  message
			$address.addClass('error')

		if @model.get('country') is 'ca'
			if _.isEmpty(@model.get('occupation'))
				errors = true
				app.notify 'error',  'Please select an occupation.'
		
		if not address_errors
			$address.removeClass('error')

		return errors

	check_dob_keyup: () ->

		$dob = @$('.func__dob_val')
		dob = $.trim($dob.val())
		if not @dob_regex.test(dob)
			if dob.length > 10
				$('.messenger-shown').remove()
				app.notify 'error', @dob_error_message
		else
			$('.messenger-shown').remove()
			$dob.removeClass('error')

		dob = dob.split('/')
		month = dob[0]
		day = dob[1]
		year = dob[2]

		if month? and $.trim(month) isnt '' and day? and $.trim(day) isnt '' and year? and $.trim(year) isnt '' 
			dob = {day: day, month: month, year: year}
			@model.set 'dob', dob
		else
			@model.set 'dob', {}

	check_dob_focusout: () ->

		$dob = @$('.func__dob_val')
		dob = $.trim($dob.val())
		if not @dob_regex.test(dob)
			$('.messenger-shown').remove()
			app.notify 'error', @dob_error_message
			$dob.addClass('error')
		else
			$('.messenger-shown').remove()
			$dob.removeClass('error')

		@check_continue()

	check_name_keyup: () ->

		$name = $('.func__name_val')
		name = $.trim($name.val())

		if name isnt '' and not name.split(' ').length < 2
			$name.removeClass('error')
			$('.messenger-shown').remove()
			@model.set('name', name)


	check_name_focusout: () ->

		$name = $('.func__name_val')
		name = $.trim $name.val()

		if name is ''
			app.notify 'error', 'Please add your full name.'
			$name.addClass('error')
		else
			$name.removeClass('error')

		if name.split(' ').length < 2
			app.notify 'error', 'Please add your first name and last name.'
			$name.addClass('error')
		else
			$name.removeClass('error')

	add_occupation: (e) ->

		$item = @$(e.currentTarget)
		occupation = 
			id: $item.data('id')
			description: $item.data('description')
		@model.set 'occupation', occupation
		@check_continue()

	set_country: () ->

		self = @

		country = @model.get('country')
		if not country?
			return
		country = country.toUpperCase()

		setTimeout(() =>
			@model.set('countries_set', true)
			$('.search.country.dropdown').dropdown(
				onChange: $.proxy @country_dropdown_change, @
			)
			$('.search.country.dropdown').dropdown('set selected', country)
		500)

	set_state: () ->

		state = @model.get('state')

		setTimeout(() =>
			@$('.ui.dropdown.states').dropdown('set selected', state)

			@$('.ui.dropdown.states').dropdown('set selected', state)
			
		500)

	country_dropdown_change: (value, text, $selectedItem) ->

		if not value?
			return

		country = value.toLowerCase()
		app.models['user'].set('country', country)
		countries = @model.get('countries')
		config = @model.get('config')
		country_config = countries[country]
		if country_config?
			@model.set('phone_code', country_config['phone_code'])
		if not country_config? or not country_config['operating']
			@model.set('show_states', false)
			@model.set('show_operating', false)
			@model.set('show_not_operating', true)
			@model.set('tweet_text', text)
			return 
		if country is 'us'
			@model.set('show_states', true)
			@model.set('show_operating', false)
			@model.set('show_not_operating', false)
			return
		else
			@model.set('show_states', false)
			@model.set('show_not_operating', false)
		
		@model.set('show_operating', true)
		@model.set('show_not_operating', false)

	state_dropdown_change: (value, text, $selectedItem) ->

		if not value?
			return 

		config = @model.get('config')
		allowed_states = config['allowed_states']
		state = value.toLowerCase()

		if not (state in allowed_states)
			@model.set('tweet_text', text)
			@model.set('show_not_operating', true)
			@model.set('show_operating', false)
			return 
		@model.set('show_operating', true)
		@model.set('show_not_operating', false)

		app.models['user'].set('state', state)

		return

	address_input: () ->

		if $.trim(@$('.func__personal_address')) isnt ''
			return
		@model.set('address', {})

	set_address: () ->	

		address = @model.get 'address'

		if _.isEmpty(address)
			return

		text = ''

		text+= $.trim(address['addressline1'])
		if address['addressline1']? and $.trim(address['addressline1']) isnt ''
			text+= ', ' + $.trim(address['addressline2'])
		text+= ', ' + $.trim(address['city'])
		text+= ', ' + $.trim(address['state_province_region'])
		text+= ' '  + $.trim(address['zip_postal'])

		@model.set('address_text', text)

	add_occupation: (e) ->

		$item = @$(e.currentTarget)
		occupation = 
			id: $item.data('id')
			description: $item.data('description')

		dfd = $.post SITE_URL + '/private/user/update/occupation',
			occupation: occupation
			user_uid: app.models['user'].get('uid')
		dfd.done (data) =>
			if data['error']
				app.notify 'error', 'There was an error saving your occupation. Please try again.'
			else
				app.notify 'success', 'Successfully saved your occupation.'
				app.models['user'].set 'occupation', occupation
