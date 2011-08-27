db.teams.update({}, { $set: { 'entry.votable': false }}, false, true);
