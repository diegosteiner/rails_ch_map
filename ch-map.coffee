(($) ->
  class CHMap
    constructor: (element, options) ->
      @element = element
      @options = $.extend({
          value: 0
          autoload: false
          extend_SVGElement: true
          aspect_ratio: 0.62
          callbacks: {
            click: []
            mouseenter: []
            mouseleave: []
          }
          toggleable_elements: (element) ->
            return [
              $(element).find("#cantons>path").get()
              $(element).find("#canton_names text").get()
            ]
        }, options)

      @callbacks = {
        click: $.Callbacks()
        mouseenter: $.Callbacks()
        mouseleave: $.Callbacks()
      }

      for type, callbacks of @options.callbacks
        callbacks = [callbacks] unless $.isArray(callbacks)
        for callback in callbacks
          @callbacks[type].add callback
          console.log callback.length

      @extend_SVGElement() if @options.extend_SVGElement == true
      @load() if @options.autoload == true

    _initialize_aspect_ratio_enforcement: ->
      @enforce_aspect_ratio()
      $(window).resize =>
        @enforce_aspect_ratio()

    _initialize_callbacks: ->
      for type, callback of @callbacks
        continue if callback.length == 0
        for element in @_toggleable_elements()
          ((type, callback) ->
            $(element).on type, ->
              callback.fire(this)
          )(type, callback)

    _toggleable_elements: ->
      te = @options.toggleable_elements
      elements = te(@element) if $.isFunction(te)
      elements = te if $.isArray(te)
      return (e for e in ([].concat.apply([], elements)) when e?)

    extend_SVGElement: ->
      unless SVGElement.hasClass == 'function'
        SVGElement.prototype.hasClass = (className) ->
          new RegExp('(\\s|^)' + className + '(\\s|$)').test(@getAttribute('class'))

      unless SVGElement.addClass == 'function'
        SVGElement.prototype.addClass = (className) ->
          @setAttribute('class', @getAttribute('class') + ' ' + className) if !@hasClass(className)

      unless SVGElement.removeClass == 'function'
        SVGElement.prototype.removeClass = (className) ->
          c = @getAttribute('class')
          c ||= " "
          removedClass = c.replace(new RegExp('(\\s|^)' + className + '(\\s|$)', 'g'), '$2')
          @setAttribute('class', removedClass) if @hasClass(className)

      unless SVGElement.toggleClass == 'function'
        SVGElement.prototype.toggleClass = (className) ->
          if @hasClass(className)
            @removeClass(className)
          else
            @addClass(className)

    enforce_aspect_ratio: ->
      $(@element).css('height', $(@element).width() * @options.aspect_ratio)

    load: ->
      $(@element).load 'images/ch_map.svg', =>
        $(@element).addClass('loaded')
        @_initialize_aspect_ratio_enforcement()
        @_initialize_callbacks()

    is_loaded: ->
      return $(@element).hasClass('loaded')

  $.fn.chmap = (options) ->
    $(this).each ->
      new CHMap(this, options)

) jQuery