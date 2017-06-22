
app.module 'Activity', () ->

	@startWithParent = false

	@onStart = (options) =>

		@options = options

		@init (err) =>
			if err?
				app.trigger 'error', err

	@init = (cb) =>

		# setTimeout(() =>
		# 	app.trigger 'user:init'
		# 3000)

		@create_collection (err) =>
			if err?
				return cb err 
			@_create_views (err) =>
				if err?
					return cb err
				@_show_views (err) =>
					if err?
						return cb err

	@create_collection = (cb) =>
		try 
			Activities = require '../collections/activities'
			app.collections['activities'] = new Activities(@options)
		catch e 
			return cb e
		return cb null

	@_create_views = (cb) =>

		try 
			Activities = require '../views/activities'
			@view = new Activities collection: app.collections['activities']
		catch e 
			return cb e
		return cb null

	@_show_views = (cb) =>

		try 
			app.layout.content.show @view
		catch e 
			return cb e
		return cb null




