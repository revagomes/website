qs = require 'querystring'
app = require '../config/app'
[Person, Team, Vote] = (app.db.model m for m in ['Person', 'Team', 'Vote'])

ensureAuth = (req, res, next) ->
  return res.redirect "/login?returnTo=#{encodeURIComponent(req.url)}" unless req.loggedIn
  next()

module.exports =
  ensureAuth: ensureAuth

  ensureAccess: (req, res, next) ->
    return next() if req.team? and req.team.includes(null, req.session.team)
    ensureAuth req, res, ->
      unless req.user.admin
        return next 401 if req.person? and req.person.id isnt req.user.id
        return next 401 if req.team? and not req.team.includes(req.user, req.session.team)
        return next 401 if req.vote? and req.vote.personId.toString() isnt req.user.id
      next()

  ensureAdmin: (req, res, next) ->
    ensureAuth req, res, ->
      return next 401 unless req.user.admin
      next()

  loadPerson: (req, res, next) ->
    if id = req.params.personId or req.params.id
      Person.findById id, (err, person) ->
        return next err if err
        return next 404 unless person
        req.person = person
        next()
    else
      req.person = req.user
      next()

  loadPersonTeam: (req, res, next) ->
    return next() unless req.person
    req.person.team (err, team) ->
      return next err if err
      req.team = team
      next()

  loadPersonVotes: (req, res, next) ->
    return next() unless req.person
    req.person.votes (err, votes) ->
      return next err if err
      req.votes = votes
      Vote.teams votes, next

  loadTeam: (req, res, next) ->
    if id = req.params.teamId or req.params.id
      findBy = if /^[0-9a-fA-F]{24}$/.test(id) then 'findById' else 'findBySlug'
      Team[findBy] id, (err, team) ->
        return next err if err && err.message != 'Invalid ObjectId'
        return next 404 unless team
        req.team = team
        next()
    else if code = req.params.code
      code = qs.unescape(code)
      Team.findOne code: code, (err, team) ->
        return next err if err
        return next 404 unless team
        req.team = team
        next()
    else
      next()

  loadTeamPeople: (req, res, next) ->
    req.team.people (err, people) ->
      return next err if err
      req.people = people
      next()

  loadTeamVotes: (req, res, next) ->
    req.team.votes (err, votes) ->
      return next err if err
      req.votes = votes
      Vote.people votes, next

  loadMyVote: (req, res, next) ->
    return next() unless req.user?
    Vote.findOne { teamId: req.team.id, personId: req.user.id }, (err, vote) ->
      return next err if err
      req.vote = vote
      next()

  loadVote: (req, res, next) ->
    if id = req.params.voteId or req.params.id
      Vote.findById id, (err, vote) ->
        return next err if err
        return next 404 unless vote
        req.vote = vote
        next()
    else
      next()
