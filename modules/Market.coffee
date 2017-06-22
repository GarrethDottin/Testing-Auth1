
app.module 'Market', () ->

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
			Market = require '../models/market'
			app.models['market'] = new Market(@options)
		catch e 
			return cb e
		return cb null

	@_create_views = (cb) =>

		try 
			Market = require '../views/market/market'
			@view = new Market model: app.models['market']
		catch e 
			return cb e
		return cb null

	@_show_views = (cb) =>

		try 
			app.layout.content.show @view
		catch e 
			return cb e
		return cb null
