
app.module 'Settings', () ->

	@startWithParent = false

	@onStart = (options) =>
		@options = options
		@init (err) =>
			if err?
				app.trigger 'error', err

	@init = (cb) =>

		@create_models (err) =>
			if err?
				return cb err
			@_create_views (err) =>
				if err?
					return cb err
				@_show_views (err) =>
					if err?
						return cb err

	@create_models = (cb) =>
		try 
			if not app.models['settings']?
				Settings = require '../models/settings'
				app.models['settings'] = new Settings(@options)
		catch e 
			return cb e
		return cb null

	@_create_views = (cb) =>

		try 
			Settings = require '../views/settings'
			@view = new Settings model: app.models['settings']
		catch e 
			return cb e
		return cb null

	@_show_views = (cb) =>

		try 
			app.layout.content.show @view
		catch e 
			return cb e
		return cb null
