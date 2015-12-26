class Miner.Views.JobResultsView extends Marionette.CompositeView
  tagName: 'table'
  className: 'table table-bordered table-hover'
  childView: Miner.Views.JobResultView
  childViewContainer: 'tbody'
  template: HandlebarsTemplates['job_results']

