#require "colors"
$ = {}
$ extends require 'fs'
$ extends require 'util'
$ extends require 'path'
hogan = require 'hogan.js'

cache = {}
ctx = {}

read = (path, options, fn) ->
  str = cache[path]
  return fn(null, str) if (options.cache and str)
  $.readFile path, 'utf8', (err, str) ->
    return fn(err) if (err)
    cache[path] = str if (options.cache)
    fn(null, str)

render_partials = (partials, opt, fn) ->
  #console.log partials
  count = 1
  result = {}
  for name, path of partials
    continue unless typeof path is 'string'
    path += ctx.ext unless $.extname(path) 
    path = ctx.lookup(path)
    count++
    #console.log "count++: ".yellow, count, name, path
    read path, opt, ((name, path) ->
        return (err, str) ->
          return unless count
          if err
            count = 0
            fn(err)
          #console.log "count--: ".green, count, name, path
          result[name] = str
          fn(null, result) unless --count
      )(name, path)
  fn(null, result) if --count

render_layout = (path, opt, fn) ->
  return fn(null, false) unless path
  path += ctx.ext unless $.extname(path) 
  path = ctx.lookup(path)
  return fn(null, false) unless path
  read path, opt, (err, str) ->
    return fn(err) if (err)
    fn(null, str)

render = (path, opt, fn) ->
  ctx = this
  #console.log $.inspect(opt, no, 0, yes)
  partials = opt.settings.partials or {}
  partials = partials extends opt.partials if opt.partials
  render_partials partials, opt, (err, partials) ->
    #console.log 'partials '.cyan, partials
    return fn(err) if (err)
    render_layout opt.layout or opt.settings.layout, opt, (err, layout) ->
      #console.log 'layout '.cyan, layout
      read path, opt, (err, str) ->
        #console.log 'body '.cyan, str
        return fn(err) if (err)
        try
          tmpl = if layout
            partials.yield = str
            hogan.compile(layout, opt)
          else
            hogan.compile(str, opt)
          fn(null, tmpl.render(opt.locals, partials))
        catch err
          fn(err)

module.exports = render