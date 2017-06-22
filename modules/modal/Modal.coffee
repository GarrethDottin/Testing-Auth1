
app.module 'Modal', (MyModule, MyApp, Backbone, Marionette, $, _) ->

	@startWithParent = true

	@onStart = (type) =>

		@init_modals()
		@on 'show', @show_modal

	@init_modals = () =>
		$('.modal').remove()
		ModalView = require '../../views/modals/ModalView'
		@mv = new ModalView(model: app.models['user'])
		app.layout.modals.show @mv

	@show_modal = (class_name, config_name) =>

		@mv.model = model
		@mv.onRender = () ->
			$('.modal.' + class_name).modal('show')

		$('.modal').remove()
		@mv.render()
		@mv.onShow()
		