
module.exports = class Collection extends Backbone.Collection

	fetch: (options) ->

		dfd = $.ajax
			type: 'POST',
			url: @url,
			data: options['data'] or {}
			dataType: 'json',
			success: (resp) =>
				if not resp['error']
					@reset(resp['data'])
				else
					dfd.fail(resp)
		return dfd
