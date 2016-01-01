# 入力元テーブルに入った情報を元に、
# 対象プロジェクトが利用しているライブラリ情報を格納する
#
# [使い方]
#   ProjectAnalyzer.new.perform
class ProjectAnalyzer < Base
  queue_as :analyzer

  def perform(analyze_count: 5)
    target_projects = InputProject.crawled.limit(analyze_count)
    target_projects.each do |project|
      # InputProjectのGemfileを解析し、紐づくgemfilesのリストを取得する
      is_parse_success, gemfiles, error =
        begin
          contents = project.gemfile.try(:content)
          # FIXME: もっといい感じにする
          # gemspecの場合はrubygemsからの情報を持っているためgemfilesに加える
          InputDependencyLibrary.where(input_project_id: project.id).each do |lib|
            contents = '' if contents.nil?
            contents += "\n gem '" + lib.name + "'"
          end
          GemfileParser.new.parse_gemfile(contents)
        rescue => e
          [false, nil, e]
        end

      if is_parse_success
        # InputProjectおよび紐づくテーブルの情報をProjectに格納する
        # 既にデータが存在する場合は上書き保存をする
        # また、関連するライブラリの情報を保存する
        source_project = copy_project(project)

        ActiveRecord::Base.transaction do
          source_project.create_dependency_projects(gemfiles.map(&:name))

          # dependencies ライブラリもProjectとして保存する(is_incomplete = trueとする)
          source_project.create_project_from_dependency(gemfiles.map(&:name))

          # 各種プロジェクト詳細情報をコピー
          copy_project_trees(project, source_project)
          copy_project_branches(project, source_project)
          copy_project_tags(project, source_project)
          copy_project_weekly_commit_counts(project, source_project)
          copy_project_readme(project, source_project)

          source_project.save!

          project.attributes = {
            crawl_status: CrawlStatus::ANALYZE_DONE
          }
          project.save!
        end
      else
        # 解析失敗
        project.attributes = {
          crawl_status: CrawlStatus::ANALYZE_ERROR
        }
        project.save!
        Rails.logger.warn("Parse error #{project.id} - #{error}")
      end
    end
  end

  private

  # project情報作成
  # 次の順で作成する
  # 1.github_item_idが存在する場合、プロジェクト情報更新
  # 2.上記がない場合、full_nameで検索し、存在したらプロジェクト情報作成
  # 3.上記がない場合、nameで検索し、存在したらプロジェクト情報作成
  # 4.いずれにも該当しない場合、新規作成
  def copy_project(project)
    dup_project_attributes = project
                             .attributes
                             .slice(*InputProject::COPYABLE_ATTRIBUTES.map(&:to_s))

    if Project.where(github_item_id: project.github_item_id).present?
      source_project = Project
                       .find_or_initialize_by(github_item_id: project.github_item_id)
                       .tap { |v| v.attributes = dup_project_attributes }
    elsif Project.where(full_name: project.full_name,
                        github_item_id: nil).present?
      source_project = Project
                       .find_or_initialize_by(full_name: project.full_name,
                                              github_item_id: nil)
                       .tap { |v| v.attributes = dup_project_attributes }
    elsif Project.where(name: project.name,
                        full_name: nil,
                        github_item_id: nil).present?
      source_project = Project
                       .find_or_initialize_by(name: project.name,
                                              full_name: nil,
                                              github_item_id: nil)
                       .tap { |v| v.attributes = dup_project_attributes }
    else
      source_project = Project
                       .find_or_initialize_by(github_item_id: project.github_item_id)
                       .tap { |v| v.attributes = dup_project_attributes }
    end
    source_project
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
      next unless InputTree.is_readme?(content.path)
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
