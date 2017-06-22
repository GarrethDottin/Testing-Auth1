###
	Address Search Mixin
	Handles manual address entry, searching for an address match and selecting an address
###

module.exports =

	onRender: () ->
		@events()

	events: () ->
		@$('.func__add_personal_address').off('click', @launch_manual_personal_address_modal)
		@$('.func__add_personal_address').on('click', $.proxy @launch_manual_personal_address_modal, @)

		@$('.func__personal_address').off('keyup', @start_search)
		@$('.func__personal_address').on('keyup', $.proxy @start_search, @)

		@$(':not(.func__search_click_state)').off('click', @hide_search_results)
		@$(':not(.func__search_click_state)').on('click', $.proxy @hide_search_results, @)

		@$('.func__search_results li').off('click', @retrieve_address)
		@$('.func__search_results li').on('click', $.proxy @retrieve_address, @)
	
	# personal address modal
	launch_manual_personal_address_modal: (e) ->

		$('.ui.modal.func__launch_add_personal_address').modal('setting',
			onShow: () =>
				address = @model.get('address')
				if not _.isEmpty(address)
					$('.func__address_1').val(address['addressline1'])
					$('.func__address_2').val(address['addressline2'])
					$('.func__city').val(address['city'])
					$('.func__state_province_region').val(address['state_province_region'])
					$('.func__zip_postal').val(address['zip_postal'])
				$('.func__close').click () =>
					$('.ui.modal.func__launch_add_personal_address').modal('hide')
				$('.func__modal_save_address').click (e) =>
					@save_personal_manual_address e
			onHide: () =>
				app.trigger 'check:continue'
				$('.func__modal_save_address').off()
		).modal('show')

	# Correct auto search as typing logic
	start_search: (e) ->

		clearTimeout @address_timeout

		@address_timeout = setTimeout(() =>
			@find_address()
		300)
		app.trigger 'check:continue'

	# Hide the results if user clicks anywhere else but on the address
	hide_search_results: (e) ->
		@$('.func__search_results').addClass('hidden')
		@$('.func__search_results li').remove()

	# When a auto complete item is clicked, retreive te whole address and set it
	retrieve_address: (e) ->
		@address_id = $(e.currentTarget).data('id')
		@address_text = $(e.currentTarget).text()
		@$('.func__personal_address').removeClass('error')
		@$('.func__personal_address').val @address_text
		@model.set 'address_text', @address_text

		# if app.ENV is 'localhost'
		# 	data = {"Items":[{"Id":"CAN|PR|X227937399|F|0|0","DomesticId":"13791354","Language":"FRA","LanguageAlternatives":"FRA,ENG","Department":"","Company":"","SubBuilding":"123","BuildingNumber":"555","BuildingName":"","SecondaryStreet":"","Street":"Boul Saint-Jude","Block":"","Neighbourhood":"","District":"","City":"Alma","Line1":"123-555 Boul Saint-Jude","Line2":"","Line3":"","Line4":"","Line5":"","AdminAreaName":"","AdminAreaCode":"","Province":"QC","ProvinceName":"Québec","ProvinceCode":"QC","PostalCode":"G8B 0C7","CountryName":"Canada","CountryIso2":"CA","CountryIso3":"CAN","CountryIsoNumber":124,"SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"123-555 Boul Saint-Jude\nALMA QC G8B 0C7\nCANADA","Type":"Residential","DataLevel":"Premise"},{"Id":"CAN|PR|X227937399|E|0|0","DomesticId":"13791354","Language":"ENG","LanguageAlternatives":"FRA,ENG","Department":"","Company":"","SubBuilding":"123","BuildingNumber":"555","BuildingName":"","SecondaryStreet":"","Street":"Saint-Jude Blvd","Block":"","Neighbourhood":"","District":"","City":"Alma","Line1":"123-555 Saint-Jude Blvd","Line2":"","Line3":"","Line4":"","Line5":"","AdminAreaName":"","AdminAreaCode":"","Province":"QC","ProvinceName":"Québec","ProvinceCode":"QC","PostalCode":"G8B 0C7","CountryName":"Canada","CountryIso2":"CA","CountryIso3":"CAN","CountryIsoNumber":124,"SortingNumber1":"","SortingNumber2":"","Barcode":"","POBoxNumber":"","Label":"123-555 Saint-Jude Blvd\nALMA QC G8B 0C7\nCANADA","Type":"Residential","DataLevel":"Premise"}]}

		# 	@handle_retrieve(data)
		# else

		$.getJSON("https://services.postcodeanywhere.co.uk/CapturePlus/Interactive/Retrieve/v2.10/json3.ws?callback=?",
			Key: 'MT28-JJ43-ZX93-NA26',
			Id: @address_id
		,$.proxy(@handle_retrieve,@))

	handle_retrieve: (data) ->

		if data.Items.length == 1 && typeof(data.Items[0].Error) != "undefined"
			console.log(data.Items[0].Description)
		else
			if data.Items.length == 0
				# console.log("Sorry, there were no results")
				@$('.func__personal_address').val("Sorry, there were no results. Please be more specific or add your address manually.").addClass('error')

			else
				address_data = data['Items'][0]
				address = 
					addressline1: address_data['Line1']
					addressline2: address_data['Line2']
					city: address_data['City']
					state_province_region: address_data['Province']
					state_province_region_name: address_data['ProvinceName']
					zip_postal: address_data['PostalCode']
					service_id: @address_id

				@model.set 'address', address 
				@check_continue()

	find_address: () ->

		address = $.trim $('.func__personal_address').val()
		country = @model.get('country')
		if not country?
			return
		country = country.toUpperCase()

		if address is ''
			$('.func__search_results li').remove()
			return

		if  address is @prev_address
			return

		@prev_address = address

		$('.func__address_form_wrap').addClass('loading')
		$('.func__search_results').addClass('hidden')

		# if app.ENV is 'localhost'
		# 	data = {"Items":[{"Id":"CAN|PR|X2047860951|E|0|0","Text":"1 281 Rten, Armagh, QC Unit 123","Highlight":"","Cursor":31,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X225830899|E|0|0","Text":"121 Av Gouin, Amos, QC Unit 123","Highlight":"","Cursor":31,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X227937399|E|0|0","Text":"555 Boul Saint-Jude, Alma, QC Unit 123","Highlight":"","Cursor":38,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X218588578|E|0|0","Text":"775 Av Des Mélèzes, Alma, QC Unit 123","Highlight":"","Cursor":37,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X2046986023|E|0|0","Text":"1268 Rue Ricard, Acton Vale, QC Unit 123","Highlight":"","Cursor":40,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X915098508|E|0|0","Text":"Cp 123, Bdp, Acton Vale, QC","Highlight":"","Cursor":0,"Description":"","Next":"Retrieve"},{"Id":"CAN|PR|X2047090249|E|0|0","Text":"1565 Rue Saint-Amour, Acton Vale, QC Unit 123","Highlight":"","Cursor":45,"Description":"","Next":"Retrieve"}]}
		# 	@handle_find(data)
		# else

		$.getJSON("https://services.postcodeanywhere.co.uk/CapturePlus/Interactive/Find/v2.10/json3.ws?callback=?",
			Key: 'MT28-JJ43-ZX93-NA26',
			SearchTerm: address,
			# LastId: '0',
			SearchFor: 'Everything',
			Country: country,
			LanguagePreference: 'EN',
			MaxSuggestions: 7,
			MaxResults: 7
		,$.proxy(@handle_find, @))

	handle_find: (data) ->

		$('.func__address_form_wrap').removeClass('loading')

		if data.Items.length == 1 && typeof(data.Items[0].Error) != "undefined"
			alert(data.Items[0].Description);
		else
			if data.Items.length == 0
				console.log 'no results'
			else 
				$('.func__search_results li').remove()
				for result in data['Items']
					$('.func__search_results ul').append '
						<li data-id="' + result['Id'] + '"> ' + result['Text'] + '</li>
					'
				$('.func__search_results').removeClass('hidden')

				@events()

	save_personal_manual_address: (e) ->

		$('.messenger-shown').remove()

		address = 
			addressline1: $.trim($('.func__address_1').val())
			addressline2: $.trim($('.func__address_2').val()) || 'NA'
			city: $.trim($('.func__city').val())
			state_province_region: $.trim($('.func__state_province_region').val())
			zip_postal: $.trim($('.func__zip_postal').val())

		errors = false

		if address['addressline1'] is ''
			errors = true
			app.notify 'error', 'Please provide the first address line.'

		if address['city'] is ''
			errors = true
			app.notify 'error', 'Please provide a city.'
			
		if address['state_province_region'] is ''
			errors = true
			app.notify 'error', 'Please provide a state, province or region.'
			
		if address['zip_postal'] is ''
			errors = true
			app.notify 'error', 'Please provide a ZIP or postal code.'
			
		if errors 
			return

		text = ''

		text+= $.trim(address['addressline1']) + ' '
		if address['addressline1']? and $.trim(address['addressline1']) isnt ''
			text+= ', ' + $.trim(address['addressline2'])
		text+= ', ' + $.trim(address['city'])
		text+= ', ' + $.trim(address['state_province_region'])
		text+= ' '  + $.trim(address['zip_postal'])

		@model.set 'address', address 
		$('.ui.modal.func__launch_add_personal_address').modal('hide')
		$('.func__personal_address').val $.trim(text)

		@check_continue()
