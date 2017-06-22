
module.exports = class Onboarding1 extends require('./model')

	initialize: () ->

		try 
			@sync_values 'user', ['id_scanned', 'id_selfie_scanned', 'social_verified']
		catch e 
			app.trigger 'error', e

	check_continue: () ->
		social_verified = @get('social_verified')
		if not social_verified? or not social_verified
			social_verified = false
		else
			social_verified = true
		return @get('id_scanned') and @get('id_selfie_scanned') and social_verified
	