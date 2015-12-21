class Miner.Collections.JobSearchLists extends Backbone.Collection
  model: Miner.Models.JobSearchList
  url: '/api/management_jobs/job_search_lists'

  parse: (res) ->
    return res.result
