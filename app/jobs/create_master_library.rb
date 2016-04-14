# マスタライブラリを作成する
# マスタライブラリは誤ったライブラリの紐付け検出、及び修正のために使用される
#
# [使い方]
#   CreateMasterLibrary.new.perform()
class CreateMasterLibrary < LibraryRelation
  queue_as :analyzer

  def perform
    # マスタライブラリのクリア
    MasterLibrary.delete_all

    # マスタライブラリ作成
    create_master_libraries
  end

  private

  # ライブラリ一覧を取得
  def library_lists
    ProjectDependency.where.not(library_name: '').select(:library_name).uniq
  end

  def create_master_libraries
    results = []
    # 依存ライブラリからライブラリ名一覧を取得し、マスタライブラリに格納する
    library_lists.each_with_index do |library, i|
      # 1000件ごとにコミット
      if i % 1000 == 0
        binding.pry
        MasterLibrary.import results
        results = []
      end

      # ライブラリ名からProjectIdを求める(手法はLibraryRelationと同様)
      project_to = find_project_id_based_on_library_name(library.library_name)

      if project_to.present?
        results << MasterLibrary.new(project_to_id: project_to.id,
                                     library_name: library.library_name)
      else
        results << MasterLibrary.new(library_name: library.library_name)
      end
    end

    MasterLibrary.import results
  end
end
