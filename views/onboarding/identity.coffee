template = require '../../templates/onboarding/identity'

module.exports = class IdentityView extends Backbone.Marionette.ItemView
	id: 'onboarding-identity'
	className: 'ha-onboarding'
	template: template

	modelEvents:
		'change:id_scanned': 'fieldsChanged'
		'change:selfiescanned': 'fieldsChanged'
		'change:social_question_set': 'fieldsChanged'
		'change:social_verified': 'fieldsChanged'

	events:
		'click .func__next': 'save_and_continue'
		'click .func__launch_doc_upload': 'launch_doc_upload'
		'click .func__launch_selfie_upload': 'launch_selfie_upload'
		'click .func__submit_social': 'submit_social'
		'click .func__submit_social_answers': 'submit_social_answers'
			
	initialize: ->

		Cocktail.mixin(@, require './mixins/shared')

		@model.set 'step_percent', 100
		@model.set 'title', 'Verification'
		@model.set 'step_number', 2

	fieldsChanged: () ->
		doc = @$('.ui.dropdown.doc').dropdown('get value')
		@render()
		if doc.length
			@$('.ui.dropdown.doc').dropdown('set selected', doc)
		@$('.ui.dropdown').dropdown()
		@$('.ui.checkbox').checkbox()

	onRender: () ->
		@$('.ui.dropdown').dropdown()
		@$('.ui.checkbox').checkbox()

	onShow: () ->
		@check_continue()

	check_continue: () ->
		if @model.check_continue()
			@$('.func__next').removeClass('disabled')

	save_and_continue: (e) ->

		$button = @$(e.currentDefault)

		if $button.hasClass('disabled')
			return

		$button.addClass('disabled').addClass('loading')

		dfd = $.post SITE_URL + '/private/user/update/onboarding',
			completed: 1
			data: {}

		dfd.done (data) =>
			console.log data
			if not data['error']
				@model.set 'onboarding_step', 2
				app.models['user'].set 'onboarding_step', 2
				app.models['user'].set 'onboarding_skipped', 2
				slideup = (@$el.height() + 50)*-1
				@$el.velocity 'top': slideup + 'px', 300, () =>
					app.module('Onboarding').trigger 'completed:onboarding'
			else
				app.notify 'error', data['data']
				$button.removeClass('disabled').removeClass('loading')
				app.trigger 'error', new Error(data['data'])

		dfd.fail (data) =>
			if data.status is 401
				app.trigger '401'
				return
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')
			@render()
			app.trigger 'error', 'IdentityView - Call to /private/user/update/onboarding failed'

	launch_doc_upload: (e) ->

		self = @

		$('.func__doc_upload_modal').modal('setting',
			onShow: () =>

				if not window.doc_dz?

					window.doc_dz = new Dropzone('#doc-dropzone',
						url: '/id/submit'
						maxFilesize: 5
						addRemoveLinks: true
						autoProcessQueue: false
						maxFiles: 1
						acceptedFiles: '.jpg,.jpeg,.png'
						maxFilesize: 1
						dictDefaultMessage: 'Drop a file or click here to upload your ID. Allowed file types are JPG/JPEG and PNG.'
						accept: (file, done) =>
							done()
						init: () ->
							@on 'error', (file, message, cb) =>
								app.notify 'error', message
								window.doc_dz.removeAllFiles()
								$('.func__submit_doc').removeClass('disabled').removeClass('loading')
							@on 'success', (resp) =>
								app.notify 'success', 'Successfully uploaded your ID.'
								app.models['user'].set('id_scanned', true)
								$('.func__submit_doc').removeClass('disabled').text('Uploaded')
								self.render()
								$('.func__doc_upload_modal').modal('hide')
								self.check_continue()
					)

				$('.func__submit_doc').click (e) =>

					$button = $('.func__submit_doc')
					if $button.hasClass('disabled')
						return

					$button.addClass('disabled').addClass('loading')

					if not window.doc_dz.files.length
						app.notify 'error', 'Please upload a scan or picture of your ID.'
						$('.func__submit_doc').removeClass('disabled').removeClass('loading')
					else
						window.doc_dz.processQueue()

				$('.fa-close').click () =>
					$('.func__doc_upload_modal').modal('hide')
					$('html,body').css 'overflow', ''
			onVisible: () =>
				$('.func__doc_upload_modal').modal('center')
			onHide: () =>
				$('.func__submit_doc').off()
				
		).modal('show')

	launch_selfie_upload: (e) ->

		self = @

		$('.func__selfie_upload_modal').modal('setting',
			onShow: () =>

				if not window.selfie_dz?
					window.selfie_dz = new Dropzone('#selfie-dropzone',
						url: '/selfie/submit'
						maxFilesize: 5
						addRemoveLinks: true
						autoProcessQueue: false
						maxFiles: 1
						maxFilesize: 1
						acceptedFiles: '.jpg,.jpeg,.png'
						dictDefaultMessage: 'Drop a file or click here to upload a picture of you holding your ID. Allowed file types are JPG/JPEG and PNG.'
						accept: (file, done) =>
							done()
						init: () ->
							@on 'error', (file, message, cb) =>
								app.notify 'error', message
								window.selfie_dz.removeAllFiles()
								$('.func__submit_selfie').removeClass('disabled').removeClass('loading')
							@on 'success', (resp) =>
								app.notify 'success', 'Successfully uploaded your selfie.'
								$('.func__submit_selfie').removeClass('disabled').text('Uploaded')
								app.models['user'].set('id_selfie_scanned', true)
								self.render()
								$('.func__selfie_upload_modal').modal('hide')
								self.check_continue()
					)

				$('.func__submit_selfie').click () =>
					$button = $('.func__submit_selfie')
					if $button.hasClass('disabled')
						return

					$button.addClass('disabled').addClass('loading')

					if not window.selfie_dz.files.length
						app.notify 'error', 'Please upload a picture of yourself holding your ID.'
						$('.func__submit_selfie').removeClass('disabled').removeClass('loading')
					else
						window.selfie_dz.processQueue()

				$('.fa-close').click () =>
					$('.func__doc_upload_modal').modal('hide')
					$('html,body').css 'overflow', ''
			onVisible: () =>
				$('.func__doc_upload_modal').modal('center')
			onHide: () =>
				$('.func__submit_doc').off()
				
		).modal('show')
	
	submit_social: (e) ->
		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')
		$('.messenger-shown').remove()

		social = $.trim(@$('.func__document_val:visible').val())

		if social is ''
			app.notify 'error', 'Please provide your social security number (XX-XXX-XXXX).'
			$button.removeClass('disabled').removeClass('loading')
			return

		social = social.replace(/[^0-9]/g, '')
		if social.length isnt 9
			app.notify 'error', 'Please provide your full social security number (XX-XXX-XXXX).'
			$button.removeClass('disabled').removeClass('loading')
			return

		@model.set('document_value', social)

		console.log "in submit_social: " + social

		dfd = $.post SITE_URL + '/private/user/ssn/submit',
			social: social
			user_uid: app.models.user.get('uid')

		dfd.done (resp) =>
			if resp['error']
				message = 'Error verifying social security number.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
				$button.removeClass('disabled').removeClass('loading')
			else
				question_set = resp['data']['question_set']
				if question_set?
					@model.set('social_question_set', question_set)
				else
					@model.set('social_verified', true)
				@check_continue()
		dfd.fail (data) =>
			app.notify 'error', app.generic_error
			$button.removeClass('disabled').removeClass('loading')

	submit_social_answers: (e) ->

		$button = $(e.currentTarget)
		if $button.hasClass('disabled')
			return
		$button.addClass('disabled').addClass('loading')
		$('.messenger-shown').remove()

		question_set_id = @$('.func__questions').data('id')
		answers = []

		errors = false

		$questions = @$('.func__question')
		for q in $questions
			$selected = @$(q).find('input:checked')
			if not $selected.length
				errors = true
				message = 'Please select an answer for every question.'
				app.notify 'error', message
				break
			answers.push {
				question_id: parseInt($selected.attr('name'))
				answer_id: parseInt($selected.data('id'))
			}

		if errors 
			$button.removeClass('disabled').removeClass('loading')
			return

		dfd = $.post '/private/user/ssn/answers/submit', 
			user_uid: app.models.user.get('uid')
			answers: answers
			question_set_id: question_set_id

		dfd.done (resp) =>
			if resp['error']
				message = 'Error verifying social security number.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
				$button.removeClass('disabled').removeClass('loading')
			else
				@model.set('social_verified', true)
				@model.set('social_question_set', undefined)
				@render()
			@check_continue()
		dfd.fail (data) ->
				message = 'Error verifying social security number.'
				app.notify 'error', message
				app.trigger 'error', new Error(message)
				$button.removeClass('disabled').removeClass('loading')
