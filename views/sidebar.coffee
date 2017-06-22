template = require '../templates/sidebar'

module.exports = class SideBarView extends Backbone.Marionette.ItemView
    id: 'sidebar-view'
    template: template
    className: 'snapper-absolute'

    modelEvents:
        'change:account_tier': 'fieldsChanged'

    events:

        'click .item': (e) ->
            if $(window).width() < 767
                app.snapper.close()
            e.stopPropagation()
            $ref = @$(e.currentTarget)
            route = $ref.data 'route'
            if not route?
                return
            @$('.item').removeClass 'active'
            if $ref.hasClass 'market'
                $('.btc.item').addClass 'active'
            else
                $ref.addClass 'active'
            $('html,body').scrollTop(0)
            app.router.navigate route, trigger: true

         'click .func__signout': (e) ->
            e.preventDefault()
            dfd = $.post SITE_URL + '/logout'
            dfd.done () =>
                location.reload()
            dfd.fail () =>
                app.trigger 'error', new Error('Call to /logout failed')
                location.reload()

    initialize: () ->

        app.on 'set_sidebar_selected', $.proxy @set_sidebar_selected, @
        base = require('./mixins/base')
        Cocktail.mixin(@, base)

    fieldsChanged: () ->
        @render()
        @set_sidebar_selected()

    onShow: () ->
        $(window).resize @sidebar_height
        @set_sidebar_selected()

    set_sidebar_selected: () ->

        page = app.models['user'].get('current_page')
        $('#sidebar-view .item').removeClass 'active'

        if page is 'dashboard'
            $('#sidebar-view .dashboard').addClass('active')
        else if page is 'activity'
            $('#sidebar-view .activity').addClass('active')
        else if page is 'buy_btc' or page is 'sell_btc'
            $('#sidebar-view .market').addClass('active')
        else if page is 'buy' or page is 'sell'
            $('#sidebar-view .btc').addClass('active')
        else if page is 'payments'
            $('#sidebar-view .payments').addClass('active')
        else if page is 'settings'
            $('#sidebar-view .settings').addClass('active')

        setTimeout(() =>
            @sidebar_height()
        10)

    sidebar_height: () ->

        height = $('.ha-main').height() 
        window_height = $(window).height()
        $('.func__sidebar').css('min-height', window_height + 'px')
        if window_height > height
            height = window_height
        $('.func__sidebar').height height
