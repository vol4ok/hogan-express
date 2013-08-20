# HOGAN-EXPRESS

Mustache template engine for express 3.x. 

Use twitter's [hogan.js](https://github.com/twitter/hogan.js) engine.

Supports
  - partials 
  - layout
  - caching

### Install

`npm install hogan-express`

### Usage

**Setup**:
```
app.set('view engine', 'html')
app.set('layout', 'layout') # rendering by default
app.set('partials', head: "head") # partails using by default on all pages
app.enable('view cache')
app.engine 'html', require('hogan-express')
```
----
**Rendering template**:
```
app.get '/', (req,res)->
  res.locals = what: 'World'
  res.render "index", partials: {temp: 'temp'}
```
(will render `layout.html` with `index.html`, `head.html` and `temp.html` partials)

`{{{ yield }}}` variable in template means the place where your page are rendered inside the layout.

----
**Custom yield tags**:

You can define more extension points in `layout.html` using custom tags ``{{yield-<name>}}``:

layout:

```
<head>
	...
	{{{yield-styles}}}
	{{{yield-scripts}}}
</head>
```
index:

```
{{#yield-styles}}
	<style>
		...
	</style>
{{/yield-styles}}

{{#yield-scripts}}
	<script>
		...
	</script>
{{/yield-scripts}}
```

Page `idnex.html` will be rendered into ``{{yield}}`` without content of ``{{#yield-styles}}...{{/yield-styles}``
and ``{{#yield-scripts}}...{{/yield-scripts}}``. That content goes into accordingly named tags in `layout.html`.
If ``{{{yield-styles}}}`` is missing, styles tag content will not be rendered.

----
**Custom layout**:


For render page with custom layout, just specify it in options `res.render "admin.html", layout: "admin-layout"`

### License
MIT License
