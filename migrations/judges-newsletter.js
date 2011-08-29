db.people.find({ role: 'judge', email: /@/, twitterScreenName: /\w/ }).forEach(function(person) {
  print(person.email);
});
