# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  # Adding the form fields behavior to the buttons on the nu collections.
$(document).ready ->

  tapasApp = (->
    init = (settings) ->
      tapasApp.config =
        removeFormFields:
          listener : false


      # allow overriding the default config
      $.extend tapasApp.config, settings
      setup()
      return

    setup = ->
      removeFormFields()
      formPages()


      return


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

    formPages = ( ) ->
      $('#add_another_author').addFormFields
        target: $('span.author:first-of-type')

      $('#add_another_contributor').addFormFields
        target: $('span.contributor:first-of-type')


    tapasAppError = ( message = 'Error:', value = null ) ->
      @.message = message
      @.value = value
      @.toString = ->
        message + '.  Value:' + value





    # these are the public API

    init: init
  )()

  #end tapasApp module;
  window.tapasApp = tapasApp
  tapasApp.init(
    updateUserviewPrefBoolean: false
  )
