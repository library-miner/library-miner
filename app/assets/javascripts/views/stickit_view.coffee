Miner.Views.StickitView =
  render: ->
    args = Array.prototype.slice.apply(arguments)
    result = Marionette.ItemView.prototype.render.apply(@, args)
    @stickit()
    @
