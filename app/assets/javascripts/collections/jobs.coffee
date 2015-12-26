class Miner.Collections.Jobs extends Backbone.Collection
  model: Miner.Models.Job
  url: '/api/management_jobs'

  parse: (res) ->
    return res.result
