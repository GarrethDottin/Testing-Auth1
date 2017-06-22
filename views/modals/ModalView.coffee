template = require '../../templates/modals/modals'

module.exports = class ModalView extends Backbone.Marionette.ItemView
	id: 'modals-view'
	template: template

	modelEvents:
		'change:synapse_banks': () ->
			console.log 'render'
			@render()

	initialize: ->

	handle_change: () ->

	onShow: () ->

		$('.modal').modal('setting',
			onShow: () ->
				$('.func__close').click () ->
					$(@).parent('.modal').modal('hide')
			onHide: () ->
				$('.func__close').off()
		).modal()
