template = require '../../templates/market/market'

shared = require './mixins/shared'

module.exports = class MarketView extends Backbone.Marionette.ItemView
	id: 'market-view'
	className: 'ha-section col-xs-12'
	template: template

	modelEvents: 
		'change:quotes': () ->
			@calculate_volume_boxes()
		'change:account_tier': 'fields_changed'
		'change:accounts': 'fields_changed'
		'change:countries': 'fields_changed'
		'change:country': 'fields_changed'
		'change:fiat': 'fields_changed'
		'change:fiat_symbol': 'fields_changed'
		'change:percent_remaining': 'fields_changed'
		'change:account_tier': 'fields_changed'
		'change:has_payment_method': 'fields_changed'

	events: 
		'click .func__nav_buy': (e) ->
			app.router.navigate 'buy', trigger: true

		'click .func__nav_sell': (e) ->
			app.router.navigate 'sell', trigger: true

		'keyup :input': () ->
			if not $.urlParam('onboarding')?
				@calculate_volume_boxes()

		'click .func__init_transact': (e) ->
			@init_transact(e)

		'click .func__new_method': () ->
			$('html,body').scrollTop(0)
			app.router.navigate '/payments', trigger: true

		'click .func__confirm_transaction': (e) ->
			@transact(e)
			
		'click .func__verify': () ->
			$('html,body').scrollTop(0)
			app.router.navigate '/payments', trigger: true
		'click .func__verification': () ->
			app.router.navigate '/settings?setting=verification', trigger: true

	initialize: () ->

		base = require('../mixins/base')
		Cocktail.mixin(@, shared, base)

	onShow: () ->
		@$('.ui.dropdown').dropdown()
		app.models.user.set_fiat_remaining()
		app.models.user.has_payment_method()

	fields_changed: () ->

		if $('.func__confirm_order').modal('is active') or $('.func__sell_part2').modal('is active')
			return

		$volume_form = @$('.func__volume')
		$receive_form = @$('.func__receive')
		volume = $volume_form.val()
		receive = $receive_form.val()

		if $volume_form.is(':focus')
			to_focus = '.func__volume'
		else if $receive_form.is(':focus')
			to_focus = '.func__receive'

		payments_text = @$('.selection.dropdown .text').text()
		uid = @$('.menu .item').data('uid')

		@render()

		@$('.func__volume').val volume
		@$('.func__receive').val receive
		@$('.ui.dropdown').dropdown()

		if payments_text? and uid?
			@$('.selection.dropdown .default.text').text(payments_text)
			@$('.menu .item[data-uid="' + uid + '"]').addClass('active')

		@calculate_volume_boxes()

		setTimeout(() =>
			@$(to_focus).focus()
		200)
