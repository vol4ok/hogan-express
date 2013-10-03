express = require 'express'

app = module.exports = express()
hogan = require("hogan.js")
_ = require("underscore")

app.set('view engine', 'html')
app.set('layout', 'layout')
app.set('partials', head: "head")

#app.enable('view cache')

app.engine 'html', require('../hogan-express.coffee')
app.set('views', __dirname + '/views')

app.use(express.bodyParser())
app.use(app.router)

app.get '/', (req,res)->
  res.locals = what: 'World'

  res.locals.data = "default data"

  res.render "index",
    list: [ {title: "first", data: "custom data"}, {title: "Second"}, {title: "third"} ]
    partials: {temp: 'temp'}

    reverseString: ->
      context = @
      return (text) ->
        ctx= {}
        ctx= _.extend(ctx, res.locals, context)
        return hogan.compile(text).render(ctx).split("").reverse().join("")

app.listen(4020)
