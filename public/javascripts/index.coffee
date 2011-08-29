load = ->
  # countdown
  $('time:first').each ->
    $.get '/now', (data) ->
      serverLoadTime = new Date parseInt data
      localLoadTime = new Date
      parts = $(this).attr('datetime').split(/[-:TZ]/)
      parts[1]--; # js dates :( js dates are hot dates.
      start = Date.UTC.apply null, parts

      $('#countdown').each ->
        $this = $(this)
        append = $(this).text()

        pluralize = (count, str) ->
          count + ' ' + str + (if parseInt(count) != 1 then 's ' else ' ')

        names = ['hour', 'minute', 'second']
        do tick = ->
          secs = ((start - serverLoadTime) - (new Date - localLoadTime)) / 1000
          if secs > 0
            parts = [secs / 3600, secs % 3600 / 60, secs % 60]
            $this.html null
            $.each parts, (i, num) ->
              $this.append pluralize(Math.floor(num), names[i])
            $this.append append if append
            setTimeout tick, 800
          else
            $this.html $('<h1>STOPSTOPSTOP</h1>')

$(load)
$(document).bind 'end.pjax', load
