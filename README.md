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

## Details

### Built in tags

The built in tags are taken from [mozilla element page](eleme) apart
from those listed as obsolote and deprecated. 


[eleme]: https://developer.mozilla.org/en/docs/Web/HTML/Element
