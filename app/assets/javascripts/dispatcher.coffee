class Dispatcher
  constructor: ->
    Miner.Application = new Backbone.Marionette.Application()

    instance = new Miner.Controllers.MinerController()
    Miner.addInstance('translations', instance)
    routers = new Miner.Routers.MinerRouters(controller: instance)

    Backbone.history.start()
    Miner.Application.start()

$ ->
  new Dispatcher()
