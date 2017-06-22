template = require '../templates/payments/payments'

module.exports = class PaymentsView extends Backbone.Marionette.ItemView
	id: 'payments-view'
	template: template
	className: 'ha-section'

	modelEvents:
		'change:bank_accounts': () ->
			@render()
		'change:credit_cards': () ->
			@render()

	events: 
		'click .ccard.more-info-link': 'show_ccard_info'
		'click .ccard.less-info-link': 'hide_ccard_info'
		'click .bank.more-info-link': 'show_bank_info'
		'click .bank.less-info-link': 'hide_bank_info'

	initialize: () ->
		@data = {}
		base = require('./mixins/base')
		bank = require './mixins/methods/bank/main'
		Cocktail.mixin(@, base, bank)
		@start_mixins()

	onRender: () ->
		setTimeout(() =>
			app.trigger 'set_sidebar_selected'
		300)

	show_ccard_info: () ->

		@$('.ccard.more-info-link').addClass('hidden')
		@$('.ccard.less-info-link').removeClass('hidden')
		@$('.ccard.info').removeClass('hidden')

	hide_ccard_info: () ->

		@$('.ccard.more-info-link').removeClass('hidden')
		@$('.ccard.less-info-link').addClass('hidden')
		@$('.ccard.info').addClass('hidden')

	show_bank_info: () ->

		@$('.bank.more-info-link').addClass('hidden')
		@$('.bank.less-info-link').removeClass('hidden')
		@$('.bank.info').removeClass('hidden')

	hide_bank_info: () ->

		@$('.bank.more-info-link').removeClass('hidden')
		@$('.bank.less-info-link').addClass('hidden')
		@$('.bank.info').addClass('hidden')
