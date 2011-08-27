module.exports = (app) ->
  Team = app.db.model 'Team'

  (req, res, next) ->
    if req.method is 'POST' and m = req.url.match /^\/teams\/(.+)\/commits$/
      console.log "#{req.method} #{req.url} - POST-COMMIT HOOK"
      code = m[1]
      Team.findOne code: code, (err, team) ->
        return next err if err
        return next 404 unless team
        try
          package = JSON.parse req.body.package
          for commit in package.commits
            app.events.emit 'commit', commit, team
        catch e
          return next e
        res.send 200
    else next()
