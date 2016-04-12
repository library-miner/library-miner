# 依存ライブラリをプロジェクトIDと紐付ける
#
# [使い方]
#   LibraryRelation.new.perform(mode: "all")
#   LibraryRelation.new.perform()
class LibraryRelation < Base
  queue_as :analyzer

  def perform(mode: 'diff')
    # ライブラリ紐付け失敗テーブルの初期化
    LibraryRelationError.delete_all

    # 全件入れ替えモードの場合、紐付けを初期化
    remove_library_relation if mode == 'all'

    dependencies = ProjectDependency.where(project_to_id: nil)
    dependencies.find_each do |dependency|
      # rubygems から github_item_id を求め紐付ける
      github_item_id = InputLibrary.get_github_item_id_from_gem_name(
        dependency.library_name
      )
      if github_item_id.present?
        project_to = Project.where(github_item_id: github_item_id).first
      end

      # 上記失敗の場合、rubygemsからfull_nameを求め紐付ける
      if project_to.nil?
        full_name = InputLibrary.get_full_name_from_gem_name(
          dependency.library_name
        )
        if full_name.present?
          project_to = Project.where(full_name: full_name).first
        end
      end

      # 上記失敗の場合、nameからproject_idを求める(Starが一番多いもの)
      if project_to.nil?
        project_to = Project
                     .where(name: dependency.library_name)
                     .order(stargazers_count: :desc)
                     .first
      end

      # 全て失敗した場合はエラーリストに格納する(基本的に発生しない)
      if project_to.nil?
        LibraryRelationError.count_up_error_library(
          dependency.library_name
        )
      else
        # 紐付けられた場合
        dependency.project_to = project_to
        dependency.save
      end
    end

    # 不完全なプロジェクトを対象に、プロジェクトが完全であるか確認し
    # in_complete フラグを更新する
    projects = Project.incompleted
    projects.find_each do |project|
      next unless project.check_completed?
      pt = project.get_project_type
      project.attributes = {
        is_incomplete: false,
        project_type: pt,
        export_status: ExportStatus::WAITING
      }
      project.save
    end
  end

  private

  # 依存ライブラリとプロジェクトIDの関連を削除する
  # プロジェクトは全て不完全とする
  def remove_library_relation
    ProjectDependency.update_all(
      project_to_id: nil,
      updated_at: Time.zone.now
    )
    Project.update_all(
      is_incomplete: true,
      updated_at: Time.zone.now
    )
  end
end
