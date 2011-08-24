db.teams.find({}, {name: 1}).forEach(function(t) {
  var name = t.name
    , slug = generateSlug(name);
  print(slug, '<-', name);
  db.teams.update({_id: t._id}, {$set: {slug: slug}});
});

function generateSlug(s) {
  return s
    .toLowerCase()
    .replace(/[^-a-z0-9]+/g, '-')
    .replace(/^-/, '')
    .substring(0, 20)  // arbitrarily below heroku's 30 limit
    .replace(/-$/, '');
}
