'use strict'

# jshint undef: true, unused: true


# global $:false

# global Modernizr

# global ui

#global picturefill
$(document).ready ->

  tapasApp = (->
    init = (settings) ->
      tapasApp.config =
        $tapasBootstrapSelect: $('select.bs-select')
        removeFormFields:
          listener : false


      # allow overriding the default config
      $.extend tapasApp.config, settings
      setup()
      return

    setup = ->
      CoreFilesPage()
      CommunitiesPage()
      tooltipSetup()
      handleRequiredInputs()
      # ellipsisExpand()
      removeFormFields()
      # doSelectSubmit()
      # submenuMobileFix()
      # closeFacetMenu()

      return

    # this makes the per page and sort selectors automatically apply
    # doSelectSubmit = ->
    #   $(doSelectSubmit.selector).each ->
    #     select = $(this)
    #     select.bind "change", ->
    #       select.closest("form").submit()
    #       false
    #     return
    #   return
    #
    # doSelectSubmit.selector = "form select#sort, form select#per_page"

    # This is a fix for the submenus on mobile
    # submenuMobileFix = ->
    #   $(".dropdown-submenu").click (e) ->
    #     e.stopPropagation()
    #     $(this).siblings(".dropdown-submenu").removeClass('open')
    #     $(this).toggleClass('open')
    #     if $(this).hasClass('open')
    #       $(this).children('.dropdown-menu').show()
    #     else
    #       $(this).children('.dropdown-menu').hide()
    #     return
    #   $('.dropdown-submenu').mouseleave ->
    #     $(this).removeClass('open')
    #     $(this).children('.dropdown-menu').attr('style', '')
    #   return

    # This is to close the facet menu after the more button has been clicked
    # closeFacetMenu = ->
    #   $(".facets .more_facets_link").click (e) ->
    #     $(this).parents('.open').addClass('closed').removeClass('open');
    #   return

    ###
    Tooltip Setup
    ###
    tooltipSetup = ->
      $('a[data-toggle=tooltip]').tooltip container: 'body'
      return


    ###
    Builds interaction to inputs with [required="required"] to make sure that the user fills it out.
    ###
    handleRequiredInputs = ->

      #Query for inputs textareas and selects with require
      targets = $('input, textarea, select').filter('[required="required"]')

      #Construct the tooltips for inputs that need to be filled still.
      addTooltip = (e) ->
        $(e).tooltip title: 'Required'


      #cycle through each function.
      targets.each (index, el) ->
        id = $(el).attr('id')

        #add the required class.
        $('label[for="' + id + '"]').addClass 'required-label'

        # Check the element to figure out if we still need the tooltip or not.
        $(el).on 'focus hover click change keypress', ->
          if $(this).val().length > 0
            $(this).tooltip 'destroy'
          else
            addTooltip this
          return

        return

      return


    ###
    Looks for the datatoggle
    @return {[type]} [description]
    ###
    # ellipsisExpand = ->
    #   $toggleLink = $('*[data-toggle="ellipsis"]')
    #
    #   #look for the target and toggle classes on that element.
    #   toggleState = (event) ->
    #
    #     #stop the event from triggering other reations
    #     event.preventDefault()
    #     event.stopPropagation()
    #     $target = (if $(this).attr('href').length > 0 then $($(this).attr('href')) else $($(this).data('target')))
    #     if $target.length > 0
    #       $target = $target.find('.ellipsis')  unless $target.hasClass('ellipsis')
    #       $target.toggleClass 'in'
    #       $(this).children('i').toggleClass('icon-expand-alt').toggleClass 'icon-collapse-alt'
    #     else
    #       console.log 'Invalid target specified for tapasApp.ellipsisExpand', $target
    #     return
    #
    #   $toggleLink.on 'click', toggleState
    #   return


    #Handles spawning new permission related form elements on the core_files/new page.
    CoreFilesPage = ->
      # Adding the form fields behavior to the buttons on the core_files.

      $('#add_another_contributor').addFormFields
        target: $('span.contributor:not(.to-remove)')
        titleText: 'Remove contributor'

      $('#add_another_author').addFormFields
        target: $('span.author:not(.to-remove)')
        titleText: 'Remove author'

      $('#add_another_collection').addFormFields
        target: $('span.collection:not(.to-remove)')
        titleText: 'Remove collection'

      # TODO: (charles) possible quick and dirty way to autocomplete users when creating a record
      # $('.core_file_authors').autocomplete
      #   source: $('#core_file_authors').data('autocomplete-source')

      return


    #Handles spawning new permission related form elements on the communities/new and edit page.
    CommunitiesPage = ->
      # Adding the form fields behavior to the buttons on the communities.

      $('#add_another_project_member').addFormFields
        target: $('span.project_member:not(.to-remove)')
        titleText: 'Remove member'

      $('#add_another_project_editor').addFormFields
        target: $('span.project_editor:not(.to-remove)')
        titleText: 'Remove editor'

      $('#add_another_project_admin').addFormFields
        target: $('span.project_admin:not(.to-remove)')
        titleText: 'Remove admin'

      $('#add_another_institution').addFormFields
        target: $('span.institution:not(.to-remove)')
        titleText: 'Remove admin'

      return



    ###
    Show model using the #ajax-modal on created at the bottom of every page.
    ###
    initModal = ( heading = "Modal", body ="Hello World", footer = false,  show = true ) ->
      t = $('#ajax-modal')
      t.find('#ajax-modal-heading').text(heading)
      t.find('#ajax-modal-body').html(body)
      if footer
        t.find('#ajax-modal-footer').html(footer)
      else
        t.find('#ajax-modal-footer').hide()
      t.modal({
        'show' : show
        })
      clear = ->
        t.find('#ajax-modal-heading').text('')
        t.find('#ajax-modal-body').html('')
        t.find('#ajax-modal-footer').html('').css('display', 'block')
        t.off('hidden')
      reloadWindow = ->
        window.location.reload()
      listenForAjax = ( element ) ->
        $( element ).on('ajax:complete', reloadWindow )

      # We shouldn't need to do this but there isn't a great way of updating the DOM and keeping the data in sync with the app.
      hanldleRemoteLinks = ->
        remoteLinks = t.find( 'a[data-remote]' )
        listenForAjax link for link in remoteLinks
      hanldleRemoteLinks()
      t.on('hidden', clear)


    # Handle remove form field buttons click
    #
    #  <div class="control-group" id="controlGroup1">
    #    <label for="">email</label>
    #    <input type="email" id="email-field">
    #    <button type="button" data-delete data-target=".control-group">Delete Field</button>
    #  </div>
    #  This markup will cause the removal of the contain div, so you would need to place the element
    #  with the markup in a container element, or the function is smart enough to find a specific jQuery selector and delete that selector and itself.
    #  General yet specific


    removeFormFields = ( ) ->

      handleClick = (e) ->
          $el = $(@)
          e.preventDefault()
          removeSelector = $el.data('target')
          unless removeSelector?
             removeSelector = $el.attr('href')

          # This is vague to allow class selectors of containing divs
          $remove = $el.closest( removeSelector ).first()

          #if this remove variable is still null then let's make sure it is specific to only one item
          if $remove.length == 0
            $remove = if  $( removeSelector ).length is 1 then $( removeSelector ) else null

          if $remove?
            # make sure to remove the element itself
            $el.remove()
            $remove.empty().remove()
          else
            throw new tapasAppError "Couldn't find specific target or parent element to remove." , removeSelector
      if tapasApp.config.removeFormFields.listener
        $('*[data-delete ]').on('click', handleClick )
      else
        $('body').on('click', '*[data-delete]' , handleClick )


    ##tapasAppError Class for debugging
    tapasAppError = ( message = 'Error:', value = null ) ->
      @.message = message
      @.value = value
      @.toString = ->
        message + '.  Value:' + value





    # these are the public API

    init: init
    initModal: initModal
  )()

  #end tapasApp module;
  window.tapasApp = tapasApp
  tapasApp.init(
    # updateUserviewPrefBoolean: false
  )
