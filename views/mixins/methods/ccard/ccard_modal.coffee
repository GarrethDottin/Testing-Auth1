
module.exports = 

	events:
		'click .func__save_ccard': 'create_ccard_account'
		'click .func__launch_ccard_modal': 'launch_ccard_modal'
		'click .func__delete_ccard': 'delete_ccard'
		'click .func__confirm_verify_ccard': 'verify_ccard'
		'click .func__launch_verify_ccard': 'launch_verify_ccard'
		'click .func__complete_ccard': 'complete_ccard'
		'click .ui.modal.step2 .ui.modal .checkbox': 'set_button'

	onRender: () ->
		@data['ccard_modal'] = {}

	launch_ccard_modal: (e) ->

		country = app.models['user'].get('country')
		# country = 'us'

		if not @card?
			@card = new Card(
			    form: '.form.func__ccard_form'
			    container: '.func__ccard_wrapper'
			    formSelectors:
			        numberInput: '.func__card_number'
			        expiryInput: '.func__expiration_date' 
			        cvcInput: '.func__security_code'
			        nameInput: '.func__card_name'
			)

		$('.ui.modal.ccard.step1[data-country="' + country + '"]').modal('setting',
			onShow: () ->
				# $('.ui.modal.ccard.step1[data-country="' + country + '"] .checkbox').checkbox()
				# $('.fa-close').click () ->
				# 	$('.ui.modal.ccard.step1[data-country="' + country + '"]').modal('hide')

			onVisible: () ->

			onHide: () ->
				$('.fa-close').off()
				$('.part1.func__save_ccard').html 'Next &nbsp;<i class="fa fa-chevron-right"></i>'
				$('.part1.func__save_ccard').removeClass 'disabled'
			onHidden: () ->

		).modal('close all').modal('show')

	launch_ccard_modal_part2: () ->

		$('.ui.modal.step2.ccard').modal('setting',
			onShow: () ->

				$('.ui.modal.ccard.step2 .checkbox').checkbox()

				$('.fa-close').click () ->
					$('.ui.modal.ccard.step2').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.part2.func__save_ccard').html 'Next &nbsp;<i class="fa fa-chevron-right"></i>'
				$('.part2.func__save_ccard').removeClass 'disabled'

			onHidden: () ->
				
					# $('.ui.dimmer').removeClass('active').addClass('hidden')
					# $('body').removeClass('dimmable')
					# $('body').removeClass('dimmed')
				

		).modal('show')

	create_ccard_account: () ->

		$('.messenger-shown').remove()

		# country = app.models['user'].get('country')
		# # country = 'us'
		# ref_str = '.ui.modal.ccard.step1[data-country="' + country + '"] '

		# $card_number = $(ref_str + '.func__card_number')
		# $expiration_date = $(ref_str + '.func__expiration_date')
		# $card_name = $(ref_str + '.func__card_name')
		# $security_code = $(ref_str + '.func__security_code')
		# $full_name = $(ref_str + '.func__card_name')
		# $button = $(ref_str + '.func__save_bank')

		# if $button.hasClass 'disabled'
		# 	return

		# $button.addClass 'disabled'
		# $button.html 'Saving...'

		# @data['ccard_modal']['ccardAccountData'] =
		# 	'cardNumber': $card_number.val().replace(/\s+/g, '')
		# 	'cardExpiryDate': $expiration_date.val().replace(/\s+/g, '')
		# 	'cardCVV2': $security_code.val()
		# 	'full_name': $full_name.val()
		# 	'ccard_country': country
		# 	'currency': $(ref_str + '.currency:checked').data('currency')

		# form_errors = false

		# # Card number

		# card_number = @data['ccard_modal']['ccardAccountData'].cardNumber

		# if card_number is ''
		# 	form_errors = true
		# 	$card_number.addClass('error')

		# # Transit Number

		# expiration_date = @data['ccard_modal']['ccardAccountData'].cardExpiryDate

		# console.log 'expiration'
		# console.log expiration_date

		# if expiration_date is ''
		# 	$expiration_date.addClass('error')
		# 	form_errors = true

		# if not /^(0[1-9]|1[0-2])\/\d{2}$/.test(expiration_date)
		# 	$expiration_date.addClass('error')
		# 	form_errors = true
		# 	app.notify 'error', 'Please format the card expiration date to mm/yy.'

		# @data['ccard_modal']['ccardAccountData'].cardExpiryDate = expiration_date.replace('/', '')


		# # Account number

		# security_code = @data['ccard_modal']['ccardAccountData'].cardCVV2

		# console.log 'security code'
		# console.log security_code.length

		# if security_code is ''
		# 	$security_code.addClass('error')
		# 	form_errors = true

		# if security_code.length < 3 or security_code.length > 3
		# 	$security_code.addClass('error')
		# 	form_errors = true
		# 	app.notify 'error', 'Security code must be 3 digits.'

		# full_name = @data['ccard_modal']['ccardAccountData'].full_name

		# if full_name is ''
		# 	$full_name.addClass('error')
		# 	form_errors = true

		# if form_errors
		# 	$button.removeClass 'disabled'
		# 	$button.html 'Continue &nbsp;<i class="fa fa-fa-check"></i>'
		# 	return

		form = document.getElementById('payment-form')
		Vogogo.getCardId form, (data) =>
			console.log data
		

		@launch_ccard_modal_part2()

	delete_ccard: (e) ->

		$button = $(e.currentTarget)

		if $button.hasClass 'disabled'
			return

		$button.text 'Deleting...'
		$button.addClass('disabled')

		ccard_uid = $button.data 'ccard-uid'
		country = app.models['user'].get('country')

		@data['ccard_modal'].to_delete = 
			user_uid: app.models['user'].get 'uid'
			payment_method_uid: ccard_uid

		$('.func__confirm_delete_ccard').modal('setting',
			onShow: () =>
				$('.func__confirm_delete_ccard .func__confirm').click () =>
					@confirm_delete_ccard()
					$('.func__confirm_delete_ccard').modal('hide')
				$('.func__confirm_delete_ccard .func__cancel').click () =>
					$('.func__confirm_delete_ccard').modal('hide')

				$('.fa-close').click () ->
					$('.func__confirm_delete_ccard').modal('hide')
			onHide: () =>
				$button.text('Delete').removeClass('disabled')
				$('.func__confirm_delete_ccard .func__confirm').off()
				$('.func__confirm_delete_ccard').off()
				$('.fa-close').off()
		).modal('show')

	confirm_delete_ccard: () ->

		dfd = $.post SITE_URL + '/private/method/delete',
			@data['ccard_modal'].to_delete

		dfd.done (data) =>
			if data['error']
				message = 'Failed to delete credit card account. Please try again.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else  
				ccards = app.models['user'].get 'credit_cards'
				console.log ccards
				ccards = _.without(ccards, _.findWhere(ccards, uid: @data['ccard_modal'].to_delete['payment_method_uid']))
				if not ccards.length
					ccards = null
				app.models['user'].set 'credit_cards', ccards
				console.log app.models['user'].get 'credit_cards'

		dfd.fail (data) =>
			if data['error']
				message = app.generic_error
				app.notify 'error', message
			app.trigger 'error', new Error('Call to /private/method/delete failed')

	launch_verify_ccard: (e) ->

		$button = $(e.currentTarget)

		if $button.hasClass 'disabled'
			return

		$button.text 'Verifying...'
		$button.addClass('disabled')

		ccard_uid = $button.data 'ccard-uid'

		$('.func__verify_ccard').modal('setting',
			onShow: () =>

				$('html,body').css 'overflow', 'hidden'
				ccard_accounts = app.models['user'].get 'credit_cards'
				ccard_account = _.findWhere(ccard_accounts, uid: ccard_uid)
				last_four = ccard_account['last_four']
				@data['ccard_modal']['to_verify'] = ccard_account['uid']
				$('.func__verify_ccard .func__last_four').text last_four

				$('.fa-close').click () ->
					$('.func__verify_ccard').modal('hide')
			onHide: () =>
				$('html,body').css 'overflow', ''
				$button.text('Verify').removeClass('disabled')
				$('.fa-close').off()
		).modal('show')

	verify_ccard: (e) ->

		$button = $('.func__confirm_verify_ccard')

		if $button.hasClass('disabled')
			return

		$button.addClass('disabled')
		$button.text('Verifying...')

		$val_1 = $('.ccard .func__val_1')
		$val_2 = $('.ccard .func__val_2')

		form_errors = false

		amount1 = $val_1.val()
		amount2 = $val_2.val()

		console.log amount1

		# if amount2 is ''
		# 	$val_2.addClass('error')
		# 	form_errors = true

		if amount1 is ''
			$val_1.addClass('error')
			form_errors = true

		if form_errors
			$button.removeClass('disabled')
			$button.text('Verify')
			return

		country = app.models['user'].get('country')
		dfd = $.post SITE_URL + '/private/method/verify',
			amounts: [amount1]
			user_uid: app.models['user'].get('uid')
			payment_method_uid: @data['ccard_modal']['to_verify']

		dfd.done (data) =>
			if data['error']
				$button.removeClass('disabled')
				$button.text('Verify')
				message = data['message'] || data['data']
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else
				message = 'Successfully verified credit card account.'
				app.notify 'success', message
				$('.func__verify_ccard').modal('hide')
				$button.removeClass('disabled')
				$button.text('Verify')

				credit_cards = app.models['user'].get 'credit_cards'
				for ccard in credit_cards
					if ccard['uid'] is @data['ccard_modal']['to_verify']
						ccard['verified'] = true 

				app.models['user'].set 'credit_cards', credit_cards
				app.models['user'].set('credit_card', true)
				app.models['user'].check_need_to_verify()
				app.models['user'].determine_account_tier()
				app.models['user'].set_fiat_remaining()
				app.models['user'].trigger('change:credit_cards')


		dfd.fail (data) =>
			$button.removeClass('disabled')
			$button.text('Verify')
			app.notify 'error', app.generic_error
			app.trigger 'error', new Error('Call to /private/method/verify failed')

	post_new_ccard: (cb) ->

		country = app.models['user'].get('country')

		dfd = $.post SITE_URL + '/private/method/add',
			user_uid: app.models['user'].get 'uid'
			payment_data: @data['ccard_modal']['ccardAccountData']
			pp_name: 'oculus'

		dfd.done (data) =>
			console.log data
			if data['error']
				message = data['message'] || data['data']
				app.notify 'error', message

				if $(ref_str2).modal('is active')
					$('.func__complete_ccard').removeClass('disabled').html('Complete &nbsp;<i class="fa fa-check"></i>')

				app.trigger 'error', new Error(message)

			else
				app.models['user'].set 'credit_cards', data['data']['ccard']

				ref_str1 = '.ui.modal.ccard.step2[data-country="' + country + '"]'
				ref_str2 = '.ui.modal.ccard.step3[data-country="' + country + '"]'
				$(ref_str1).modal('hide')

				app.models['user'].check_need_to_verify()

		dfd.fail (data) =>
			if data.status is 401
				app.trigger '401'
				return
			app.notify 'error', app.generic_error
			$('.func__complete_ccard').removeClass('disabled').html('Complete &nbsp;<i class="fa fa-check"></i>')
			app.trigger 'error', new Error 'Call to /private/method/add failed'

	complete_ccard: (e) ->

		$button = $(e.currentTarget)

		checked = $('.ccard.step2 input:checked').attr('class')

		if checked is 'deposit'
			if $button.hasClass('disabled')
				return

			$button.addClass('disabled')
			$button.text('Saving...')

			@post_new_ccard (err) =>
				if err?
					$button.removeClass 'disabled'
					$button.html 'Continue &nbsp;<i class="fa fa-check"></i>'
		else if checked is 'instant'
			@launch_ccard_modal_part3()

	set_button: (e) ->

		country = app.models['user'].get('country')

		checked = $('.ui.modal.ccard.step2[data-country="' + country + '"] input:checked').data('type')
		if checked is 'deposit'
			$('.func__complete_ccard').html('<i class="fa fa-check"></i>&nbsp; Complete')
		else
			$('.func__complete_ccard').html('Next &nbsp;<i class="fa fa-chevron-right"></i>')

