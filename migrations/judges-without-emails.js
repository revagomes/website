db.people.find({ role: 'judge', email: { $not: /@/ }}).forEach(function(person) {
  print(person.name + " " + person.twitterScreenName);
});
