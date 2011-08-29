app = require '../config/app'
Vote = app.db.model 'Vote'
m = require './middleware'

app.get '/iframe/:teamId', [m.loadTeam, m.loadMyVote], (req, res) ->
  css = req.query.css if /^https?:\/\//.test(req.query.css)
  req.vote = null unless req.user?.voter
  Vote.count teamId: req.team._id, type: 'voter', (err, count) ->
    next err if err
    res.render 'iframe', layout: false, vote: req.vote, count: count, css: css

app.get '/iframe/:teamId/authed', [m.loadTeam, m.loadMyVote], (req, res) ->
  res.render 'iframe/authed', layout: false, vote: req.vote

app.get '/iframe/:teamId/test', (req, res) ->
  res.render 'iframe/test', layout: false
