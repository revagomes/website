db.people.find({ role: 'judge', twitterScreenName: { $not: /\w/ }}).forEach(function(person) {
  print(person.name + " <" + person.email + ">");
});
