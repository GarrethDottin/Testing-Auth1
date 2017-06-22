
module.exports =

	onRender: () ->
		@$('.func__resend_link').off('click', @resend_link)
		@$('.func__resend_link').on('click', $.proxy @resend_link, @)
		
	resend_link: (e) ->
		e.preventDefault()
		dfd = $.post SITE_URL + '/private/user/resend/verification',
			email: app.models['user'].get('email')
		dfd.done (data) =>
			if data['error']
				message = 'Error sending verification link. Try again soon.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
			else
				app.notify 'success', 'Successfully re-sent verification link.'
				