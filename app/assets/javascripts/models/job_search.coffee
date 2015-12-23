class Miner.Models.JobSearch extends Backbone.Model

  initialize: ->
    # エンキュー開始時刻は初期値1日前
    currentDate = new Date()
    currentMonth = currentDate.getMonth() + 1
    yesterday = currentDate.getDate() - 1
    before24Hour =
      currentDate.getFullYear() +
      "/" +
      currentMonth +
      "/" +
      yesterday +
      " " +
      currentDate.getHours() +
      ":" +
      "00"
    @set(From: before24Hour)

