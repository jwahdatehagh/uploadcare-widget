{
  namespace,
  ui: {progress: {Circle}},
  jQuery: $
} = uploadcare

namespace 'uploadcare.widget.tabs', (ns) ->
  class ns.BasePreviewTab

    PREFIX = '@uploadcare-dialog-preview-'

    constructor: (@container, @tabButton, @dialogApi, @settings) ->
      @__initTabButtonCircle()

      notDisabled = ':not(.uploadcare-disabled-el)'
      @container.on('click', PREFIX + 'back' + notDisabled, =>
        @dialogApi.fileColl.clear())
      @container.on('click', PREFIX + 'done' + notDisabled, @dialogApi.done)

    __initTabButtonCircle: ->
      circleEl = $('<div class="uploadcare-dialog-icon">')
        .css({padding: '11px'})
        .appendTo(@tabButton)

      circleDf = $.Deferred()

      update = =>
        infos = @dialogApi.fileColl.lastProgresses()
        progress = 0
        for progressInfo in infos
          progress += (progressInfo?.progress or 0) / infos.length
        circleDf.notify {progress}

      @dialogApi.fileColl.onAnyProgress.add update
      @dialogApi.fileColl.onAdd.add update
      @dialogApi.fileColl.onRemove.add update
      update()

      circle = new Circle(circleEl).listen circleDf.promise(), 'progress'

      updateTheme = ->
        circle.setColorTheme(
          if tabActive
            'default'
          else 
            if buttonHovered
              'darkGrey'
            else
              'grey'
        )

      tabActive = false
      @dialogApi.onSwitched.add (_, switchedToMe) =>
        tabActive = switchedToMe
        updateTheme()

      buttonHovered = false
      @tabButton.hover ->
        buttonHovered = true
        updateTheme()
      , ->
        buttonHovered = false
        updateTheme()
