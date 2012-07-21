# HOGAN-EXPRESS

Mustache template engine for express 3.x.

Supports
  - partials 
  - layout
  - caching

### Usage

Setup:
```
  app.set('layout', 'layout')
  app.set('partials', head: "head")
  app.enable('view cache')
```

Rendering template:
```
app.get '/', (req,res)->
  res.locals = what: 'World'
  res.render "index", partials: {temp: 'temp'}
```
