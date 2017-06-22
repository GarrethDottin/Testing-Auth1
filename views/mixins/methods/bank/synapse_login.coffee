
module.exports = 

	select_bank: (e) ->

		bank_name = $(e.currentTarget).data('bank-name')
		if bank_name? and bank_name isnt ''
			app.models['user'].set('selected_bank', bank_name)

		synapse_banks = app.models['user'].get('synapse_banks')
		bank = {}
		for synapse_bank in synapse_banks['banks']
			if bank_name is synapse_bank['bank_name']
				bank = synapse_bank
				break			

		app.models['user'].set('selected_bank_logo', bank['logo'])

		$('.ui.modal.func__bank_login').modal('setting',
			onShow: () ->

				$('.func__bank_logo').attr('src', bank['logo'])
				$('.fa-close').click () ->
					$('.func__bank_login').modal('hide')
				if bank['bank_name'] is 'USAA'
					$('.func__pin_option').removeClass('hidden')
			onVisible: () ->
		
				$('.ui.modal.func__bank_login').modal('refresh')

			onHide: () ->
				$('.func__login_bank').removeClass('disabled').text('Link Account')

				$('.fa-close').off()
			onHidden: () ->
				$('.func__pin_option').addClass('hidden')

		).modal('show')

	login_bank: (e) ->

		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return 
		$button.addClass('disabled').addClass('loading')

		$username = $('.func__bank_username')
		$password = $('.func__bank_password')
		$pin = $('.func__account_pin')

		username = $.trim $username.val()
		password = $.trim $password.val()
		
		if not $('.func__pin_option').hasClass('hidden')
			pin = $.trim $pin.val()
		else
			pin = '1234'

		errors = false

		$('.messenger-shown').remove()

		if username is ''
			errors = true
			$username.addClass('error')
			app.notify 'error', 'Please enter your username.'

		if password is ''
			errors = true
			$password.addClass('error')
			app.notify 'error', 'Please enter your password.'

		if errors
			$button.removeClass('disabled').removeClass('loading')
			return 

		dfd = $.post '/private/method/login',
			user_uid: app.models['user'].get('uid')
			bank_name: app.models['user'].get('selected_bank')
			username: username
			bank_password: password
			pin: pin
		dfd.done (resp) =>
			console.log resp
			if resp['error']
				app.notify 'error', resp['data'] or app.generic_error
				return
			if resp['data']['http_code'] is '202'
				@handle_mfa(resp)
			else
				@handle_new_bank()

		dfd.fail (data) =>
			app.notify 'error', app.generic_error

		dfd.always () =>
			$button.removeClass('disabled').removeClass('loading')

	handle_mfa: (resp) ->

		$('.func__question_field').siblings('.field').remove()
		$('.func__code_field').siblings('.field').remove()

		@handle_mfa_question(resp['data']['nodes'])

	handle_mfa_question: (nodes) ->

		$('.func__submit_bank_mfa').removeClass('disabled').removeClass('loading')		

		for question in nodes
			q = question['extra']['mfa']['message']
			id = question['_id']['$oid']

			$('.func__question_field').after '
				<div class="field func__question" data-id="' + id + '">
					<label>' + q + '</label>
					<div class="ui left input">
						<input class="func__answer" type="text" placeholder="Enter your MFA answer">
					</div>
				</div>
			'

		$('.func__modal_mfa_answers').modal('setting',
			onShow: () ->
				$('.fa-close').click () ->
					$('.func__modal_mfa_answers').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.func__submit_bank_mfa').removeClass('disabled').text('Submit')

			onVisible: () ->

		).modal('show')

	handle_mfa_device: (data) ->

		mfa = data['mfa']

		$('.func__code_field').after '
				<div class="field">
					<label>' + mfa['message'] + '</label>
					<div class="ui left input">
						<input class="func__answer" type="text" placeholder="Enter your MFA code">
					</div>
				</div>
			'

		$('.func__modal_mfa_code').modal('setting',
			onShow: () ->
				$('.fa-close').click () ->
					$('.func__modal_mfa_code').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.func__submit_bank_mfa').removeClass('disabled').removeClass('loading')

			onVisible: () ->

		).modal('show')

	bank_question_answers: (e) ->

		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return 
		$button.addClass('disabled').addClass('loading')

		$answer = $('.func__answer')
		answer = $.trim $answer.val()

		errors = false

		$('.messenger-shown').remove()

		if answer is ''
			errors = true
			$answer.addClass('error')
			app.notify 'error', 'Please enter your multi factor authentication answer.'
		
		if errors
			$button.removeClass('disabled').removeClass('loading')
			return 

		dfd = $.post '/private/method/answer',
			user_uid: app.models['user'].get('uid')
			answer: answer
			id: $('.func__question').data('id')
		dfd.done (data) =>
			if data['error']
				app.notify 'error', 'Incorrect answer. Please try again.'
				return 
			data = data['data']
			if data['is_mfa']
				@handle_mfa data
			else
				@handle_new_bank()
			
		dfd.fail (data) =>
			app.notify 'error', app.generic_error

		dfd.always () =>
			$button.removeClass('disabled').removeClass('loading')
