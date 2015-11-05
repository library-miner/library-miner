# 依存ライブラリをプロジェクトIDと紐付ける
#
# [使い方]
#   LibraryRelation.new.perform(mode: "all")
#   LibraryRelation.new.perform()
class LibraryRelation < Base
  queue_as :library_relation

  def perform(mode: "diff")
    # ライブラリ紐付け失敗テーブルの初期化
    LibraryRelationError.delete_all

    # 全件入れ替えモードの場合、紐付けを初期化
    if mode == "all"
      remove_library_relation
    end

    dependencies = ProjectDependency.where(:project_id_to: nil)
    dependencies.each do |dependency|
      # rubygems から github_item_id を求め紐付ける
      github_item_id = InputLibrary.get_github_item_id_from_gem_name(dependency.name)

      # 上記失敗の場合、rubygemsからfull_nameを求め紐付ける
      full_name = InputLibrary.get_full_name_from_gem_name(dependency.name)
      # 上記失敗の場合、nameからproject_idを求める(Starが一番多いもの)

      # 全て失敗した場合はエラーリストに格納する(基本的に発生しない)

    end

    # 依存ライブラリが全てプロジェクトIDと紐付いている
    # かつ project の github_item_idがある場合
    # プロジェクトは完全と見なす
    # なお、依存ライブラリ側のgithub_item_idがなくとも完全と見なす
    projects = Project.where(is_incomplete: true)
    projects.each do |project|

    end
  end

  private

  # 依存ライブラリとプロジェクトIDの関連を削除する
  def remove_library_relation
    ProjectDependency.update_all(
      project_to_id: nil,
      updated_at: Time.now
    )
    Project.update_all(
      updated_at: Time.now
    )
  end

end
