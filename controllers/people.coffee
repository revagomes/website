_ = require 'underscore'
app = require '../config/app'
m = require './middleware'
Person = app.db.model 'Person'
Team = app.db.model 'Team'

# index
app.get '/people', (req, res, next) ->
  Person.find {name: {$ne: null}}, {}, {sort: [['github.followersCount', -1]]}, (err, people) ->
    return next err if err
    res.render2 'people', people: people

# new
app.get '/people/new', [m.ensureAdmin], (req, res, next) ->
  res.render2 'people/new', person: new Person

# create
app.post '/people', [m.ensureAdmin], (req, res) ->
  person = new Person req.body
  person.save (err) ->
    if err
      res.render2 'people/new', person: person
    else
      res.redirect "people/#{person}"

# me
app.get '/people/me(\/edit)?', [m.ensureAuth], (req, res, next) ->
  res.redirect "/people/#{req.user.id}#{req.params[0] || ''}"

# show
app.get '/people/:id', [m.loadPerson, m.loadPersonTeam, m.loadPersonVotes], (req, res, next) ->
  res.render2 'people/show',
    person: req.person
    team: req.team
    votes: req.votes

# edit
app.get '/people/:id/edit', [m.loadPerson, m.ensureAccess], (req, res, next) ->
  res.render2 'people/edit', person: req.person

# update
app.put '/people/:id', [m.loadPerson, m.ensureAccess], (req, res) ->
  unless req.user.admin
    delete req.body[attr] for attr in ['role', 'admin', 'technical']
  _.extend req.person, req.body
  req.person.save (err) ->
    return next err if err && err.name != 'ValidationError'
    if req.person.errors
      res.render2 'people/edit', person: req.person
    else
      res.redirect "/people/#{req.person}"

# delete
app.delete '/people/:id', [m.loadPerson, m.ensureAccess], (req, res, next) ->
  req.person.remove (err) ->
    return next err if err
    res.redirect '/'
