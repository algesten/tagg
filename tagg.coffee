isplain    = (o) -> !!o && typeof o == 'object' && o.constructor == Object
isstring   = (s) -> typeof s == 'string'
isfunction = (s) -> typeof s == 'function'
concat     = (as) -> [].concat as...

# escape text
esc   = (s = '') -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;')
# escape attributes
esca  = (s) -> esc(s).replace(/"/g,'&quot;')
# turn an array of mixed string/object to attributes
attr  = (k, v) -> if v then "#{esca(k)}=\"#{esca(v)}\"" else "#{esca(k)}"
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
tag = (name, close) -> r = (args...) ->

    # outmost tag sets up / tears down _buf
    unless _buf
        try
            _buf = []; r.apply(this, args); return _buf.join('')
        finally
            _buf = null

    objs = args.filter isplain
    funs = args.map((a) -> if isstring(a) then (->esc(a)) else a).filter isfunction

    _buf.push "<#{name}" +
        (if objs.length then " " + attrs(objs) else "") +
        (if close then "/" else "") + ">"
    _buf.push unnest(this, f) for f in funs
    _buf.push (if close then "" else "</#{name}>")

# the exported tags (and tag function)
tags = {tag}

# html5 tag list, copied from https://developer.mozilla.org/en/docs/Web/HTML/Element
'html,head,style,title,address,article,body,footer,header,h1,h2,h3,h4,h5,h6,hgroup,nav,section,blockquote,dd,div,dl,dt,figcaption,figure,li,main,ol,p,pre,ul,a,abbr,b,bdi,bdo,cite,code,data,dfn,em,i,kbd,mark,q,rp,rt,ruby,s,samp,small,span,strong,sub,sup,time,u,var,audio,map,video,iframe,object,canvas,noscript,script,del,ins,caption,colgroup,table,tbody,td,tfoot,th,thead,tr,button,datalist,fieldset,form,label,legend,meter,optgroup,option,output,progress,select,textarea,details,dialog,menu,menuitem,summary,content,decorator,element,shadow,template'.split(',').forEach (t) -> tags[t] = tag t

# self closing tags
'area,base,br,col,embed,hr,img,input,keygen,link,meta,param,source,track,wbr'.split(',').forEach (t) -> tags[t] = tag t, true

if typeof module == 'object'
    module.exports = tags
else if typeof define == 'function' and define.amd
    define -> tags
else
    this.tagg = tags
