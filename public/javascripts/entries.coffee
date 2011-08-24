load = ->
  $('#page.entries-edit').each ->
    $('#entryVotable')
      .change ->
        $('.votable .technical').toggle $(this).is(':checked')
        true
      .change()

$(load)
$(document).bind 'end.pjax', load
