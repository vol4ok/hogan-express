###!
 * Copyright (c) 2012 Andrew Volkov <hello@vol4ok.net>
###

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
    # Remove potential UTF Byte Order Mark
    str = str.replace(/^\uFEFF/, '')
    cache[path] = str if (options.cache)
    fn(null, str)

renderPartials = (partials, opt, fn) ->
  count = 1
  result = {}
  for name, path of partials
    continue unless typeof path is 'string'
    path += ctx.ext unless $.extname(path) 
    path = ctx.lookup(path)
    count++
    read path, opt, ((name, path) ->
        return (err, str) ->
          return unless count
          if err
            count = 0
            fn(err)
          result[name] = str
          fn(null, result) unless --count
      )(name, path)
  fn(null, result) unless --count

renderLayout = (path, opt, fn) ->
  return fn(null, false) unless path
  path += ctx.ext unless $.extname(path) 
  path = ctx.lookup(path)
  return fn(null, false) unless path
  read path, opt, (err, str) ->
    return fn(err) if (err)
    fn(null, str)

customContent = (str, tag, opt, partials) ->
  oTag = "{{##{tag}}}"
  cTag = "{{/#{tag}}}"
  text = str.substring(str.indexOf(oTag) + oTag.length, str.indexOf(cTag))
  hogan.compile(text, opt).render(opt, partials)

render = (path, opt, fn) ->
  ctx = this
  partials = opt.settings.partials or {}
  partials = partials extends opt.partials if opt.partials

  lambdas = opt.settings.lambdas or {}
  lambdas = lambdas extends opt.lambdas if opt.lambdas
  # get rid of junk from "extends" - make it a normal object again
  delete lambdas['prototype']
  delete lambdas['__super__']

  # create the lambdafied functions
  # this way of dealing with lambdas assumes you'll want
  # to call your function on the rendered content instead
  # of the original template string
  opt.lambdas = {}
  for name, lambda of lambdas
    do (name, lambda) ->
      opt.lambdas[name] = ->
        lcontext = @
        return (text) ->
          # getting the context right here is important
          # it must account for "locals" and values in the current context
          #  ... particually interesting when applying within a list
          lctx= {}
          lctx = lctx extends opt._locals if opt._locals
          lctx = lctx extends lcontext
          return lambda(hogan.compile(text).render(lctx))

  renderPartials partials, opt, (err, partials) ->
    return fn(err) if (err)
    layout = if opt.layout is undefined
      opt.settings.layout
    else
      layout = opt.layout
    renderLayout layout, opt, (err, layout) ->
      read path, opt, (err, str) ->
        return fn(err) if (err)
        try
          tmpl = hogan.compile(str, opt)
          result = tmpl.render(opt, partials)
          customTags = str.match(/({{#yield-\w+}})/g)
          yields = {}
          if customTags
            for customTag in customTags
              tag = customTag.match(/{{#([\w-]+)}}/)[1]
              if tag
                if layout
                  opt[tag] = customContent(str, tag, opt, partials)
                else
                  yields[tag.replace('yield-', '')] = customContent(str, tag, opt, partials)
          if layout
            opt.yield = result
            tmpl = hogan.compile(layout, opt)
            result = tmpl.render(opt, partials)
            return fn(null, result)
          return fn(null, result, yields)
        catch err
          fn(err)

module.exports = render
