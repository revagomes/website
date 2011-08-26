var slugs = {};
var dupes = {};

db.people.find({ $or : [ { 'twit.screenName' : { $exists : true } } , { 'github.login' : { $exists : true } } ] },
               {'name': 1, 'twit.screenName': 1, 'github.login': 1}).forEach(function(p) {
  var slug = ((p.twit && p.twit.screenName) || (p.github && p.github.login)).toLowerCase();
  if (slugs[slug]) {
    slugs[slug].push(p._id);
    dupes[slug] = slugs[slug];
    slug = p._id;
  } else {
    slugs[slug] = [p._id];
    db.people.update({_id: p._id}, {$set: {slug: slug}});
    print(slug, '<-', p.name);
  }
});

print('--- dupes ---');
printjson(dupes);
