module.exports = class Activity extends Backbone.Marionette.ItemView

	id: 'activity-view'
	tagName: 'span'
	template: require '../templates/activity/activity'

	fieldsChanged: () ->
		@render()

	initialize: () ->

	onShow: () ->
	