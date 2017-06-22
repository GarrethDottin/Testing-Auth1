
###
	Onboarding shared mixin
	Handles slideIn animation, stepping back and canceling onboarding
###

module.exports = 

	onRender: () ->
		@events()

	onShow: () ->
		@slideIn()

	events: () ->
		@$('.func__step_back').off('click', @stepBack)
		@$('.func__step_back').on('click', $.proxy @stepBack, @)
		@$('.func__exit_onboarding').off('click', @cancelOnboarding)
		@$('.func__exit_onboarding').on('click', $.proxy @cancelOnboarding, @)

	slideIn: () ->
		slideup = 600
		height = @$el.height()
		if @model.get('step_number') is 2
			slideup = 1200
		@$el.css('position', 'absolute').css('top', (slideup*-1) + 'px')
		setTimeout(() =>
			@$el.velocity('top': '0px', 200)
		300)
		$('#onboarding').transition({
			opacity: 1,
			scale: 1,
			duration: 300,
			easing: 'in',
		})

	stepBack: (e) ->
		$button = $(e.currentTarget)

		if $button.hasClass('disabled')
			return

		$button.addClass('disabled').addClass('loading')

		dfd = $.post '/private/user/stepback/onboarding'

		dfd.done (data) =>
			if data['error']
				app.notify 'error', app.generic_error
				$button.removeClass('disabled').removeClass('loading')
				return 

			app.models['user'].set 'onboarding_step', data['data']['onboarding_step']
			slideup = (@$el.height() + 50)*-1
			@$el.velocity 'top': slideup + 'px', 300, () =>
				app.module('Onboarding').trigger 'next:onboarding'
			
		dfd.fail (data) =>
			$button.removeClass('disabled').removeClass('loading')
			app.notify 'error', app.generic_error
			app.trigger 'error', new Error('Call to /private/user/onboarding/skip failed')

	cancelOnboarding: () ->
		app.module('Onboarding').trigger 'cancel:onboarding'
		