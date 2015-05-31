isplain     = (o) -> !!o && typeof o == 'object' && o.constructor == Object
isstring    = (s) -> typeof s == 'string'
isprimitive = (a) -> typeof a in ['boolean', 'number', 'string', 'symbol']
isfunction  = (s) -> typeof s == 'function'
not_        = (f) -> (a...) -> !f(a...)
mixin       = (os...) -> r = {}; r[k] = v for k, v of o for o in os; r

# boolean attributes (including html for DOCTYPE) from https://html.spec.whatwg.org/#attributes-3
bool = {}
'allowfullscreen,async,autofocus,autoplay,checked,controls,default,defer,disabled,\
formnovalidate,hidden,ismap,itemscope,loop,multiple,muted,novalidate,open,readonly,\
required,reversed,scoped,seamless,selected,sortable,typemustmatch,\
html'.split(',').forEach (a) -> bool[a] = true

# escape text
esc   = (s = '') -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;')
# escape attributes
esca  = (s) -> esc(s).replace(/"/g,'&quot;')
# turn an array of mixed string/object to attributes
attr  = (k, v) ->
    if bool[k] then (if v then "#{esca(k)}" else '') else "#{esca(k)}=\"#{esca(v)}\""
attrs = (a) -> (attr(k,v) for k, v of a).join(' ')

# unwrapper for nested content function
unnest = (bind, f) ->
    if isfunction f
        unnest bind, f.call(bind)
    else if isprimitive(f)
        out.text String(f)

# global output when rendering, set vi capture()
out = null

# creates a tag
tag = (name, vod, ispass=false) -> tagf = (args...) ->

    # outmost tag sets up / tears down a StringOut
    return capture(new StringOut, tagf, args) unless out

    objs = args.filter(isplain).reduce ((p ,c) -> mixin p, c), {}
    funs = args.filter(not_ isplain).map (a) -> if !isfunction(a) then (->a) else a

    out.begin name, vod, objs unless ispass
    unnest(this, f) for f in funs
    out.close name unless vod
    undefined

# default output, as string
class StringOut
    constructor: ->
        @buf = []
    start: ->
    begin: (name, vod, props) ->
        @buf.push "<#{name}" + (if (a = attrs(props)).length then " " + a else "") + ">"
    text: (t) ->
        @buf.push esc(t)
    close: (name) ->
        @buf.push "</#{name}>"
    end: -> @buf.join('')

# capture the output for the given tag function applying args
capture = (_out, tagf, args) ->
    try
        out = _out
        out.start()
        tagf.apply this, (args ? [])
    finally
        out = null
    _out.end()

# the exported tags (and tag/capture function)
tags = {tag, capture}

# ############ LIST OF DEFINED TAGS

# html5 normal elements, copied from https://developer.mozilla.org/en/docs/Web/HTML/Element
'html,head,style,title,address,article,body,footer,header,h1,h2,h3,h4,h5,h6,hgroup,\
nav,section,blockquote,dd,div,dl,dt,figcaption,figure,li,main,ol,p,pre,ul,a,abbr,b,bdi,\
bdo,cite,code,data,dfn,em,i,kbd,mark,q,rp,rt,ruby,s,samp,small,span,strong,sub,sup,\
time,u,var,audio,map,video,iframe,object,canvas,noscript,script,del,ins,caption,colgroup,\
table,tbody,td,tfoot,th,thead,tr,button,datalist,fieldset,form,label,legend,meter,optgroup,\
option,output,progress,select,textarea,details,dialog,menu,menuitem,summary,content,\
decorator,element,shadow,template'.split(',').forEach (t) -> tags[t] = tag t

# void elements, see http://stackoverflow.com/questions/3558119#answer-3558200
'area,base,br,col,embed,hr,img,input,keygen,link,meta,param,source,\
track,wbr'.split(',').forEach (t) -> tags[t] = tag t, true

# special passthrough tag.
tags['pass'] = tag 'pass', true, true

tags.html5 = (as...) ->
    tag('!DOCTYPE', true) html:true, '\n', -> tags.html as...

if typeof module == 'object'
    module.exports = tags
else if typeof define == 'function' and define.amd
    define -> tags
else
    this.tagg = tags
