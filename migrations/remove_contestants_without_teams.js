var memberIds = db.teams.distinct('peopleIds');
db.people.update(
  { _id: { $nin: memberIds } , role: 'contestant' },
  { $set: { role: null } }
, false, true);
