
module.exports = class Model extends Backbone.Model

	# Takes in a model name and an array of attributes
	# Makes sure the model calling will sync to the model's attributes
	sync_values: (model_name, attributes) ->
		@_set_listentos(model_name, attributes)
		@_get_values(model_name, attributes)

	_get_values: (model_name, attributes) ->
		for attr in attributes
			model = app.models[model_name]
			if not model?
				return throw new Error 'Model does not exist: ' + model_name
			attribute = model.get(attr)
			if attribute?
				@set(attr, attribute)

	_set_listentos: (model_name, attributes) ->
		model = app.models[model_name]
		if not model?
			return throw new Error 'Model does not exist: ' + model_name
		for attr in attributes
			((attr, attributes) =>
				@listenTo model, 'change:' + attr, () =>
					@set(attr, model.get(attr))
			)(attr, attributes)

	find_with_attr: (obj, attr, value)  ->
		for k,v of obj
			if v[attr] is value
				return v
	
	save: (attribute, model) ->
		value = @get(attribute)
		model_value = app.models[model].get(attribute)
		if value isnt model_value
			app.models[model].set(attribute, value)
