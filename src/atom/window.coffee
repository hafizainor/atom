fs = require 'fs'
_ = require 'underscore'
$ = require 'jquery'

Layout = require 'layout'
Editor = require 'editor'

# This a weirdo file. We don't create a Window class, we just add stuff to
# the DOM window.

windowAdditions =
  editor: null
  keyBindings: null
  layout: null
  menuItemActions: null

  startup: ->
    @keyBindings = {}
    @menuItemActions = {}
    @layout = Layout.attach()
    @editor = new Editor $atomController.url?.toString()
    @registerEventHandlers()
    @bindKeys()
    @bindMenuItems()
    $(window).focus()

  shutdown: ->
    @layout.remove()
    @editor.shutdown()
    $(window).unbind('focus')
    $(window).unbind('blur')
    $(window).unbind('keydown')

  bindKeys: ->
    @bindKey 'meta+s', => @editor.save()
    @bindKey 'meta+w', => @close()

  bindMenuItems: ->
    @bindMenuItem "File > Save", => @editor.save()

  bindMenuItemAndKey: (path, pattern, action) ->
    @bindMenuItem path, action
    @bindKey pattern, action

  bindMenuItem: (path, action) ->
    @menuItemActions[path] = action

  bindKey: (pattern, action) ->
    @keyBindings[pattern] = action

  keyEventMatchesPattern: (event, pattern) ->
    keys = @parseKeyPattern pattern

    keys.ctrlKey == event.ctrlKey and
      keys.altKey == event.altKey and
      keys.shiftKey == event.shiftKey and
      keys.metaKey == event.metaKey and
      event.which == keys.key.toUpperCase().charCodeAt 0

  parseKeyPattern: (pattern) ->
    [modifiers..., key] = pattern.split '+'

    ctrlKey: 'ctrl' in modifiers
    altKey: 'alt' in modifiers
    shiftKey: 'shift' in modifiers
    metaKey: 'meta' in modifiers
    key: key

  registerEventHandlers: ->
    $(document).bind 'keydown', (event) =>
      for pattern, action of @keyBindings
        action() if @keyEventMatchesPattern(event, pattern)

    $(window).focus => @registerMenuItems()
    $(window).blur -> atom.native.resetMainMenu()

  registerMenuItems: ->
    for path of @menuItemActions
      atom.native.addMenuItem(path)

  performActionForMenuItemPath: (path) ->
    @menuItemActions[path]()

  showConsole: ->
    $atomController.webView.inspector.showConsole true

  onerror: ->
    @showConsole true

for key, value of windowAdditions
  console.warn "DOMWindow already has a key named `#{key}`" if window[key]
  window[key] = value
