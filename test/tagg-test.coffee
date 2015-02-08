tagg = require '../src/tagg'
{html5, head, meta, body, ol, li, title, script, div, p, img, option} = tagg

eql = assert.deepEqual

describe 'elements', ->

    it 'renders an open/close element for no argument', ->
        eql p(), '<p></p>'

    it 'use objects as attributes', ->
        eql p({class:'foo', style:'background:black'}, 'data-blah':'panda'),
            '<p class="foo" style="background:black" data-blah="panda"></p>'

    it 'escapes &, < and " in attribute values', ->
        eql (p class:'_&pa"nda<!'), '<p class="_&amp;pa&quot;nda&lt;!"></p>'

    it 'escapes &, < and " in attribute names', ->
        eql (p '_&cl"ass<!':'panda'), '<p _&amp;cl&quot;ass&lt;!="panda"></p>'

    it 'is aware of boolean attributes which truthy renders without value', ->
        eql (option selected:'yes'), '<option selected></option>'

    it 'is aware of boolean attributes which falsey renders key/value', ->
        eql (option selected:''), '<option></option>'

    it 'is treats "html" as a boolean attribute', ->
        eql (img html:true), '<img html>'

    it 'uses string arguments as child text', ->
        eql p('panda'), '<p>panda</p>'

    it 'escapes & and < in child text', ->
        eql (p 'cute < panda & cats'), '<p>cute &lt; panda &amp; cats</p>'

    it 'leaves " be in child text', ->
        eql (p '"panda"'), '<p>"panda"</p>'

    it 'mixes objects and string arguments', ->
        eql p(class:'foo', 'panda'), '<p class="foo">panda</p>'

    it 'can take objects and strings in backwards order', ->
        eql p('panda', class:'foo'), '<p class="foo">panda</p>'

    it 'uses direct tags as children', ->
        eql div(p), '<div><p></p></div>'

    it 'uses wrapped tags as children', ->
        eql div(->p()), '<div><p></p></div>'

    it 'uses functions returning strings as child text nodes', ->
        eql p(->'panda'), '<p>panda</p>'

    it 'can mix classes and child funcs', ->
        eql div(class:'foo',p,style:'float:right',->p(class:'bar')),
            '<div class="foo" style="float:right"><p></p><p class="bar"></p></div>'

    it 'can mix strings and child funcs', ->
        eql div('pan',(->p('da')),'!'), '<div>pan<p>da</p>!</div>'

    it 'can mix child funcs and strings', ->
        eql div((->p('pan')),'da'), '<div><p>pan</p>da</div>'

    it 'can mix it all together', ->
        eql p('pan',class:'foo',(->p('da')),style:'float:right',(->p),'!'),
            '<p class="foo" style="float:right">pan<p>da</p><p></p>!</p>'

describe 'void elements', ->

    it 'renders no close tag', ->
        eql img(), '<img>'

    it 'renders objects as attributes', ->
        eql (img src:'/panda.jpg'), '<img src="/panda.jpg">'

    it 'are fine as direct elements', ->
        eql (p img), '<p><img></p>'

    it 'are fine as nested', ->
        eql (p ->img src:'/panda.jpg'), '<p><img src="/panda.jpg"></p>'

    it 'handles, albeit being awkward, having nested', ->
        eql (img src:'/panda.jpg', -> p 'panda'), '<img src="/panda.jpg"><p>panda</p>'

describe 'readme example', ->

    it 'is valid', ->
        pandas = [
            {src:'/panda1.jpg', desc:'Cute baby panda'}
            {src:'/panda2.jpg', desc:'Panda with straw'}
            {src:'/panda3.jpg', desc:'Sleeping panda'}
        ]
        h = html5 ->
            head ->
                meta charset:'utf-8'
                title 'Forever Panda'
                script src:'/js/jquery.min.js'
            body ->
                p 'Funny panda compilation, puppies & kitties:'
                ol ->
                    li (->img src:p.src), p.desc for p in pandas


        eql h, '<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>Forever Panda</title><script src="/js/jquery.min.js"></script></head><body><p>Funny panda compilation, puppies &amp; kitties:</p><ol><li><img src="/panda1.jpg">Cute baby panda</li><li><img src="/panda2.jpg">Panda with straw</li><li><img src="/panda3.jpg">Sleeping panda</li></ol></body></html>'
