module.exports = (app) ->
  Team = app.db.model 'Team'

  (req, res, next) ->
    if req.method is 'POST' and m = req.url.match /^\/teams\/(.+)\/commits$/
      code = m[1]
      Team.findOne code: code, (err, team) ->
        return next err if err
        return next 404 unless team
        console.log req.body
        app.events.emit 'commit', req.body
        res.send 200
    else next()
