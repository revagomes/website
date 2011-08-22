load = ->
  $('#page.projects-edit').each ->
    $('#projectVotable')
      .change ->
        $('.votable .technical').toggle $(this).is(':checked')
        true
      .change()

$(load)
$(document).bind 'end.pjax', load
