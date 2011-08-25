app = require '../config/app'
Team = app.db.model 'Team'
Person = app.db.model 'Person'
Service = app.db.model 'Service'
Vote = app.db.model 'Vote'
m = require './middleware'

# middleware
loadCurrentPersonWithTeam = (req, res, next) ->
  return next() unless req.person
  req.user.team (err, team) ->
    return next err if err
    req.team = team
    next()
loadCanRegister = (req, res, next) ->
  Team.canRegister (err, canRegister, left) ->
    return next err if err
    req.canRegister = canRegister
    req.teamsLeft = left
    next()

app.get '/', [loadCurrentPersonWithTeam, loadCanRegister], (req, res) ->
  res.render2 'index/index',
    team: req.team
    canRegister: req.canRegister
    teamsLeft: req.teamsLeft

['how-to-win', 'locations', 'prizes', 'rules', 'sponsors', 'scoring'].forEach (p) ->
  app.get '/' + p, (req, res) -> res.render2 "index/#{p}"

app.get '/about', (req, res) ->
  Team.count {}, (err, teams) ->
    return next err if err
    Person.count { role: 'contestant' }, (err, people) ->
      return next err if err
      res.render2 'index/about',
        teams: teams - 1   # compensate for team fortnight
        people: people - 4

app.get '/judging', (req, res) ->
  res.redirect '/judges/new'

app.get '/now', (req, res) ->
  res.end Date.now().toString()

app.get '/services', [m.ensureAuth], (req, res, next) ->
  return next 401 unless req.user.contestant or req.user.admin
  Service.sorted (error, services) ->
    next error if error
    res.render2 'index/services', services: services

app.get '/iframe/:teamId/authed', [m.loadTeam, m.loadMyVote], (req, res) ->
  res.render 'index/iframe-authed', layout: false, vote: req.vote

app.get '/iframe/:teamId', [m.loadTeam, m.loadMyVote], (req, res) ->
  css = req.query.css if /^https?:\/\//.test(req.query.css)
  Vote.count teamId: req.team._id, type: 'voter', (err, count) ->
    next err if err
    res.render 'index/iframe', layout: false, vote: req.vote, count: count, css: css
