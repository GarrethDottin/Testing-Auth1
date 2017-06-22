template = require '../templates/settings/settings'

module.exports = class SettingsView extends Backbone.Marionette.ItemView
	id: 'settings-view'
	className: 'ha-section'
	template: template

	events:
		'click .ha-sub-nav a': 'navigate'
		'click .func__change_email': 'change_email'   
		'click .func__change_password': 'change_password'
		'click .func__add_phone': 'add_phone'
		'click .func__change_name': 'add_name'
		'click .func__launch_doc_upload': 'launch_doc_upload'
		'click .func__launch_selfie_upload': 'launch_selfie_upload'
			
	modelEvents:
		'change:setting': 'fieldsChanged'
		'change:email': 'fieldsChanged'
		'change:email_verified': 'fieldsChanged'
		'change:email_login': 'fieldsChanged'
		'change:show_states': 'fieldsChanged'
		'change:phone': 'fieldsChanged'
		'change:phone_code': 'fieldsChanged'
		'change:phone_verified': 'fieldsChanged'
		'change:name': 'fieldsChanged'
		'change:has_social_network': 'fieldsChanged'
		'change:id_selfie_scanned': 'fieldsChanged'
		'change:id_selfie_verified': 'fieldsChanged'
		'change:id_scanned': 'fieldsChanged'
		'change:id_scan_verified': 'fieldsChanged'

		
	fieldsChanged: () ->

		country = @model.get('country') or @$('.search.country.dropdown').dropdown('get value')
		states = @model.get('state') or @$('.search.states.dropdown').dropdown('get value')
		currency = @model.get('fiat') or @$('.ui.dropdown.currencies').dropdown('get value')
		country = country.toUpperCase()

		@render()

		@$('.ui.dropdown.currencies').dropdown('set selected', currency)
		@$('.search.states.dropdown').dropdown('set selected', states)
		@$('.search.country.dropdown').dropdown('set selected', country)

		@set_dropdowns()

	initialize: (options) ->
		save_wallet = require('./mixins/save_wallet')
		resend_link = require('./mixins/resend_link')
		base = require('./mixins/base')
		Cocktail.mixin(@, save_wallet, resend_link, base)
		@init_setting_page()

	onShow: () ->
		@set_dropdowns()
		@set_default_currency()
		@set_country()
		@set_state()

	onDestroy: () ->
		$('.ui.dropdown.currencies .item').off()
		$('.ui.dropdown.country .item').off()
		$('.ui.dropdown.states .item').off()
		
	onRender: () ->

	set_dropdowns: () ->
		self = @

		@$('.ui.dropdown.currencies').dropdown()
		@$('.search.country.dropdown').dropdown()
		@$('.search.states.dropdown').dropdown()

		@$('.ui.dropdown.currencies .item').click () ->
			value = $(@).data('value')
			self.currency_dropdown_change value

		@$('.ui.dropdown.country .item').click () ->
			value = $(@).data('value')
			self.country_dropdown_change value

		@$('.ui.dropdown.states .item').click () ->
			value = $(@).data('value')
			self.states_dropdown_change value

		
	navigate: (e) ->
		setting = @$(e.currentTarget).data 'setting'
		@model.set 'setting', setting
		app.router.navigate 'settings?setting=' + setting, trigger: true

	init_setting_page: () ->

		setting = @model.get 'setting'
		if not setting?
			@model.set 'setting', 'account'
	
	change_email: (e) ->

		$('.func__change_email_modal').modal('setting',
			onShow: () =>

				$('.func__confirm_change_email').click(@confirm_email_change)

				$('.fa-close').click () ->
					$('.func__change_email_modal').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.func__confirm_change_email').removeClass('disabled').text('Save')
				$('.func__confirm_change_email').off(@confirm_email_change)

		).modal('show')

	confirm_email_change: (e) ->

		$button = $(@)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$new_email_form = $('.func__new_email')
		$confirm_new_email_form = $('.func__confirm_new_email')

		new_email = $.trim($new_email_form.val())
		confirm_new_email = $.trim($confirm_new_email_form.val())

		errors = false 

		if new_email is ''
			errors = true
			$new_email_form.addClass('error')
			app.notify('error','Enter your new email address.')

		if confirm_new_email is ''
			errors = true
			$confirm_new_email_form.addClass('error')
			app.notify('error', 'Confirm your new email address.')

		if new_email isnt confirm_new_email
			errors = true
			$new_email_form.addClass('error')
			$confirm_new_email_form.addClass('error')
			app.notify('error',  'Your emails don\'t match.')

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return

		dfd = $.post SITE_URL + '/user/update/email',
			uid: app.models['user'].get('uid')
			new_email: new_email
		dfd.done (data) =>
			if data['error']
				app.notify('error', data['data'])
				$button.removeClass('disabled').removeClass('loading')
			else
				$('.func__change_email_modal').modal('hide')
				app.models['user'].set('email', new_email)
				app.models['user'].set('email_verified', false)
				app.notify('success', 'Successfully updated your email address.')

		dfd.fail (data) =>
			app.notify('error', 'Error changing email address. Please try again.')
			$button.removeClass('disabled').removeClass('loading')

	change_password: (e) ->

		$('.func__change_password_modal').modal('setting',
			onShow: () =>
				$('.func__confirm_change_password').click(@confirm_change_password)
				$('.fa-close').click () ->
					$('.func__change_password_modal').modal('hide')
			onHide: () ->
				$('.fa-close').off()
				$('.func__confirm_change_password').removeClass('disabled').text('Save')
				$('.func__confirm_change_password').off(@confirm_change_password)

		).modal('show')

	confirm_change_password: (e) ->

		$button = $(@)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$new_password_form = $('.func__new_password')
		$confirm_new_password_form = $('.func__confirm_new_password')

		new_password = $.trim($new_password_form.val())
		confirm_new_password = $.trim($confirm_new_password_form.val())

		errors = false 

		if new_password is ''
			errors = true
			$new_password_form.addClass('error')
			app.notify('error', 'Enter your new password.')

		if confirm_new_password is ''
			errors = true
			$confirm_new_password_form.addClass('error')
			app.notify('error', 'Confirm your new password.')

		if new_password isnt confirm_new_password
			errors = true
			$new_password_form.addClass('error')
			$confirm_new_password_form.addClass('error')
			app.notify('error', 'Your passwords don\'t match.')

		if new_password.length < 6
			errors = true
			$new_password_form.addClass('error')
			$confirm_new_password_form.addClass('error')
			app.notify('error', 'Password must be greater than 6 characters.')

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return

		dfd = $.post SITE_URL + '/user/auth/update/password',
			uid: app.models['user'].get('uid')
			new_password: new_password
		dfd.done (data) =>
			if data['error']
				app.notify('error', data['data'])
				$button.removeClass('disabled').removeClass('loading')
			else
				$('.func__change_password_modal').modal('hide')
				app.models['user'].set('email_verified', true)
				app.models['user'].set('email_login', true)
				app.notify('success', 'Successfully updated your password.')
				$button.removeClass('disabled').removeClass('loading')

		dfd.fail (data) =>
			app.notify('error', 'Error updating password. Please try again.')
			$button.removeClass('disabled').removeClass('loading')

	set_default_currency: () ->

		fiat = @model.get('fiat')
		fiat = fiat.toUpperCase()
		@$('.ui.dropdown.currencies').dropdown('set selected', fiat)

	set_country: () ->

		country = @model.get('country')
		
		if country?
			country = country.toUpperCase()
			@$('.ui.dropdown.country').dropdown('set selected', country)

		if @model.get('country') is 'us'
			@model.set('show_states', true)

	set_state: () ->

		state = @model.get('state')
		if state?
			@$('.ui.dropdown.states').dropdown('set selected', state)

			interval = setInterval(() =>
				@$('.ui.dropdown.states').dropdown('set selected', state)
				value = @$('.search.states.dropdown').dropdown('get value')
				if value is state 
					clearInterval(interval)
			200)

	currency_dropdown_change: (value) ->
		if not value?
			return
		fiat = value.toLowerCase()

		app.models['user'].set('fiat', fiat)

	country_dropdown_change: (value) ->
		if not value?
			return
		country = value.toLowerCase()
		app.models['user'].set('country', country)

		countries = @model.get('countries')
		config = @model.get('config')
		country_config = countries[country]

		if country is 'us'
			@model.set('show_states', true)
		else
			@model.set('show_states', false)

	states_dropdown_change: (value) ->
		if not value?
			return
		state = value.toLowerCase()
		app.models['user'].set('state', state)

	add_phone: () ->
		$('.func__add_phone_modal').modal('setting',
			onShow: () =>
				$('.func__add_phone_modal .func__confirm_add_phone').click $.proxy @set_phone, @
				phone_code = @model.get('phone_code')
				if phone_code?
					$('.func__new_phone_code').val(@model.get('phone_code'))
			onVisible: () =>
				$('.fa-close').click () =>
					$('.func__add_phone_modal').modal('hide')
				$('.func__new_phone').focus()
			onHide: () =>
				$('.func__add_phone_modal .func__confirm_add_phone').off()
				$('.func__new_phone').val('')
				$('.func__confirm_add_phone').removeClass('disabled').removeClass('loading')
				$('.fa-close').off()
		).modal('show')

	set_phone: () ->

		$button = $('.func__confirm_add_phone')
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$func__new_phone_code = $('.func__new_phone_code')
		$func__new_phone = $('.func__new_phone')

		phone_code = $.trim($func__new_phone_code.val())
		phone = $.trim($func__new_phone.val())

		errors = false 

		if not phone_code? or not phone_code.length
			errors = true
			$func__new_phone_code.addClass('error')
			app.notify 'error', 'Please enter your phone code number.'

		if not phone? or not phone.length
			errors = true
			$func__new_phone.addClass('error')
			app.notify 'error', 'Please enter your phone number.'

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return 

		phone = phone.replace(/\s/g, '')
		phone = phone.replace(/-/g, '')
		phone = phone.replace(/\(|\)/g, '')

		dfd = $.post SITE_URL + '/private/user/phone/submit',
			phone_code: phone_code
			phone: phone

		dfd.done (data) =>

			if data['error']
				message = data['data'] or 'Error sending verification code. Please try again.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
				$button.removeClass('disabled').removeClass('loading')
			else
				@verify_phone_modal(phone_code, phone)

		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')

	verify_phone_modal: (phone_code, phone) ->

		@temp_phone_code = phone_code
		@temp_phone = phone

		$('.func__verify_phone_modal').modal('setting',
			onShow: () =>
				$('.func__verify_phone_modal .func__verify_phone').click $.proxy @verify_phone, @
			onVisible: () =>
				$('.func__number').text(phone_code + phone)
				$('.fa-close').click () =>
					$('.func__verify_phone_modal').modal('hide')
			onHide: () =>
				$('.func__verify_phone_modal .func__verify_phone').off()
				$('.func__verify').val('')
				$('.func__verify_phone').removeClass('disabled').removeClass('loading')
				$('.fa-close').off()
		).modal('show')

	verify_phone: () ->

		$button = $('.func__verify_phone')
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$code = $('.func__verify')
		code = $.trim($('.func__verify').val())

		errors = false 

		if not code? or not code.length
			errors = true
			$code.addClass('error')
			app.notify 'error', 'Please enter your verification code.'

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return 

		dfd = $.post SITE_URL + '/private/user/phone/verify',
			uid: @model.get('uid')
			code: code
		dfd.done (data) =>
			if data['error']
				app.notify 'error', data['data']
				app.trigger 'error', new Error(data['data'])
				$button.removeClass('disabled').removeClass('loading')
			else
				@model.set('phone', @temp_phone)
				@model.set('phone_code', @temp_phone_code)
				$('.func__verify_phone_modal').modal('hide')
				app.notify 'success', 'Successfully updated your phone number.'
		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')

	add_name: () ->
		
		$('.func__add_name_modal').modal('setting',
			onShow: () =>
				$('.func__add_name_modal .func__confirm_add_name').click $.proxy @set_name, @
			onVisible: () =>
				$('.fa-close').click () =>
					$('.func__add_name_modal').modal('hide')
			onHide: () =>
				$('.func__add_name_modal .func__confirm_add_name').off()
				$('.func__new_name').val('')
				$('.func__confirm_add_name').removeClass('disabled').removeClass('loading')
				$('.fa-close').off()
		).modal('show')

	set_name: () ->

		$button = $('.func__confirm_add_name')
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')

		$name = $('.func__new_name')
		name = $.trim($('.func__new_name').val())

		errors = false 

		if not name? or not name.length
			errors = true
			$name.addClass('error')
			app.notify 'error', 'Please enter your name.'

		if name.split(' ').length < 2
			app.notify 'error', 'Please add your first name and last name.'
			$name.addClass('error')
			errors = true

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return 

		dfd = $.post SITE_URL + '/private/user/update/name',
			uid: @model.get('uid')
			name: name
		dfd.done (data) =>
			if data['error']
				app.notify 'error', data['data']
				app.trigger 'error', new Error(data['data'])
				$button.removeClass('disabled').removeClass('loading')
			else
				app.models['user'].set('name', name)
				$('.func__add_name_modal').modal('hide')
				app.notify 'success', 'Successfully updated your name.'
		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')

	launch_doc_upload: (e) ->

		self = @

		$('.func__doc_upload_modal').modal('setting',
			onShow: () =>

				if not window.doc_dz?
					window.doc_dz = new Dropzone('#doc-dropzone',
						url: '/id/submit'
						maxFilesize: 5
						addRemoveLinks: true
						autoProcessQueue: false
						maxFiles: 1
						acceptedFiles: '.jpg,.jpeg,.png'
						dictDefaultMessage: 'Drop a file or click here to upload your ID. Allowed file types are JPG/JPEG and PNG.'
						accept: (file, done) =>
							done()
						init: () ->
							@on 'error', (file, message, cb) =>
								app.notify 'error', message
								window.doc_dz.removeAllFiles()
								$('.func__submit_doc').removeClass('disabled').text('Upload')
							@on 'success', (resp) =>
								app.notify 'success', 'Successfully uploaded your ID.'
								$('.func__submit_doc').removeClass('disabled').text('Uploaded')
								app.models['user'].set('id_scanned', true)
								self.render()
								$('.func__doc_upload_modal').modal('hide')
					)

				$('.func__submit_doc').click () =>
					$button = $('.func__submit_doc')
					if $button.hasClass('disabled')
						return

					$button.addClass('disabled').text('Uploading...')

					if not window.doc_dz.files.length
						app.notify 'error', 'Please upload a scan or picture of your ID.'
						$('.func__submit_doc').removeClass('disabled').text('Upload')
					else
						window.doc_dz.processQueue()

				$('.fa-close').click () =>
					$('.func__doc_upload_modal').modal('hide')
					$('html,body').css 'overflow', ''
			onVisible: () =>
				$('.func__doc_upload_modal').modal('center')
			onHide: () =>
				$('.func__submit_doc').off()
				
		).modal('show')

	launch_selfie_upload: (e) ->

		self = @

		$('.func__selfie_upload_modal').modal('setting',
			onShow: () =>

				if not window.selfie_dz?
					window.selfie_dz = new Dropzone('#selfie-dropzone',
						url: '/selfie/submit'
						maxFilesize: 5
						addRemoveLinks: true
						autoProcessQueue: false
						maxFiles: 1
						acceptedFiles: '.jpg,.jpeg,.png'
						dictDefaultMessage: 'Drop a file or click here to upload a picture of you holding your ID. Allowed file types are JPG/JPEG and PNG.'
						accept: (file, done) =>
							done()
						init: () ->
							@on 'error', (file, message, cb) =>
								app.notify 'error', message
								window.selfie_dz.removeAllFiles()
								$('.func__submit_selfie').removeClass('disabled').text('Upload')
							@on 'success', (resp) =>
								app.notify 'success', 'Successfully uploaded your selfie.'
								$('.func__submit_selfie').removeClass('disabled').text('Uploaded')
								app.models['user'].set('id_selfie_scanned', true)
								self.render()
								$('.func__selfie_upload_modal').modal('hide')
					)

				$('.func__submit_selfie').click () =>
					$button = $('.func__submit_selfie')
					if $button.hasClass('disabled')
						return

					$button.addClass('disabled').text('Uploading...')

					if not window.selfie_dz.files.length
						app.notify 'error', 'Please upload a picture of yourself holding your ID.'
						$('.func__submit_selfie').removeClass('disabled').text('Upload')
					else
						window.selfie_dz.processQueue()

				$('.fa-close').click () =>
					$('.func__doc_upload_modal').modal('hide')
					$('html,body').css 'overflow', ''
			onVisible: () =>
				$('.func__doc_upload_modal').modal('center')
			onHide: () =>
				$('.func__submit_doc').off()
				
		).modal('show')
