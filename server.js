require('coffee-script');

[ 'login',
  'index',
  'iframe',
  'people',
  'judges',
  'teams',
  'deploys',
  'votes',
  'websocket',
  'redirect'
].forEach(function(controller) {
  require('./controllers/' + controller);
});
