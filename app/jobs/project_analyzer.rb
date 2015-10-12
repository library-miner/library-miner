# 入力元テーブルに入った情報を元に、
# 対象プロジェクトが利用しているライブラリ情報を格納する
#
# [使い方]
#   ProjectAnalyzer.new.perform
class ProjectAnalyzer < Base
  queue_as :project_analyzer

  def perform(analyze_count: 5)
    target_projects = InputProject.crawled.limit(analyze_count)
    target_projects.each do |project|
      # InputProjectのGemfileを解析し、紐づくgemfilesのリストを取得する
      is_parse_success, gemfiles, error =
        begin
          GemfileParser.new.parse_gemfile(project.gemfile.try(:content))
        rescue => e
          [false, nil, e]
        end

      if is_parse_success
        # InputProjectおよび紐づくテーブルの情報をProjectに格納する
        # 既にデータが存在する場合は上書き保存をする
        # また、関連するライブラリの情報を保存する
        dup_project_attributes = project
          .attributes
          .slice(*InputProject::COPYABLE_ATTRIBUTES.map(&:to_s))
        source_project = Project
          .find_or_initialize_by(github_item_id: project.github_item_id)
          .tap { |v| v.attributes = dup_project_attributes }
        # TODO: 詳細情報もコピーする

        ActiveRecord::Base.transaction do
          source_project.create_dependency_projects(gemfiles.map(&:name))
          # TODO: dependencies ライブラリもProjectとして保存する(is_incomplete = trueとする)
          # TODO: SourceProjectを解析済みにする
          source_project.save!
        end
      else
        # TODO: パース失敗時の処理
        Rails.logger.error("Parse error #{project.id} - #{error}")
      end
    end
  end

  private

  def search_or_initialize_project(library_name)
  end
end
