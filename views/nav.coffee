template = require '../templates/nav'

module.exports = class NavView extends Backbone.Marionette.ItemView
    id: 'nav-view'
    template: template

    modelEvents:

        'change:name': 'fieldsChanged'
        'change:quote': 'fieldsChanged'
        'change:fiat_symbol': 'fieldsChanged'

    events:
        'click .func__signout': (e) ->
            e.preventDefault() 
            dfd = $.post SITE_URL + '/logout'
            dfd.done () =>
                location.reload()
            dfd.fail () =>
                app.trigger 'error', new Error('Call to /logout failed')
                location.reload()

        'mouseenter .dropdown': (e) ->
            @$(e.currentTarget).toggleClass('open')
        'mouseleave .dropdown': (e) ->
            @$(e.currentTarget).toggleClass('open')

    fieldsChanged: () ->
        @render()


