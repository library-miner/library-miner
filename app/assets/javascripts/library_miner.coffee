window.Miner =
  Controllers: {}
  Routers: {}
  Views: {}
  Models: {}
  Collections: {}
  Instances: {}

  addInstance: (variableName, instance) ->
    Miner.Instances[variableName] = instance

  getInstance: (variableName) ->
    Miner.Instances[variableName]
