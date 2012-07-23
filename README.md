# HOGAN-EXPRESS

Mustache template engine for express 3.x.

Supports
  - partials 
  - layout
  - caching

### Install

`npm install hogan-express`

### Usage

Setup:
```
app.set('view engine', 'html')
app.set('layout', 'layout') # rendering by default
app.set('partials', head: "head") # partails using by default on all pages
app.enable('view cache')
app.engine 'html', require('hogan-express')
```

Rendering template:
```
app.get '/', (req,res)->
  res.locals = what: 'World'
  res.render "index", partials: {temp: 'temp'}
```
(will render `layout.html` with `index.html`, `head.html` and `temp.html` partials)

### License
MIT License