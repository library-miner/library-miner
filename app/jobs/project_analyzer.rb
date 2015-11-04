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
        ActiveRecord::Base.transaction do
          source_project.create_dependency_projects(gemfiles.map(&:name))
          # TODO: dependencies ライブラリもProjectとして保存する(is_incomplete = trueとする)
          # TODO: SourceProjectを解析済みにする

          # 各種プロジェクト詳細情報をコピー
          copy_project_trees(project, source_project)
          copy_project_branches(project, source_project)
          copy_project_tags(project, source_project)
          copy_project_weekly_commit_counts(project, source_project)
          copy_project_readme(project, source_project)
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

  def copy_project_trees(input_project, project)
    trees = input_project.input_trees
    project.project_trees.delete_all

    trees.each do |tree|
      dup_tree_attributes = tree
      .attributes
      .slice(*InputTree::COPYABLE_ATTRIBUTES.map(&:to_s))
      source_tree = project
      .project_trees
      .build
      .tap { |v| v.attributes = dup_tree_attributes }
      source_tree.save!
    end
  end

  def copy_project_branches(input_project, project)
    branches = input_project.input_branches
    project.project_branches.delete_all

    branches.each do |branch|
      dup_branch_attributes = branch
      .attributes
      .slice(*InputBranch::COPYABLE_ATTRIBUTES.map(&:to_s))
      source_branch = project
      .project_branches
      .build
      .tap { |v| v.attributes = dup_branch_attributes }
      source_branch.save!
    end
  end

  def copy_project_tags(input_project, project)
    tags = input_project.input_tags
    project.project_tags.delete_all

    tags.each do |tag|
      dup_tag_attributes = tag
      .attributes
      .slice(*InputTag::COPYABLE_ATTRIBUTES.map(&:to_s))
      source_tag = project
      .project_tags
      .build
      .tap { |v| v.attributes = dup_tag_attributes }
      source_tag.save!
    end
  end

  def copy_project_weekly_commit_counts(input_project, project)
    commits = input_project.input_weekly_commit_counts
    project.project_weekly_commit_counts.delete_all

    commits.each do |commit|
      dup_commit_attributes = commit
      .attributes
      .slice(*InputWeeklyCommitCount::COPYABLE_ATTRIBUTES.map(&:to_s))
      source_commit = project
      .project_weekly_commit_counts
      .build
      .tap { |v| v.attributes = dup_commit_attributes }
      source_commit.save!
    end
  end

  def copy_project_readme(input_project, project)
    contents = input_project.input_contents
    project.project_readmes.delete_all

    contents.each do |content|
      if InputTree.is_readme?(content.path)
        dup_content_attributes = content
        .attributes
        .slice(*InputContent::COPYABLE_ATTRIBUTES.map(&:to_s))
        source_content = project
        .project_readmes
        .build
        .tap { |v| v.attributes = dup_content_attributes }
        source_content.save!
      end
    end
  end

end
