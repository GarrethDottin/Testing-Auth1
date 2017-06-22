
module.exports = class Router extends Backbone.Router

	routes:
		'': () ->
			@navigate 'activity', trigger: true
		'activity': 'activity'
		'buy': 'buy'
		'sell': 'sell'
		'payments': 'payments'
		'settings': 'settings'

		'*path' : () ->
			@navigate 'activity', trigger: true

	initialize: () ->

		@bind 'route', @_trackPageview

	before: (route, params) ->
		@clear()

	after: (route, params) ->

		app.trigger 'set_sidebar_selected'
		
	_trackPageview: ->
		if ga?
			url = Backbone.history.getFragment()
			ga('send', 'pageview', "/#{url}")

	activity: (params) =>

		if not params? or params['page'] < 1
			return @navigate '/activity?page=1', trigger: true

		app.models['user'].set('current_page', 'activity')
		app.module('Activity').start(params)
		
	buy: (params) ->

		if params?['onboarding']
			app.module('Onboarding').trigger 'start:onboarding'
		@check_onboarding(params)

		app.models['user'].set('current_page', 'buy_btc')
		app.models['user'].set('current_action', 'market')

		app.module('Market').stop()
		app.module('Market').start(action: 'buy')

	sell: (params) ->

		if params?['onboarding']
			app.module('Onboarding').trigger 'start:onboarding'
		@check_onboarding(params)

		app.models['user'].set('current_page', 'sell_btc')
		app.models['user'].set('current_action', 'market')

		app.module('Market').stop()
		app.module('Market').start(action: 'sell')

	payments: (params) ->

		app.models['user'].set('current_page', 'payments')

		if params?['onboarding']
			app.module('Onboarding').trigger 'start:onboarding'
		else
			@check_onboarding(params)

		PaymentsView = require '../views/payments'
		pv = new PaymentsView({model: app.models['user']})
		app.layout.content.show(pv)

	settings: (params) ->

		app.models['user'].set('current_page', 'settings')
		if params?
			setting = params['setting']
		else
			setting = 'account'
		app.module('Settings').start(params)

	check_onboarding: (params) ->
		if params?
			return 

		user = app.models['user']
		if user.get('onboarding_skipped') >= 2
			# if user.get('country') is 'us'
			# 	if not user.get('meta')? or not user.get('meta')['synapse_kyc']?
			# 		app.module('Synapse').start()
			return

		reroute = false

		try
			onboarding = params['onboarding']
		catch e
			reroute = false

		if not onboarding?
			reroute = true
		else if onboarding? and onboarding is true
			reroute = false

		if reroute
			@navigate Backbone.history.getFragment() + '?onboarding=true', trigger: true

	clear: () ->
		app.models['user'].set('current_action', '')
		# app.module('Dashboard').stop()
		app.module('Onboarding').stop()
		app.module('Market').stop()
		app.module('Settings').stop()
		app.module('Activity').stop()
