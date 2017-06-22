### 
	Application Class
	Responsible for initializing and managing all components of the application
###

# Require the view helpers
require './lib/helpers'

class Application extends Backbone.Marionette.Application

	initialize: () ->	
		
		# Initializers 
		@addInitializer(@setInitVariables)
		@addInitializer(@setEnvVariables)
		@addInitializer(@setBasil)
		@addInitializer(@setModels)
		@addInitializer(@setLayout)
		@addInitializer(@setModules)
		@addInitializer(@setUserInitEvent)
		@addInitializer(@setViews)

		# Before start functions
		@on('before:start', @requirePlugins)
		@on('before:start', @check_verification_status)
		@on('before:start', @setRouter)

		# Onstart function
		@on('start', @onStart)

		# Application start

		@getUser (user) =>
			@start(user)

	# Start function

	onStart: () ->
		if not Backbone.History.started
			Backbone.history.start(pushState: true)	
			Object.freeze? @

	# Initializer functions

	# Sets variables needed for init
	setInitVariables: () ->
		window.app = @
		@models = {}
		@collections = {}
		@generic_error = 'Whoops, we experienced an error. Please try again soon.'
		@CRYPTO_ROUNDING = 4
		@FIAT_ROUNDING = 2
		@MIN_VOL = 
			btc: 0.01
			ltc: 0.1
		@snapper = {}

	# Sets the client-side equivalent of a ENV variables
	setEnvVariables: () ->
		@ENV = window.location.hostname
		if @ENV is 'localhost'
			window.SITE_URL = 'http://localhost:3000'
		else if @ENV is 'staging.harbor.ly'
			window.SITE_URL = 'https://staging.harbor.ly'
		else if @ENV is 'harbor.ly'
			window.SITE_URL = 'https://harbor.ly'
		else
			protocol = window.location.protocol
			host = window.location.host 
			window.SITE_URL = protocol + '//' + host

	# Gets the user from the server and uses the data to set the gloal models
	getUser: (cb) ->
		dfd = $.post '/private/user/initialize'
		dfd.done (data) =>
			if not data['error']
				user = data['data']
				cb(user)
			else
				@notify 'error', 'Internal Server Error. Please try again.'
		dfd.fail (data) =>
			@notify 'error', 'Internal Server Error. Please try again.'

	# Takes in the user object and sets the global models
	setModels: (user) ->
		User = require './models/user'
		Tickers = require './models/tickers'
		Nav = require './models/nav'
		Sidebar = require './models/sidebar'

		@models['user'] = new User(user)
		@models['tickers'] = new Tickers()
		@models['nav'] = new Nav()
		@models['sidebar'] = new Sidebar()
		@models['user'].start()

		# @setViews()

	# Called after the models are set, sets the views
	setViews: () ->
		Sidebar = require './views/sidebar'
		@sidebar = new Sidebar(model: @models['sidebar'])

		if $(window).width() < 767
			@layout.sidebar_mobile.show(@sidebar)
		else
			@layout.sidebar.show(@sidebar)

		Nav = require './views/nav'
		@nav = new Nav(model: @models['nav'])

		@layout.nav.show(@nav)

	# Sets the basil storage object (https://github.com/Wisembly/basil.js/tree/master)
	setBasil: () ->
		@basil = new window.Basil()

	# Sets the application layout object and renders
	setLayout: () ->
		AppLayout = require './views/AppLayout'
		require './modules/modal/Modal'
		@layout = new AppLayout()
		@layout.render()

	# Requires all the global modules 
	setModules: () ->
		require './modules/Onboarding'
		require './modules/Activity'
		require './modules/Market'
		require './modules/Settings'

	# Sets a listener for user init, which refreshes the user data from the server
	setUserInitEvent: () ->
		@on 'user:init', () =>
			@getUser (user) =>
				@models['user'].attributes = user
				@models['user'].start()
				
		@on '401', () =>
			protocol = window.location.protocol
			host = window.location.host 
			window.location.replace protocol + '//' + host + '/signin?post=' + Backbone.history.fragment

		@on 'error', (err) =>
			console.log err
			console.log err.stack
			try
				Raven.captureMessage(err)
			catch e 
				console.log e

	# Before start functions

	# Requires custom plugins
	requirePlugins: () ->
		require('./lib/plugins')()

	# Sets the router class
	setRouter: () ->
		Router = require './lib/router'
		@router = new Router()

	# Checks if the app is being started in a "just verified" state
	check_verification_status: () ->
		verification_success = $.urlParam('verification_success')
		try
			verification_success = JSON.parse(verification_success)
		catch e
			app.trigger 'error', e

		if verification_success? and verification_success
			setTimeout(() =>
				@notify 'success', 'Your email address has been successfully verified.'
			1000)
			
		else if verification_success? and not verification_success 
			setTimeout(() =>
				@notify 'error', 'There was an error verifying your email address. Please try again.'
			1000)

		added_network = $.urlParam('added_network')
		try 
			added_network = JSON.parse(added_network)
		catch e 
			app.trigger 'error', e

		if added_network? and added_network
			setTimeout(() =>
				@notify 'success', 'Your social network has successfully been verified.'
			1000)
		else if added_network? and not added_network
			setTimeout(() =>
				@notify 'error', 'This social network is already in use, please use another one.'
			1000)

	# App helper functions

	# generates a UUID
	UUID: () ->
		s = []
		hexDigits = "0123456789abcdef"
		`
		for (var i = 0; i < 36; i++) {
			s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
		}
		`
		s[14] = "4"
		s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1)
		s[8] = s[13] = s[18] = s[23] = "-"

		uuid = s.join("")
		return uuid

	# app.notify 'error'/'success', message
	notify: (type, message) ->
		Messenger.options =
			theme: 'air'
			extraClasses: 'messenger-fixed messenger-on-top messenger-center'
		types = ['error', 'success']
		if not (type in types)
			return
		Messenger().post
			message: message
			type: type
			showCloseButton: true

module.exports = new Application()
