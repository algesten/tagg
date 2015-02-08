tagg = require '../src/tagg'
{div, p, img} = tagg

eql = assert.deepEqual

describe 'normal elements', ->

    it 'renders an open/close element for no argument', ->
        eql p(), '<p></p>'

    it 'use objects as attributes', ->
        eql p({class:'foo', style:'background:black'}, 'data-blah':'panda'),
            '<p class="foo" style="background:black" data-blah="panda"></p>'

    it 'escapes &, < and " in attribute values', ->
        eql (p class:'_&pa"nda<!'), '<p class="_&amp;pa&quot;nda&lt;!"></p>'

    it 'escapes &, < and " in attribute names', ->
        eql (p '_&cl"ass<!':'panda'), '<p _&amp;cl&quot;ass&lt;!="panda"></p>'

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
