tagg
====

> markup as coffeescript (again)

### Installing with NPM

```bash`
npm install -S tagg
```

Use destructuring assignment to pick out the wanted tags.

```
{div, p, img} = require 'tagg'

div class:'special', ->
    p 'some text', -> img(src:'/pic.jpg')

```

### Installing with Bower

```bash
bower install -S tagg
```

This exposes the global object `tagg`.

Use destructuring assignment to pick out the wanted tags.

```
{div, p, img} = tagg

div class:'special', ->
    p 'some text', -> img(src:'/pic.jpg')
```

Example
-------

We have a list of cute pandas:

```
pandas = [
    {src:'/panda1.jpg', desc:'Cute baby panda'}
    {src:'/panda2.jpg', desc:'Panda with straw'}
    {src:'/panda3.jpg', desc:'Sleeping panda'}
]
```

The following *pure coffeescript* code:

```
{html5, head, meta, title, script, body, p, ol, li, img} = require 'tagg'

html5 ->
    head ->
        meta charset:'utf-8'
        title 'Forever Panda'
        script src:'/js/jquery.min.js'
    body ->
        p 'Funny panda compilation, puppies & kitties:'
        ol ->
            li (->img src:p.src), p.desc for p in pandas
```

Generates this output:

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Forever Panda</title>
    <script src="/js/jquery.min.js"></script>
  </head>
  <body>
    <p>Funny panda compilation, puppies &amp; kitties:</p>
    <ol>
      <li><img src="/panda1.jpg">Cute baby panda</li>
      <li><img src="/panda2.jpg">Panda with straw</li>
      <li><img src="/panda3.jpg">Sleeping panda</li>
    </ol>
  </body>
</html>
```

## API

`[tag] a1, a2, a3, ...`

All tags work exactly the same.

### Arguments are objects, functions and strings

Tags takes a variadic argument list and does:

1. Any `object` argument `{k:v}` is treated as a tag attribute specification.
2. Any `function` argument `f` will be rendered as a child element.
3. Any `string` argument `s` will be wrapped `-> s` and treated as a function argument (2).

#### Order of attribute object is irrelevant

The arguments can be in any order. Attributes are (naturally) dealt
with first. It is entirely possible to do:

    p 'some text', class:'explicit'     # <p class="explicit">some text</p>

#### Order of functions/strings is preserved

Strings and functions are dealt with in the declared order:

      p 'some', ' ', (-> 'text'), ' ', (-> img(src:'/panda.jpg')), ' after'

Will render:

    '<p>some text <img src="/panda.jpg"> after</p>'

### Single render thread

When rendering with tagg, all output must be done in one go. No
setTimeout, no ajax, no callbacks.

    # THIS DOES NOT WORK!!!!
    p 'Waiting for ajax: ' ->
        $.ajax('/something').done(->'done')

### Make your own tag

Not happy with the builtins? Make your own!

The library exports a function `tag(name,isVoid)` which can be used to
make your own tags. Set `isVoid` to true to define a void element,
like `img`, that has no closing tag.

    {tag} = require 'tagg'
    special = tag 'special'

    special class:'sweet', 'thing'

Renders to:

    <special class="sweet">thing</special>

## Built ins

### Built in tags

The built in tags are taken from [mozilla element page](eleme) apart
from those listed as obsolote and deprecated. The full list is easiest
to see in [the source](tags).

#### Void elements

Tagg is aware of [void elements](void), like `<img>` and `<meta>` –
elements which do not need a close tag.

### Boolean attributes

Boolean attributes are those whose presence indicates a true value,
like `checked` in `<input type="checkbox" checked>`. Tagg has a built
in list of such attributes, and will not output any value for them.

The map value for such properties are used as truthy/falsey, i.e.

    input type:checkbox, checked:true
    select ->
        option selected:false, 'panda'
        option selected:'yes', 'kitten'

Will render:

    <input type="checkbox" checked>
    <select>
        <option>panda</option>
        <option selected>kitten</option>

#### Empty string is falsey

Notice that javascript defines empty string `""` as falsey, so (maybe
surprisingly) `input type:checkbox, checked:''` will output `<input type="checkbox">`

#### Not tag aware

Tagg does not keep track of which attribute belongs to which tag. So
(although it makes no semantic sense) `p checked:true` will render as
`<p checked>`.

License
-------

The MIT License (MIT)

Copyright © 2015 Martin Algesten

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[eleme]: https://developer.mozilla.org/en/docs/Web/HTML/Element
[tags]:  https://github.com/algesten/tagg/blob/master/src/tagg.coffee#L56
[attrs]: https://github.com/algesten/tagg/blob/master/src/tagg.coffee#L6
[void]:  http://stackoverflow.com/questions/3558119#answer-3558200
