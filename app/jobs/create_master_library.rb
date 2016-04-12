# マスタライブラリを作成する
# マスタライブラリは誤ったライブラリの紐付け検出、及び修正のために使用される
#
# [使い方]
#   CreateMasterLibrary.new.perform()
class CreateMasterLibrary < LibraryRelation
  queue_as :analyzer

  def perform
    # マスタライブラリのクリア

    # 依存ライブラリからライブラリ名一覧を取得し、マスタライブラリに格納する
    
    # ライブラリ名からProjectIdを求める(手法はLibraryRelationと同様)
  end

  private
end
