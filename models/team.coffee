_ = require 'underscore'
mongoose = require 'mongoose'
rbytes = require 'rbytes'
querystring = require 'querystring'
request = require 'request'
util = require 'util'

InviteSchema = require './invite'
[Invite, Person, Deploy, Vote] = (mongoose.model m for m in ['Invite', 'Person', 'Deploy', 'Vote'])

TeamSchema = module.exports = new mongoose.Schema
  slug:
    type: String
    unique: true
  name:
    type: String
    required: true
    unique: true
  description: String
  entry:
    name: String
    url: String
    description: String
    instructions: String
    colophon: String
    votable:
      type: Boolean
      default: true
    technical: Boolean
  emails:
    type: [ mongoose.SchemaTypes.Email ]
    validate: [ ((v) -> v.length <= 4), 'max' ]
  invites: [ InviteSchema ]
  peopleIds:
    type: [ mongoose.Schema.ObjectId ]
    index: true
  lastDeploy: {}
  code:
    type: String
    default: -> rbytes.randomBytes(12).toString('base64')
  search: String
TeamSchema.plugin require('mongoose-types').useTimestamps
TeamSchema.index updatedAt: -1

# class methods
TeamSchema.static 'findBySlug', (slug, rest...) ->
  Team.findOne { slug: slug }, rest...
TeamSchema.static 'canRegister', (next) ->
  return next null, false, 0 # cut off team registration
  Team.count {}, (err, count) ->
    return next err if err
    max = 330 + 1 # +1 because team fortnight labs doesn't count
    next null, count < max, max - count
TeamSchema.static 'uniqueName', (name, next) ->
  Team.count { name: name }, (err, count) ->
    return next err if err
    next null, !count

# instance methods
TeamSchema.method 'toString', -> @slug or @id
TeamSchema.method 'includes', (person, code) ->
  @code == code or person and _.any @peopleIds, (id) -> id.equals(person.id)
TeamSchema.method 'invited', (invite) ->
  _.detect @invites, (i) -> i.code == invite

TeamSchema.method 'prettifyURL', ->
  return unless url = @entry.url
  r = request.get url, (error, response, body) =>
    throw error if error
    @entry.url = (if typeof(r.uri) is 'string' then r.uri else r.uri.href) or @entry.url
    @save()

TeamSchema.method 'updateScreenshot', (callback) ->
  return unless url = @entry.url
  qs = querystring.stringify url: url, expire: 1, resize: '160x93', 'out-format': 'png'
  r = request.get "http://pinkyurl.com/i?#{qs}", (error, response, body) ->
    throw error if error
    # no callback

# associations
TeamSchema.method 'people', (next) ->
  Person.find _id: { '$in': @peopleIds }, next
TeamSchema.method 'deploys', (next) ->
  Deploy.find teamId: @id, next
TeamSchema.method 'votes', (next) ->
  Vote.find teamId: @id, next

# validations

## min people
TeamSchema.pre 'save', (next) ->
  if @peopleIds.length + @emails.length == 0
    error = new mongoose.Document.ValidationError this
    error.errors.emails = 'min'
    next error
  else
    next()

## max teams
TeamSchema.pre 'save', (next) ->
  return next() unless @isNew
  Team.canRegister (err, yeah) =>
    return next err if err
    if yeah
      next()
    else
      error = new mongoose.Document.ValidationError this
      error.errors._base = 'max'
      next error

## unique name
TeamSchema.pre 'save', (next) ->
  return next() unless @isNew
  Team.uniqueName @name, (err, yeah) =>
    return next err if err
    if yeah
      next()
    else
      error = new mongoose.Document.ValidationError this
      error.errors.name = 'unique'
      next error

# callbacks

## create invites
TeamSchema.pre 'save', (next) ->
  for email in @emails
    unless _.detect(@invites, (i) -> i.email == email)
      @invites.push new Invite(email: email)
  _.invoke @invites, 'send'
  next()
TeamSchema.post 'save', ->
  for invite in @invites
    invite.remove() unless !invite or _.include(@emails, invite.email)
  @save() if @isModified 'invites'

## remove team members
TeamSchema.path('peopleIds').set (v) ->
  v.init = @peopleIds
  v
TeamSchema.pre 'save', (next) ->
  return next() unless @peopleIds.init
  toString = (i) -> i.toString()
  o = @peopleIds.init.map toString
  n = @peopleIds.map toString
  Person.remove role: 'contestant', _id: { $in: _.difference(o, n) }, next
TeamSchema.pre 'remove', (next) ->
  Person.remove role: 'contestant', _id: { $in: @peopleIds }, next

## search index
TeamSchema.pre 'save', (next) ->
  only = name: 1, location: 1, 'github.login': 1, 'twit.screenName': 1
  Person.find _id: { '$in': @peopleIds }, only, (err, people) =>
    return next err if err
    @search =
      """
      #{@name}
      #{@description}
      #{_.pluck(people, 'login').join(';')}
      #{_.pluck(people, 'location').join(';')}
      """
    next()

Team = mongoose.model 'Team', TeamSchema
