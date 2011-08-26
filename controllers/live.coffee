app = require '../config/app'

# index
app.get /^\/live\/?$/, (req, res, next) ->
  res.render2 'live'
