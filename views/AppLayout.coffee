
module.exports = class AppLayout extends Backbone.Marionette.LayoutView
	template: require '../templates/appLayout'
	el: "body"

	regions:
		sidebar_mobile: "#sidebar-mobile"
		nav: "#nav"
		content: "#content"
		sidebar: "#sidebar"
		modals: "#modals"

	events:
		'click .navbar-toggle': (e) ->
			e.preventDefault()
			e.stopPropagation()

			if app.snapper.state()['state'] is 'closed'
				app.snapper.open('left')
			else
				app.snapper.close()

		'focusout .func__state_province_region': 'check_address_spr'

	initialize: () ->
		
		$ ->

			# Semanitic modules settings

			$.fn.modal.settings.debug = false
			$.fn.modal.settings.verbose = false
			$.fn.modal.settings.performance = false

			$.fn.dimmer.settings.debug = false
			$.fn.dimmer.settings.verbose = false
			$.fn.dimmer.settings.performance = false

			$.fn.dropdown.settings.debug = false
			$.fn.dropdown.settings.verbose = false
			$.fn.dropdown.settings.performance = false

			$.fn.checkbox.settings.debug = false
			$.fn.checkbox.settings.verbose = false
			$.fn.checkbox.settings.performance = false

	onRender: () ->

		if $('.lpiframeoverlay').length
			$('.lpiframeoverlay').remove()

		if $(window).width() < 1040
			app.snapper = new Snap(
				element: document.getElementById('snapper')
				disable: 'right'
			)

	onDomRefresh: () ->

		if $('.lpiframeoverlay').length
			$('.lpiframeoverlay').remove()

	check_address_spr: () ->

		regex = /^[A-Za-z]{2}/
		$state_province_region = $('.func__state_province_region')
		state_province_region = $.trim($state_province_region.val())
		if not state_province_region?
			app.notify 'error', 'Please format your state/provice/region to XX (i.e. ON).'
			$state_province_region.addClass('error')
			return
		if state_province_region.length isnt 2 or not regex.test(state_province_region)
			app.notify 'error', 'Please format your state/provice/region to XX (i.e. ON).'
			$state_province_region.addClass('error')
		else
			$state_province_region.removeClass('error')

	# i.e. create_dom_el(div, 'btn btn-primary', 'my-button')
	create_dom_el_before: (el_type, classnames, idname) ->
		el = '<' + el_type + ' class="' + classnames + '" id="' + idname + '"></' + el_type + '>'
		@$('.func__content').before(el)
