# pjax
$('a[href^="/"]').live 'click', (e) ->
  return if e.metaKey or e.ctrlKey
  href = $(this).attr('href')
  return if href.match(new RegExp('^/(auth|login/|logout)')) # login, logout
  e.preventDefault()
  $.pjax
    url: href
    container: '#inner'
    fragment: '#inner'
    timeout: 2222
    success: ->
      if $('#inner nav').offset().top < $(window).scrollTop()
        $(window).scrollTop 0

$(document).bind 'pjax', (e, xhr, options) ->
  $('#inner').addClass('pjax')
  xhr.success (html) ->
    $('#inner').removeClass('pjax')
    wrapper = $('<div>')
    wrapper.get(0).innerHTML = html
    $('#page').prop('class', wrapper.find('#page').attr('class'))
    document.title = wrapper.find('title').text() || document.title

# ensure csrf token is included in all ajax requests
# from https://github.com/rails/jquery-ujs/blob/master/src/rails.js
$.ajaxPrefilter (options, originalOptions, xhr) ->
  token = $('meta[name="_csrf"]').attr('content')
  xhr.setRequestHeader 'X-CSRF-Token', token

# speed up default jQuery animations
$.fx.speeds._default = 200

load = ->
  $(':text:first').focus() # focus first input

  $('#page.teams-edit, #page.people-edit').each ->
    $('a.remove', this).click ->
      $this = $(this)
      pos = $this.position()
      form = $('form.delete')
      form
        .fadeIn('fast')
        .css
          left: pos.left + ($this.width() - form.outerWidth())/2
          top: pos.top + ($this.height() - form.outerHeight())/2
      false

    $('form.delete a', this).click ->
      $(this).closest('form').fadeOut('fast')
      false

  requestAt = Date.now()
  hoverAt = null
  $('form.vote')
    .hover (e) ->
      hoverAt or= Date.now()
    .submit (e) ->
      $this = $(this)
        .find('input[type=hidden].hoverAt').val(hoverAt).end()
        .find('input[type=hidden].requestAt').val(requestAt).end()
      if $this.find('div.stars:has(.star.filled)').length < 4
        alert 'All ratings must have at least 1 star.'
        false
      else true
    .delegate 'a.change', 'click', (e) ->
      e.preventDefault()
      $form = $(this).closest('form').toggleClass('view edit')
      $form[0].reset()
      $('input, textarea', $form)
        .change() # reset stars
        .prop('disabled', $form.is('.view'))
    .find('input[type=range]').stars()

$(load)
$(document).bind 'end.pjax', load
