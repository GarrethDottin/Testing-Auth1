module.exports = plugins = () =>

	$.fn.removeClassRegex = (regex) ->
		$(@).removeClass (index, classes) ->
			classes.split(/\s+/).filter (c) ->
				regex.test c
			.join ' '

	$.urlParam = (name) ->
		results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href)
		if results is null
			return null
		else
			return results[1] || 0

	String.prototype.capitalize = () ->
		return this.charAt(0).toUpperCase() + this.slice(1)
