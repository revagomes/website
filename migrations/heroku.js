db.teams.find().forEach(function(t) {
  //print('nko2-' + t.slug);
  db.people.distinct('email', {_id: {$in: t.peopleIds}}).forEach(function(e) {
    print('echo heroku sharing:add', e, '--app nko2-' + t.slug);
    print('heroku sharing:add', e, '--app nko2-' + t.slug);
  });
});
