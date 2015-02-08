
isplain    = (o) -> !!o && typeof o == 'object' && o.constructor == Object
isstring   = (s) -> typeof s == 'string'
isfunction = (s) -> typeof s == 'function'
last       = (as) -> as[as.length-1]


# escape text
esc   = (s = '') -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;')
# escape attributes
esca  = (s) -> esc(s).replace(/"/g,'&quot;')
# turn an array of mixed string/object to attributes
attr  = (k, v) -> if v then "#{esca(k)}=\"#{esca(v)}\"" else "#{esca(k)}"
attrs = (as) ->
    ((if isplain(a) then (attr(k,v) for k, v of a).join(' ') else attr(a)) for a in as).join(' ')


# trixy globals for executing nested
_ctx = null
_out = null


# unwrapper for nested content/tag function
unnest = (ctx, nested) ->
    if isfunction nested
        unnest ctx, nested.call(ctx, ctx)
    else if isstring nested
        nested
    else
        ''

# creates a tag
tag = (name, close) -> (args...) ->
    lst = last(args)
    if isfunction lst
        args = args[0...-1]
        nested = lst
    else if isstring lst
        args = args[0...-1]
        nested = -> lst
    args = args.filter (x) -> x

    render = (ctx) ->
        # outer tag sets up buffer that inner renders into
        unless _out
            (buf = []; _ctx = ctx; _out = (s) -> buf.push s)
            try (render.call(ctx,ctx); return buf.join('')) finally (_ctx = null; _out = null)
        _out "<#{name}" +
            (if args.length then " " + attrs(args) else "") +
            (if close then "/" else "") + ">"
        _out unnest(ctx, nested)
        _out (if close then "" else "</#{name}>")
        null

    # execute straight away if there is a rendering context
    if _ctx then render(_ctx) else render



div  = tag 'div'
span = tag 'span'
p    = tag 'p'
img  = tag 'img', true
