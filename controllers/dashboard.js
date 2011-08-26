var env = require('../config/env');

module.exports = function(app) {
  var io = app.ws;
  io.sockets.on('connection', function(client) {
    client.on('join', function(room){
      client.join(room);
      // If the user wants to get twitter messages we also want to send
      // the @node_knockout ones separate
      if (room === 'twitter') {
        client.join('usertwitter');
      }
      switch(room) {
        case 'irc':
          setupIrc(client);
          break;
        case 'twitter':
          setupTwitter(client);
          break;
        case 'github':
          setupGithub(client);
          break;
      }
    });
  });

  // IRC
  var setupIrc = (function() {
    if (!env.irc) {
      return false;
    }
    var irc = require('irc');
    var ircClient = new irc.Client(env.irc.server, env.irc.username, {
      'channels': env.irc.channels
    });
    ircClient.addListener('message', function (from, to, message) {
      var ircMessage = {'from': from, 'message': message};
      backlog.add(ircMessage);
      io.sockets.to('irc').emit('irc', ircMessage);
    });
    var backlog = new Backlog('irc', 30);
    return function(client) {
      backlog.getAll().forEach(function(irc) {
        client.emit('irc', irc);
      });
    };
  })();

  // Twitter
  var setupTwitter = (function() {
    if (!env.secrets.twitterUser) {
      return false;
    }
    var TwitterNode = require('twitter-node').TwitterNode;
    
    var stickyUser = '148922824'; // @node_knockout

    var searchBacklog = new Backlog('twitter', 30);
    var userBacklog = new Backlog('usertwitter', 2);
    var twitterSearchStream = new TwitterNode({
      'user': env.secrets.twitterUser.user
      , 'password': env.secrets.twitterUser.password
      , 'track': ['nko', 'nodeknockout']
      , 'follow': [stickyUser]
    });
    
    twitterSearchStream.on('tweet', function(tweet) {
      if (tweet.user.id_str === stickyUser) {
        userBacklog.add(tweet);
        io.sockets.to('usertwitter').emit('usertweet', tweet);
      } else {
        searchBacklog.add(tweet);
        io.sockets.to('twitter').emit('tweet', tweet);
      }
    });
    twitterSearchStream.on('error', function() {});
    twitterSearchStream.stream();

    return function(client) {
      searchBacklog.getAll().forEach(function(tweet) {
        client.emit('tweet', tweet);
      });
      userBacklog.getAll().forEach(function(tweet) {
        client.emit('usertweet', tweet);
      });
    };
  })();

  // Github
  var setupGithub = (function() {
    var backlog = new Backlog(30);

    var teamData = [ 'team1', 'team2', 'team3' ];
    var dummy = ['commit msg #1','commit msg #2','commit msg #3','commit msg #4'];

    function getGithubTeamData() {
      var teams = [];
      teamData.forEach(function(name) {
        teams.push({
          'name': name
          , 'commits': 0 | Math.random()* 236
          , 'message': dummy[Math.floor(Math.random()*dummy.length)]
        });
      });

      var max = 0;
      teams = teams.sort(function(a,b) {
        max = Math.max(max, a.commits);
        return b.commits - a.commits;
      }).slice(0,30);

      var github = {
        'max': max
        , 'teams': teams
      };
      return github;
    }
    
    //setInterval(function() {
    //  io.sockets.to('github').emit('commits', getGithubTeamData());
    //}, 1000);
    return function(client) {
      client.emit('commits', getGithubTeamData());
    };
  })();
}

var redis = require('redis');
var redisClient = redis.createClient();
var Backlog = function(key, maxCount) {
  key = 'dashboard-'+key;
  
  var cache = [];
  redisClient.get(key, function(err, result) {
    if (result) {
      cache = JSON.parse(result);
    }
	});
  return {
    'getAll': function() {
      return cache;
    }
    , 'add': function(data) {
      cache.push(data);
      if (cache.length > maxCount) {
        cache = cache.slice(cache.length-maxCount);
      };
			redisClient.set(key, JSON.stringify(cache));
    }
  }
};