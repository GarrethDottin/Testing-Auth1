
module.exports = class Sidebar extends require('./model')

	initialize: () ->
		try 
			@sync_values 'user', ['country', 'name', 'profile_picture']
		catch e 
			app.trigger 'error', e