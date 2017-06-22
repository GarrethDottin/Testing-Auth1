require './swag'
Swag.registerHelpers(Handlebars)

Handlebars.registerHelper('each_upto', (ary, max, options) ->

    if(!ary || ary.length == 0)
        return options.inverse(this)

    result = [ ]
    `
    for(var i = 0; i < max && i < ary.length; ++i)
        result.push(options.fn(ary[i]));
    `
    return result.join('')
)

Handlebars.registerHelper('ifCond', (v1, v2, options) ->
    if(v1 is v2)
        return options.fn(this)
    else
        return options.inverse(this)
)

`
Handlebars.registerHelper('each_hash', function(context, options) {
    var fn = options.fn, inverse = options.inverse;
    var ret = "";

    if(typeof context === "object") {
        for(var key in context) {
            if(context.hasOwnProperty(key)) {
                // clone the context so it's not
                // modified by the template-engine when
                // setting "_key"
                var ctx = jQuery.extend(
                    {"_key":key},
                    context[key]);

                ret = ret + fn(ctx);
            }
        }
    } else {
        ret = inverse(this);
    }
    return ret;
});
`