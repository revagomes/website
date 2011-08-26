printjson(db.teams.find({ slug: /\w/ }, { slug: 1, code: 1 }).map(function(team) {
  return {
    repo: 'nko2/' + team.slug,
    hook: 'http://nodeknockout.com/teams/' + encodeURIComponent(team.code) + '/commits'
  };
}));
