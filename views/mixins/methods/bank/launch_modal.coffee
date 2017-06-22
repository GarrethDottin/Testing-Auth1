
module.exports =

	launch_bank_modal: (e) ->

		country = app.models['user'].get('country')

		$('.ui.modal.bank.step1[data-country="' + country + '"]').modal('setting',
			onShow: () ->
				$('.ui.modal.bank.step1[data-country="' + country + '"] .checkbox').checkbox()

				$('.fa-close').click () ->
					$('.ui.modal.bank.step1[data-country="' + country + '"]').modal('hide')

				country = app.models['user'].get('country')
				ref_str = '.ui.modal.bank.step1[data-country="' + country + '"] '
				$(ref_str + '.func__save_bank').removeClass('loading').removeClass('disabled')

			onHide: () ->
				$('.fa-close').off()
				$('.part1.func__save_bank').html 'Next &nbsp;<i class="fa fa-chevron-right"></i>'
				$('.part1.func__save_bank').removeClass 'disabled'

			onVisible: () ->
				interval = setInterval(() ->
					$input = $('.ui.modal.bank.step1[data-country="' + country + '"] .func__transit_number')
					if $input.is(':focus')
						$('.dimmer').scrollTop(0)
						$input.blur()
					else
						clearInterval(interval)
				10)

				if country is 'us'
					$('.func__select_bank').popup()
				

		).modal('close all').modal('show')

	launch_bank_modal_part2: () ->

		country = app.models['user'].get('country')
		$('.ui.modal.step2.bank[data-country="' + country + '"]').modal('setting',
			onShow: () ->

				$('.ui.modal.bank.step2[data-country="' + country + '"] .checkbox').checkbox()

				$('.fa-close').click () ->
					$('.ui.modal.bank.step2[data-country="' + country + '"]').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.part2.func__save_bank').html 'Next &nbsp;<i class="fa fa-chevron-right"></i>'
				$('.part2.func__save_bank').removeClass 'disabled'

		).modal('show')

	launch_bank_modal_part3: () ->

		country = app.models['user'].get('country')
		$('.ui.modal.bank.step3[data-country="' + country + '"]').modal('setting',
			onShow: () ->

				$('.ui.modal.bank.step3[data-country="' + country + '"] .checkbox').checkbox()

				$('.fa-close').click () ->
					$('.ui.modal.bank.step3[data-country="' + country + '"]').modal('hide')

			onHide: () ->
				$('.fa-close').off()
				$('.part2.func__save_bank').html 'Next &nbsp;<i class="fa fa-chevron-right"></i>'
				$('.part2.func__save_bank').removeClass 'disabled'

		).modal('show')
