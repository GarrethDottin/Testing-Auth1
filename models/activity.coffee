
module.exports = class Activity extends require('./model')

	initialize: () ->

		@set_props()

	set_props: () ->

		created = parseInt @get 'created'
		date = moment(created).format("MMM Do YY, h:mm:ss a")
		date_mobile = moment(created).format("MMM Do YY")
		@set 'created_hr', date
		@set 'created_hr_mobile', date_mobile

	