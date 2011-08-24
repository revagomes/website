db.people.find({ role: 'judge', email: /@/ }).forEach(function(person) {
  print(person.email);
});
