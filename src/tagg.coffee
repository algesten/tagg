isplain    = (o) -> !!o && typeof o == 'object' && o.constructor == Object
isstring   = (s) -> typeof s == 'string'
isfunction = (s) -> typeof s == 'function'
concat     = (as) -> [].concat as...

# boolean attributes (including html for DOCTYPE) from https://html.spec.whatwg.org/#attributes-3
bool = {}
'allowfullscreen,async,autofocus,autoplay,checked,controls,default,defer,disabled,\
formnovalidate,hidden,ismap,itemscope,loop,multiple,muted,name,novalidate,open,readonly,\
required,reversed,scoped,seamless,selected,sortable,typemustmatch,\
html'.split(',').forEach (a) -> bool[a] = true

# escape text
esc   = (s = '') -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;')
# escape attributes
esca  = (s) -> esc(s).replace(/"/g,'&quot;')
# turn an array of mixed string/object to attributes
attr  = (k, v) ->
    if bool[k] then (if v then "#{esca(k)}" else '') else "#{esca(k)}=\"#{esca(v)}\""
attrs = (as) -> (concat (attr(k,v) for k, v of a for a in as)).join(' ')

# unwrapper for nested content function
unnest = (bind, f) ->
    if isfunction f
        unnest bind, f.call(bind)
    else if isstring f
        f
    else
        ''

# trixy global output buffer
_buf = null

# creates a tag
tag = (name, vod) -> r = (args...) ->

    # outmost tag sets up / tears down _buf
    unless _buf
        try
            _buf = []; r.apply(this, args); return _buf.join('')
        finally
            _buf = null

    objs = args.filter isplain
    funs = args.map((a) -> if isstring(a) then (->esc(a)) else a).filter isfunction

    _buf.push "<#{name}" +
        (if objs.length and (a = attrs(objs)).length then " " + a else "") +
        ">"
    _buf.push unnest(this, f) for f in funs
    _buf.push (if vod then "" else "</#{name}>")

# the exported tags (and tag function)
tags = {tag}

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

tags.html5 = (as...) ->
    tag('!DOCTYPE', true) html:true, '\n', -> tags.html as...

if typeof module == 'object'
    module.exports = tags
else if typeof define == 'function' and define.amd
    define -> tags
else
    this.tagg = tags
