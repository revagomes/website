db.people.find({ role: { $in: ['judge', 'contestant'] }, email: /@/ }).forEach(function(person) {
  print(person.email);
});
