module.exports = class Activities extends require('./composite_view')

	childView: require('./activity')
	collection: require('../collections/activities')
	tagName: 'div'
	template: require '../templates/activity/activities'

	events:
		'click .func__paginate_prev': 'paginate_prev'
		'click .func__paginate_next': 'paginate_next'

	initialize: (options) ->

	onAddChild: () ->
		$('.func__no_activity').remove()
		app.trigger 'set_sidebar_selected'

	paginate_prev: () ->
		if @collection.offset is 0
			return
		app.router.navigate 'activity?page=' + @collection.offset, trigger: true

	paginate_next: () ->
		app.router.navigate 'activity?page=' + (@collection.offset + 2), trigger: true
