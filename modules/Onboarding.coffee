
app.module 'Onboarding', () ->

	@startWithParent = true

	@onStart = (options) =>

		@on 'start:onboarding', () =>
			@start_onboarding()
			@previous_current_page = app.models['user'].get('current_page')
			app.models['user'].set('current_page', 'onboarding')
		@on 'next:onboarding', () =>
			@start_onboarding()
		@on 'completed:onboarding', () =>
			app.models['user'].get_user (err, user) =>
				if err?
					return location.reload()
	
				app.models['user'].set 
					payments_config: user['payments_config']
					countries: user['countries']
					synapse_banks: user['synapse_banks']
				
				@onStop()
				app.models['user'].set('current_page', @previous_current_page)
				app.router.navigate Backbone.history.getFragment().split('?')[0], trigger: true
				setTimeout(() =>
					location.reload()
				200)

		@on 'cancel:onboarding', () =>
			@onStop()
			app.router.navigate '/activity', trigger: true
			app.models['user'].set('current_page', @previous_current_page)

	@onStop = () =>
		
		$('html,body').css 'overflow', ''

		$el = $('.ha-onboarding')
		slideup = ($el.height() + 50)*-1
		$el.velocity 'top': slideup + 'px', 300, () =>
			$el = $('#onboarding')
			$el.transition(opacity: 0)
			setTimeout(() =>
				$el.remove()
				app.layout.regionManager.removeRegion 'onboarding'
			200)
			
		app.models['user'].set('current_page', @previous_current_page)

	@start_onboarding = () =>

		onboarding_step = app.models['user'].get 'onboarding_step'
		onboarding_skipped = app.models['user'].get 'onboarding_skipped'

		if onboarding_step > 0
			app.trigger 'user:init'

		if onboarding_step > 1 or onboarding_skipped > 1
			app.router.navigate Backbone.history.getFragment().split('?')[0], trigger: true
			@stop()
			return

		if onboarding_step isnt 0
			if onboarding_skipped > onboarding_step
				onboarding_step = onboarding_skipped

		if not onboarding_step?
			onboarding_step = 0

		try
			$('#onboarding').remove()
			app.layout.regionManager.removeRegion 'onboarding'

		id = 'onboarding'
		$('body').append '
			<div id="'+ id + '" class="hidden"></div>
		'
		app.layout.regionManager.addRegion(id, "#" + id)
		$('html,body').css 'overflow', 'hidden'

		map = 
			'0': 'account'
			'1': 'identity'

		View = require '../views/onboarding/' + map[onboarding_step]
		Model = require '../models/onboarding' + onboarding_step
		app.models['onboarding' + onboarding_step] = new Model()
		view = new View model: app.models['onboarding' + onboarding_step]

		app.layout.onboarding.show view

