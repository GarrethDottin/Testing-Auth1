
module.exports =

	onRender: () ->
		@data['bank_modal'] = {}

		# TODO: figure out why this needs to be in setTimeout
		setTimeout(() =>
			@events()
		0)

	events: () ->
		$('.func__save_bank').off('click', @create_bank_account)
		$('.func__save_bank').on('click', $.proxy @create_bank_account, @)

		$('.func__launch_bank_modal.ha-add-bank').off('click', @launch_bank_modal)
		$('.func__launch_bank_modal.ha-add-bank').on('click', $.proxy @launch_bank_modal, @)

		$('.func__delete_bank').off('click', @delete_bank)
		$('.func__delete_bank').on('click', $.proxy @delete_bank, @)

		$('.func__confirm_verify_bank').off('click', @verify_bank)
		$('.func__confirm_verify_bank').on('click', $.proxy @verify_bank, @)

		$('.func__launch_verify_bank').off('click', @launch_verify_bank)
		$('.func__launch_verify_bank').on('click', $.proxy @launch_verify_bank, @)

		$('.func__complete_bank').off('click', @complete_bank)
		$('.func__complete_bank').on('click', $.proxy @complete_bank, @)

		$('.ui.modal.step2 .ui.modal .checkbox').off('click', @set_button)
		$('.ui.modal.step2 .ui.modal .checkbox').on('click', $.proxy @set_button, @)

		$('.func__select_bank').off('click', @select_bank)
		$('.func__select_bank').on('click', $.proxy @select_bank, @)

		$('.func__login_bank').off('click', @login_bank)
		$('.func__login_bank').on('click', $.proxy @login_bank, @)

		$('.func__submit_bank_mfa').off('click', @bank_question_answers)
		$('.func__submit_bank_mfa').on('click', $.proxy @bank_question_answers, @)

	start_mixins: () ->

		launch_modal = require './launch_modal'
		create_bank = require './create_bank'
		delete_bank = require './delete_bank'
		verify_bank = require './verify_bank'
		synapse_login = require './synapse_login'

		Cocktail.mixin(@, launch_modal, create_bank, delete_bank, verify_bank, synapse_login)

