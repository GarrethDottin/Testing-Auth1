
module.exports = 

	delete_bank: (e) ->

		@$delete_button = $(e.currentTarget)

		if @$delete_button.hasClass 'disabled'
			return

		@$delete_button.addClass('disabled').addClass('loading')

		bank_uid = @$delete_button.data 'bank-uid'
		country = app.models['user'].get('country')

		@data['bank_modal'].to_delete = 
			user_uid: app.models['user'].get 'uid'
			payment_method_uid: bank_uid

		$('.func__confirm_delete_bank').modal('setting',
			onShow: () =>
				$('.func__confirm_delete_bank .func__confirm').click () =>
					@confirm_delete_bank()
					$('.func__confirm_delete_bank').modal('hide')
				$('.func__confirm_delete_bank .func__cancel').click () =>
					$('.func__confirm_delete_bank').modal('hide')
					@$delete_button.removeClass('disabled').removeClass('loading')

				$('.fa-close').click () ->
					$('.func__confirm_delete_bank').modal('hide')
			onHide: () =>
				$('.func__confirm_delete_bank .func__confirm').off()
				$('.func__confirm_delete_bank').off()
				$('.fa-close').off()
		).modal('show')

	confirm_delete_bank: () ->

		dfd = $.post SITE_URL + '/private/method/delete',
			@data['bank_modal'].to_delete

		dfd.done (data) =>
			if data['error']
				message = 'Failed to delete bank account. Please try again.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else  
				banks = app.models['user'].get 'bank_accounts'
				banks = _.without(banks, _.findWhere(banks, uid: @data['bank_modal'].to_delete['payment_method_uid']))
				if not banks.length
					banks = []
				app.models['user'].set 'bank_accounts', banks

		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			app.trigger 'error', new Error('Call to /private/bank/delete failed')

		dfd.always () =>
			@$delete_button.removeClass('disabled').removeClass('loading')
