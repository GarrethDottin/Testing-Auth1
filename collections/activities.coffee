
module.exports = class Activities extends require('./collection')

	url: '/private/actions/paginate'
	model: require '../models/activity'

	initialize: (options) ->
		@limit = 10
		if not options?
			options =
				page: 1
		if options['page']?	
			@offset = options['page'] - 1
		else
			@offset = 0

		@get_activity()

	get_activity: () ->
		data = 
			user_uid: app.models['user'].get 'uid'
			limit: @limit
			offset: @offset * @limit
		dfd = @fetch data: data
