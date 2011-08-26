(function() {
	var $templates = {};
	$('.template').each(function(index) {
	    var $this = $(this);
	    $templates[$this.attr('id')] = $($this.html());
	    $this.remove();
	});

  $(document).bind('end.pjax', function(e, xhr, pjax) {
    if (ws) {
      ws.disconnect();
    }
    if (pjax.url === '/live' || pjax.url === '/') {
      connect();
    }
  });

  var ws;
  function connect() {
    if (window.location.pathname.indexOf('/live') === -1 && window.location.pathname !== '/') {
      return;
    }
    if (!ws) {
      ws = io.connect(null, {
        'port': '#socketIoPort#'
        , 'force new connection': true
      });
      ws.on('connect', function() {
        ws.emit('join', 'irc');
        ws.emit('join', 'twitter');
        ws.emit('join', 'github');
      });
      ws.on('irc', function(irc) {
        var $irc = $templates.irc.clone();
        if (irc.message.match(/ACTION/)) {
          $irc.find('.msg').text('*'+irc.from+' '+irc.message.replace(/ACTION/g, ''));
          $irc.find('.name').remove();
        } else {
          $irc.find('.msg').text(irc.message);
          $irc.find('.name').text(irc.from+':');
        }
        $('.irc-dashboard ul').prepend($irc);
        ircMessages.push($irc);
        if (irc.length > 30) {
          $.each(ircMessages.slice(0, ircMessages.length-30), function(index, $oldIrc) {
            $oldIrc.remove();
          });
          ircMessages = ircMessages.slice(ircMessages.length-30);
        }
      });
      ws.on('tweet', function(tweet) {
        addTweet(tweet, 'search');
      });
      ws.on('usertweet', function(tweet) {
        addTweet(tweet, 'user');
      });
      ws.on('commits', function(commits) {
        var $gitubContainer = $('.github-commits ul').empty();
        $.each(commits.teams, function(index, team) {
          var $team = $templates.team.clone();
          $team.find('.teamname').text(team.name).attr('href', '/teams/'+team.name).end()
            .find('.count').text(team.commits+' commits').end()
            .find('.progress').width(((team.commits/commits.max)*100)+'%').end()
            .find('.message').text(team.message);
          $gitubContainer.append($team);
        });
      });
    }
    // For some reason this fixes Uncaught Error: INVALID_STATE_ERR: DOM Exception 11
    setTimeout(function() {
      ws.socket.connect();
    }, 0);
  }
  connect();
  // Irc
  var ircMessages = [];

  // Twitter
  var tweets = {
    'search': []
    , 'user': []
  };

  function addTweet(tweet, container) {
    var $tweet = $templates.tweet.clone();
    $tweet.find('.msg').text(tweet.text).end()
    .find('.name').text(tweet.user.screen_name+':').attr('href', 'http://twitter.com/'+tweet.user.screen_name).end()
    .find('.avatar').attr('src', tweet.user.profile_image_url);

    $('.twitter-dashboard ul.'+container).prepend($tweet);

    var tweetsList = tweets[container];
    tweetsList.push($tweet);
    var maxCount = (container == 'search') ? 30 : 2;
    if (tweetsList.length > maxCount) {
      $.each(tweetsList.slice(0, tweetsList.length-maxCount), function(index, $oldTweet) {
        $oldTweet.remove();
      });
      tweetsList = tweetsList.slice(tweetsList.length-maxCount);
    }
  }

  $('#make-dashboard-fullscreen').live('click', function(event) {
    var $inner = $('#inner').toggleClass('fullscreen');
    $('body').toggleClass('fullscreen');
    if ($inner.is('.fullscreen')) {
      $(this).text('Minimize');
    } else {
      $(this).text('Fullscreen');
    }
  });

})();
