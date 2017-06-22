
module.exports = 

	launch_verify_bank: (e) ->

		@$verify_button = $(e.currentTarget)

		if @$verify_button .hasClass 'disabled'
			return

		@$verify_button .addClass('disabled').addClass('loading')

		country = app.models['user'].get('country')
		bank_uid = @$verify_button .data 'bank-uid'

		$('.func__verify_bank.' + country).modal('setting',
			onShow: () =>

				$('html,body').css 'overflow', 'hidden'
				bank_accounts = app.models['user'].get 'bank_accounts'
				bank_account = _.findWhere(bank_accounts, uid: bank_uid)
				last_four = bank_account['last_four']
				@data['bank_modal']['to_verify'] = bank_account['uid']
				$('.func__verify_bank .func__last_four').text last_four

				$('.fa-close').click () ->
					$('.func__verify_bank').modal('hide')
			onHide: () =>
				$('html,body').css 'overflow', ''
				@$verify_button .text('Verify').removeClass('disabled')
				$('.fa-close').off()
		).modal('show')

	verify_bank: (e) ->

		$button = $('.func__confirm_verify_bank')

		if $button.hasClass('disabled')
			return

		$button.addClass('disabled').addClass('loading')

		country = app.models['user'].get('country')

		$val_1 = $('.func__verify_bank.' + country + ' .func__val_1')
		$val_2 = $('.func__verify_bank.' + country + ' .func__val_2')

		form_errors = false

		amount1 = $.trim $val_1.val()
		amount2 = $.trim $val_2.val()

		if $val_1.length
			if amount1 is ''
				$val_1.addClass('error')
				form_errors = true

		if $val_2.length
			if amount2 is ''
				$val_2.addClass('error')
				form_errors = true

		if form_errors
			$button.removeClass('disabled').removeClass('loading')
			return

		amounts = []
		if amount1?
			amounts.push amount1
		if amount2? 
			amounts.push amount2

		country = app.models['user'].get('country')
		dfd = $.post SITE_URL + '/private/method/verify',
			amounts: amounts
			user_uid: app.models['user'].get('uid')
			payment_method_uid: @data['bank_modal']['to_verify']

		dfd.done (data) =>
			if data['error']
				message = data['message'] || data['data']
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else
				message = 'Successfully verified bank account.'
				app.notify 'success', message
				$('.func__verify_bank').modal('hide')

				bank_accounts = app.models['user'].get 'bank_accounts'
				for bank in bank_accounts
					if bank['uid'] is @data['bank_modal']['to_verify']
						bank['verified'] = true 

				app.models['user'].set 'bank_accounts', bank_accounts
				app.models['user'].set('bank_account', true)
				app.models['user'].set_fiat_remaining()
				app.models['user'].trigger('change:bank_accounts')


		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			app.trigger 'error', new Error('Call to /private/bank/verify failed')

		dfd.always () =>
			$button.removeClass('disabled').removeClass('loading')
			@$verify_button.removeClass('disabled').removeClass('loading')
			