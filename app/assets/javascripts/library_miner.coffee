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

Handlebars.registerHelper('percent',(v) ->
  return new Handlebars.SafeString( (v * 100) + "%")
)

Handlebars.registerHelper('percent2',(v1, v2) ->
  return new Handlebars.SafeString( ((v1 / v2) * 100) + "%")
)
