
module.exports = 

	create_bank_account: () ->

		$('.messenger-shown').remove()

		country = app.models['user'].get('country')
		ref_str = '.ui.modal.bank.step1[data-country="' + country + '"] '

		$full_name = $(ref_str + '.func__full_name')
		$transit_number = $(ref_str + '.func__transit_number')
		$account_number = $(ref_str + '.func__account_number')
		$bank_number = $(ref_str + '.func__bank_number')
		$button = $(ref_str + '.func__save_bank')

		if $button.hasClass 'disabled'
			return

		$button.addClass 'disabled'
		$button.addClass 'loading'

		@data['bank_modal']['bankAccountData'] =
			'account_name': $full_name.val()
			'transit_number': $transit_number.val()
			'account_number': $account_number.val()
			'bank_number': $bank_number.val()
			'bank_country': country

		if $(ref_str + ' .checkboxes .checking').is(':checked')
			@data['bank_modal']['bankAccountData'].type = 'checking'
		else if $(ref_str + ' .checkboxes .savings').is(':checked')
			@data['bank_modal']['bankAccountData'].type = 'savings'

		form_errors = false

		# Account Name

		if @data['bank_modal']['bankAccountData'].account_name is ''
			form_errors = true
			$full_name.addClass('error')

		# Transit Number

		transit_number = @data['bank_modal']['bankAccountData'].transit_number

		if transit_number is ''
			$transit_number.addClass('error')
			form_errors = true

		if country is 'ca'
			number_type = 'Transit'
			number_length = 5
		else if country is 'us'
			number_type = 'Routing'
			number_length = 9

		if not /^\d+$/.test(transit_number)
			$transit_number.addClass('error')
			form_errors = true
			app.notify 'error', number_type + ' number must contain no special characters or decimals.'
			
		if transit_number.length isnt number_length
			$transit_number.addClass('error')
			app.notify 'error', number_type + ' number must be ' + number_length + ' digits long.'
			form_errors = true

		# Account number

		account_number = @data['bank_modal']['bankAccountData'].account_number

		if account_number is ''
			$account_number.addClass('error')
			form_errors = true

		if not /^\d+$/.test(account_number)
			$account_number.addClass('error')
			form_errors = true
			app.notify 'error', 'Account number must contain no special characters or decimals.'

		country = app.models['user'].get('country')

		if country is 'ca'
			min = 7
			max = 15
		else if country is 'us'
			min = 6
			max = 15

		if account_number.length < min or account_number.length > max
			$account_number.addClass('error')
			form_errors = true
			app.notify 'error', 'Account number must be between ' + min + '-' + max + ' digits.'

		# Bank number

		if country is 'ca'
			bank_number = @data['bank_modal']['bankAccountData'].bank_number

			if bank_number.length isnt 3
				app.notify 'error', 'Bank number must be 3 digits long.'
				$bank_number.addClass('error')
				form_errors = true

			if not /^\d+$/.test(bank_number)
				$bank_number.addClass('error')
				form_errors = true
				app.notify 'error', 'Bank number must contain no special characters or decimals.'

		if not @data['bank_modal']['bankAccountData'].type?
			form_errors = true
			app.notify 'error', 'Must select an account type.'

		if form_errors
			$button.removeClass 'disabled'
			$button.removeClass 'loading'
			return

		@launch_bank_modal_part2()

	post_new_bank: (cb) ->

		country = app.models['user'].get('country')

		if country is 'ca'
			pp_name = 'vogogo'
		else if country is 'us'
			pp_name = 'synapse'

		user_uid = app.models['user'].get 'uid'

		dfd = $.post SITE_URL + '/private/method/add',
			user_uid: user_uid
			payment_data: @data['bank_modal']['bankAccountData']
			pp_name: pp_name

		dfd.done (data) =>
			if data['error']
				message = data['message'] || data['data']
				app.notify 'error', message

				if $(ref_str2).modal('is active')
					$('.func__complete_bank').removeClass('disabled').removeClass('loading')

				app.trigger 'error', new Error(message)
				@launch_bank_modal()

			else
				app.models['user'].set 'bank_accounts', data['data']['bank']

				ref_str1 = '.ui.modal.bank.step2[data-country="' + country + '"]'
				ref_str2 = '.ui.modal.bank.step3[data-country="' + country + '"]'
				$(ref_str1).modal('hide')

		dfd.fail (data) =>
			if data.status is 401
				app.trigger '401'
				return
			app.notify 'error', app.generic_error
			$('.func__complete_bank').removeClass('disabled').removeClass('loading')
			app.trigger 'error', new Error 'Call to /private/bank/add failed'

	complete_bank: (e) ->

		$button = $(e.currentTarget)

		checked = $('.step2 input:checked').attr('class')

		if checked is 'deposit'
			if $button.hasClass('disabled')
				return

			$button.addClass('disabled').addClass('loading')

			@post_new_bank (err) =>
				if err?
					$button.removeClass 'disabled'
					$button.removeClass 'loading'
		else if checked is 'instant'
			@launch_bank_modal_part3()

	handle_new_bank: () ->

		app.models['user'].get_user (err, user) =>
			if err?
				location.reload()
			else
				app.models['user'].set 'bank_accounts', user['methods']['bank']
				if app.models['user'].get('country') is 'us'
					app.models['user'].set_synpase_banks()
				app.models['user'].trigger 'change:bank_accounts'
				setTimeout(() =>
					$('.func__modal_mfa_code').modal('hide')
					$('.func__modal_mfa_answers').modal('hide')
					$('.ui.modal.func__bank_login').modal('hide')
				300)

	set_button: (e) ->

		country = app.models['user'].get('country')

		checked = $('.ui.modal.bank.step2[data-country="' + country + '"] input:checked').data('type')
		if checked is 'deposit'
			$('.func__complete_bank').html('<i class="fa fa-check"></i>&nbsp; Complete').removeClass('loading')
		else
			$('.func__complete_bank').html('Next &nbsp;<i class="fa fa-chevron-right"></i>').removeClass('loading')

