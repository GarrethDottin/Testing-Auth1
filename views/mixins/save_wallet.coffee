
module.exports =

	onRender: () ->
		@events()
		
	events: () ->
		@$('.func__save_wallet').off('click', @save_wallet)
		@$('.func__save_wallet').on('click', $.proxy @save_wallet, @)

		@$('.func__edit_wallet').off('click', @edit_wallet)
		@$('.func__edit_wallet').on('click', $.proxy @edit_wallet, @)

		@$el.off('click', @unedit_wallet)
		@$el.on('click', $.proxy @unedit_wallet, @)

		@$('input').off('click', @stopProp)
		@$('input').on('click', $.proxy @stopProp, @)

	stopProp: (e) ->
		e.stopPropagation()

	save_wallet: (e) ->

		$('.messenger-shown').remove()

		e.stopPropagation()

		$button = @$(e.currentTarget)

		if $button.hasClass 'disabled'
			return

		$form = $button.siblings('input')
		$button.addClass('disabled').text('Saving...')
		$form.prop('disabled', 'disabled')

		type = $button.data 'type'
		address = $form.val()
		try
			current_address = @model.get('wallets')[type]['address']
		catch
			current_address = ''

		errors = false

		if current_address is address
			message = 'You cannot submit a duplicate address.'
			app.notify 'error', message
			errors = true
			app.trigger 'error', new Error(message)

		if address is ''
			app.notify 'error', 'Please enter a BTC address.'
			errors = true

		if errors
			$button.removeClass('disabled').text('Save')
			$form.prop('disabled', '')
			return

		dfd = $.post SITE_URL + '/private/address/verify',
			address: address
			type: type

		dfd.done (data) =>
			if data['error']
				message = data['message'] || data['data']
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else
				$form.siblings('i').removeClass('fa-qrcode').addClass('fa-check-circle-o confirm')
				$button.removeClass('disabled').text('Edit').removeClass('disabled')
				.removeClass('func__save_wallet').addClass('func__edit_wallet')

				data = data['data']
				app.models['user'].set 'wallets', data['wallets']
				@model.set 'wallets', data['wallets']
				# app.models['user'].check_need_to_verify()
			@render()

		dfd.fail (data) =>
			if data.status is 401
				app.trigger '401'
				return
			$button.removeClass('disabled').text('Save')
			$form.prop('disabled', '')
			app.trigger 'error', new Error('Call to /private/address/verify failed')

	edit_wallet: (e) ->
		e.stopPropagation()
		$button = @$(e.currentTarget)
		$form = $button.siblings('input')
		$button.removeClass('disabled').text('Save').addClass('func__save_wallet').removeClass('func__edit_wallet')
		$form.prop('disabled', '').siblings('i').removeClass('fa-check-circle-o').addClass('fa-qrcode').removeClass('confirm')

		@events()

	unedit_wallet: (e) -> 
		if @$('.func__ha_wallets:visible').length
			@render()
		
		


