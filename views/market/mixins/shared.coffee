
module.exports =

	calculate_volume_boxes: () ->

		if $.urlParam('onboarding')?
			return

		if $('.func__confirm_order').modal('is active') or $('.func__sell_part2').modal('is active')
			return

		try 
			currency = @model.get('fiat')
			crypto = @model.get('crypto')
			action = @model.get('action')
			if action is 'buy'
				@type = 'ask'
			else if action is 'sell'
				@type = 'bid'

			quotes = @model.get('data')
			quote = quotes[crypto+currency][@type]
			@price = quote['price']
			@expires = quote['expires']

			$volume_form = @$('.func__volume')
			$receive_form = @$('.func__receive')

			if $volume_form.is(':focus')
				errors = false
				volume = $.trim($volume_form.val())
				if isNaN(volume) or (not @isNumeric(volume) and volume isnt '')
					errors = true
				if (volume + "").split(".")[1]?.length > 4
					errors = true

				if errors
					$volume_form.val(@last_volume)
					return

				receive_volume = volume * @price
				receive_volume = math.round receive_volume, app.FIAT_ROUNDING
				if receive_volume is 0
					receive_volume = ''
				$receive_form.val receive_volume

				@model.set('crypto_volume', volume)
				@model.set('fiat_volume', receive_volume)

				@last_volume = volume
				@last_receive_volume = receive_volume

			else if $receive_form.is(':focus')
				errors = false
				receive_volume = $.trim($receive_form.val())
				if isNaN(receive_volume) or (not @isNumeric(receive_volume) and receive_volume isnt '')
					errors = true
				if (receive_volume + "").split(".")[1]?.length > 2
					errors = true

				if errors
					$receive_form.val(@last_receive_volume)
					return

				volume = receive_volume / @price
				volume = math.round volume, app.CRYPTO_ROUNDING
				if volume is 0
					volume = ''
				$volume_form.val volume

				@model.set('crypto_volume', volume)
				@model.set('fiat_volume', receive_volume)

				@last_receive_volume = receive_volume
				@last_volume = volume

			@calculate_summary()

		catch e
			app.trigger 'error', e

	set_selected: (e) ->

		$ref = @$(e.currentTarget)
		@model.get('market')['payment_method'] = $ref.data 'uid'

	set_bank_fee: (e) ->

		$ref = @$(e.currentTarget)
		type = $ref.data 'type'

		payments = app.models['user'].get 'payments'
		action = @model.get('market')['action']
		fee = payments[type][action + '_fee']
		fee = (math.round fee, app.FIAT_ROUNDING).toFixed 2
		@model.get('market')['bank_fee'] = fee

	calculate_summary: () ->

		if $('.func__confirm_order').modal('is active') or $('.func__sell_part2').modal('is active')
			return

		$volume_form = @$('.func__volume')
		$fiat_form = @$('.func__receive')
		volume = $volume_form.val()
		price = @price
		payments = @model.get('payments_config')['payments']
		action = Backbone.history.getFragment()
		crypto = 'btc'
		fiat = @model.get('fiat')

		subtotal = math.round volume * price, app.FIAT_ROUNDING
		harborly_percent =  payments['harborly_percent']

		harborly_fee = math.round subtotal * harborly_percent, app.FIAT_ROUNDING

		if action is 'buy'
			total = subtotal + harborly_fee
		else if action is 'sell'
			total = subtotal - harborly_fee

		bankfee_hard = payments['items']['original'][action + '_flat']
		bankfee_percent = payments['items']['original'][action + '_percent']

		bankfee = math.round bankfee_percent * total, app.FIAT_ROUNDING
		bankfee = math.round bankfee + bankfee_hard, app.FIAT_ROUNDING

		if action is 'buy'
			total = math.round total + bankfee, app.FIAT_ROUNDING
		else if action is 'sell'
			total = math.round total - bankfee, app.FIAT_ROUNDING

		if total <= bankfee_hard
			subtotal = 0
			bankfee = 0
			harborly_fee = 0
			total = 0
			@total_too_small = true
		else
			@total_too_small = false

		if not subtotal? or not bankfee? or not harborly_fee? or not total?
			return

		$('.func__subtotal').text subtotal.toFixed(2)
		$('.func__bank_fee').text bankfee.toFixed(2)
		$('.func__harborly_fee').text harborly_fee.toFixed(2)
		$('.func__total').text total.toFixed(2)

		@init_order = 

			'uid': app.models['user'].get 'uid'
			'country': app.models['user'].get 'country'
			'processor': 'eft:original'
			'quote_uid': '1234567890'

			'price': parseFloat price 
			'subtotal': parseFloat subtotal
			'harborly_fee': parseFloat harborly_fee
			'bankfee': parseFloat bankfee
			'total': parseFloat total

			'action': action
			'crypto': crypto
			'fiat': fiat
			'volume': parseFloat volume
			
			'expires': @expires
			'address': app.models['user'].get('wallets')[crypto]?['address']
			'crypto_readable': 'Bitcoin'
			'timestamp': moment().valueOf()
			date: moment().format("dddd, MMMM Do")
			est_delivery: moment(moment().valueOf() + moment.duration(6, "days").asMilliseconds()).format("dddd, MMMM Do")

	isNumeric: (n) ->
		return !isNaN(parseFloat(n)) && isFinite(n)

	init_transact: (e) ->

		$('.messenger-shown').remove()

		if not @init_order?
			return

		$button = $(e.currentTarget)

		if $button.hasClass 'loading'
			app.notify 'error', 'Please choose your transaction volume.'
			return

		$button.addClass('loading')

		errors = false
		errors = @check()

		user_bank_uid = $('.func__bank .item.active').data 'uid'
		if not user_bank_uid?
			app.notify 'error', 'Please select a method.'
			errors = true

		@init_order['user_bank_uid'] = user_bank_uid
		last_four = $('.func__bank .item.active').data('last_four')
		@init_order['last_four'] = last_four

		if errors 
			$button.removeClass('disabled').removeClass('loading')
			return

		app.models['user'].set 'init_order', @init_order 

		modal_str = '.func__confirm_order '

		$(modal_str).modal('setting', 
			onShow: () =>

				init_order = app.models['user'].get('init_order')

				self = @
				@set_confirm_modal(init_order)

				$(modal_str + '.func__' + init_order['action']).removeClass('hidden')
				$(modal_str).modal('refresh')
				$('.func__confirm_transaction').click () ->
					self.transact(@)
				$('.func__cancel_transaction').click () =>
					setTimeout(() =>
						@calculate_volume_boxes()
					600)
					
					if not $(modal_str + '.func__cancel_transaction').hasClass('disabled')
						$(modal_str).modal('hide')
				$('.func__close').click () ->
					setTimeout(() =>
						@calculate_volume_boxes()
					600)
					if not $(modal_str + '.func__cancel_transaction').hasClass('disabled')
						$(modal_str).modal('hide')

			onHide: () ->
				$button.removeClass('disabled').removeClass('loading')

			onHidden: () =>
				$('.func__confirm_transaction').off()
				$('.func__cancel_transaction').off()
				$('.func__close').off()
				$('.func__sell').addClass('hidden')
				$('.func__buy').addClass('hidden')

		).modal('show')

	set_confirm_modal: (order) ->
		market = @model.get('market')
		try
			$('.func__fiat_symbol').text market['fiat_symbol'].toUpperCase()
			$('.func__total').text order['total'].toFixed(2)
			$('.func__account').text('*********' + order['last_four'])
			$('.func__volume').text order['volume']
			$('.func__crypto').text order['crypto'].toUpperCase()
			$('.func__address').text order['address']
			$('.func__address').text order['address']
			$('.func__date').text order['date']
			$('.func__est_delivery').text order['est_delivery']
			$('.func__fiat').text order['fiat'].toUpperCase()
		catch e 
			app.trigger 'error', e

	set_sellpart2_modal: (order) ->

		market = @model.get('market')
		try
			$('.func__fiat_symbol').text market['fiat_symbol'].toUpperCase()
			$('.func__total').text order['init_order']['total'].toFixed(2)
			$('.func__account').text('*********' + order['init_order']['last_four'])
			$('.func__volume').text order['init_order']['volume']
			$('.func__crypto').text order['init_order']['crypto'].toUpperCase()
			$('.func__address').text order['send_address']
			$('.func__date').text order['date']
			$('.func__est_delivery').text order['est_delivery']
			$('.func__fiat').text order['init_order']['fiat'].toUpperCase()
		catch e 
			app.trigger 'error', e

	transact: (ref) ->

		$button = $(ref)
		$cancel = $('.func__cancel_transaction')

		if $button.hasClass 'disabled'
			return

		$button.addClass('disabled').addClass('loading')
		$cancel.addClass('disabled')

		user_bank_uid = $('.func__bank .item.active').data 'uid'

		if not user_bank_uid?
			$button.removeClass('disabled').removeClass('loading')
			$cancel.removeClass('disabled')
			return

		@init_order['payment_uid'] = user_bank_uid

		if err?
			app.trigger 'error', err
			return console.log err

		@get_quote (err, quote) =>
			if err?
				app.trigger 'error', err 
				return app.notify 'error', app.generic_error

			params = 
				user_uid: @init_order['uid']
				volume: @init_order['volume']
				address: @init_order['address']
				payment_uid: user_bank_uid
				quote: quote
				timestamp: moment().valueOf()

			dfd = $.post SITE_URL + '/user/' + @init_order['action'] +  '/noredirect',
				params
			dfd.done (data) =>

				$button.removeClass('disabled').removeClass('loading')
				$cancel.removeClass('disabled')

				if data['error']
					if data['data'] is 'no such quote'
						message = 'Your quote has expired.'
						$('.func__confirm_order').modal('hide')
					else
						message = data['data']

					app.notify 'error', message
				else
					if @init_order['crypto'] is 'btc'
						crypto_str = 'Bitcoin'
					else if @init_order['crypto'] is 'ltc'
						crypto_str = 'Litecoin'
					if @init_order['action'] is 'buy'
						$('.func__confirm_order').modal('hide')
						@handle_post_transact(@init_order)
					else if @init_order['action'] is 'sell'
						console.log data['data']
						@sell_part2(data['data'])
					
			dfd.fail (data) =>

				if data.status is 401
					app.trigger '401'
					return

				app.trigger 'error', new Error 'Call to /user/' + @init_order['action'] +  '/noredirect failed'

				$button.removeClass('disabled').removeClass('loading')
				$cancel.removeClass('disabled')
				app.notify 'error', app.generic_error

	sell_part2: (data) ->

		address = data['deposit_address']
		expires = data['relative_expiration']

		@startSellFlagPoll(address)

		@post_order =
			init_order: @init_order
			send_address: address

		app.models['user'].set 'post_order', @post_order
		@set_sellpart2_modal(@post_order)

		$('.func__sell_part2').modal('setting', {'closable': false}).modal('setting', 

			onShow: () =>

				self = @

				@countdown(expires)

				qr.canvas
					canvas: document.getElementById('qr-code'),
					value: address
					size: 8

				$('.func__close').click () ->
					if not $('.func__sell_part2 .func__cancel_transaction').hasClass('disabled')
						$('.func__sell_part2').modal('hide')

				$('.func__cancel').click () =>
					if not $('.func__sell_part2 .func__cancel_transaction').hasClass('disabled')
						$('.func__sell_part2').modal('hide')
						clearInterval(@flagPoll)
						$('.func__sell_part2 .func__expired').addClass('hidden')
			onHide: () =>
				$('.func__close').off()
				$('.func__cancel_transaction').off()
				$('.func__countdown').stop().addClass('hidden')
				$('.func__sell_part2 .func__expired').addClass('hidden')
				 
			# onHidden: () =>
			# 	$('.func__close').off()
			# 	$('.func__cancel_transaction').off()
			# 	$('.func__countdown').stop().addClass('hidden')
			# 	$('.func__sell_part2 .func__expired').addClass('hidden')
			# 	@calculate_volume_boxes()
			# 	clearInterval(@flagPoll)
				
		).modal('show')

	startSellFlagPoll: (address) ->
		pending = false
		clearInterval(@flagPoll)
		@flagPoll = setInterval(() =>
			if pending
				return
			pending = true
			dfd = $.post '/sell_flag',
				deposit_address: address
			dfd.done (data) =>
				if not data['error']
					if not JSON.parse(data['data'])
						clearInterval(@flagPoll)
						@handle_post_transact(@init_order)
						$('.func__sell_part2').modal('hide')
				pending = false
			dfd.fail (data) =>
				pending = false
		2000)

	check: () ->

		$('.messenger-shown').remove()

		errors = false

		if not @init_order['address']?
			app.notify 'error', 'Please link a BTC address to your account.'
			errors = true
		if @total_too_small
			app.notify 'error', 'Amount of BTC is too small.'
			errors = true
		if @init_order['volume'] < app.MIN_VOL[@init_order['crypto']]
			app.notify 'error', 'The minimum volume for Bitcoin is ' + app.MIN_VOL[@init_order['crypto']] + ' BTC.'
			errors = true
		if not app.models['user'].get('user_verified')
			app.notify 'error', 'Please verify your account before transacting.'
			errors = true

		return errors

	countdown: (date) ->

		# date = moment().valueOf() + 10000

		countdownDone = (event) =>
			$('.func__sell_part2').addClass('expired')
			$('.func__sell_part2 .func__expired').removeClass('hidden')
			@$countdown = undefined

		countdownProcess = (event) =>
			$('.func__min').text(event.strftime('%M'))
			$('.func__sec').text(event.strftime('%S'))
			if event.strftime('%M') is '00' and event.strftime('%S') is '01'
				setTimeout(() =>
					$('.func__sec').text(event.strftime('00'))
					countdownDone()
				1000)

		$('.func__countdown').removeClass('hidden')
		@$countdown = $('.func__countdown').countdown(date)
			.on('update.countdown', countdownProcess)

	handle_post_transact: (init_order) =>

		app.router.navigate '/activity', trigger: true

		$('html,body').animate scrollTop: "0px"

		message = 'You '
		title = ''
		if init_order['action'] is 'buy'
			message += 'bought '
			title += '+'
		else if init_order['action'] is 'sell'
			message += 'sold '
			title += '-'
		message += init_order['volume']
		message += ' ' + 'Bitcoin'
		title += init_order['volume']
		title += ' ' + 'BTC'

		data = 
			message: message
			state: 'pending'
			title: title
			created: init_order['timestamp']
			temp: true
			created_hr: moment(init_order['timestamp']).format("MMM Do YY, h:mm:ss a")

		ActivityModel = require '../../../models/activity'
		activity = new ActivityModel(data)

		app.collections['activities'].add(activity, at: 0)

	get_quote: (cb) ->

		type = @init_order['action']
		params =
			crypto: 'btc'
			fiat: @init_order['fiat']
			volume: @init_order['volume']
			timestamp: moment().valueOf()

		dfd = $.post '/private/quote/' + type,
			params
		dfd.done (data) =>
			if data['error']
				return app.notify 'error', app.generic_error

			quote = data['data']
			return cb null, quote

		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			return cb new Error app.generic_error
