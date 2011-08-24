db.services.find({}).sort({ name: 1 }).forEach(function(s) {
  print("\n## " + s.name + "\n");
  print(s.description.replace(/\n +/g, "\n"));
});
