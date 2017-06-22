module.exports = class View extends Backbone.Marionette.CompositeView

	appendHtml: (collectionView, itemView, index) ->
		collectionView.$('.func__append_to').append(itemView.el)

	childViewContainer: () ->
		return '.func__append_to'

	onAddChild: () ->
		


