var slugs = {};
var dupes = [];

db.people.find({ $or : [ { 'twit.screenName' : { $exists : true } } , { 'github.login' : { $exists : true } } ] },
               {'name': 1, 'twit.screenName': 1, 'github.login': 1}).forEach(function(p) {
  var slug = ((p.twit && p.twit.screenName) || (p.github && p.github.login)).toLowerCase();
  if (slugs[slug]) {
    print(slug);
    dupes.push({'_id':p._id, slug: slug});
    slug = p._id;
  } else {
    slugs[slug] = 1;
  }
  print(slug, '<-', p.name);
  db.people.update({_id: p._id}, {$set: {slug: slug}});
});

print('--- dupes ---');

dupes.forEach(function (dupe) {
  print(dupe._id, ':', dupe.slug);
});
