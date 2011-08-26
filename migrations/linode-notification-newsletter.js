db.teams.find({ linode: { $ne: null }}).forEach(function(team) {
  db.people.find(
      { _id: { $in: team.peopleIds }
      , email: { $ne: null }}).forEach(function(person) {

    var linode = team.linode;
    print([person.email, linode.username, linode.password].join(','));
  });
});
