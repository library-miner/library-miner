require 'rails_helper'

RSpec.describe GithubProjectDetailCrawler, type: :model do
  include GithubResponseSupport

  describe 'Github Repository Response の正常系テスト'
  context '正常リクエスト取得時(代表ケース)' do
    before :each do
      # Faraday dummy Responseを返すように設定
      dummy_faraday_response
      # Input Project に テストデータ投入
      create(
        :input_project,
        github_updated_at: Time.zone.today
      )
      @targets = InputProject.get_project_detail_crawl_target(
        1,
        1
      )
      # テスト対象実行
      GithubProjectDetailCrawler.new.main(@targets[0])
    end

    it '収集対象のmasterブランチ情報が格納されること' do
      target_id = @targets[0].id

      branches = InputBranch.where(
        input_project_id: target_id,
        name: 'master'
      )

      # 5回取得するようにしているため(pageテストのため)
      expect(branches.count).to eq 1 * 5
      expect(branches[0].sha).to eq '6dcb09b5b57875f334f61aebed695e2e4193db5e'
    end

    it '収集対象のtags情報が格納されること' do
      target_id = @targets[0].id

      tags = InputTag.where(
        input_project_id: target_id
      )

      # 5回取得するようにしているため(pageテストのため)
      expect(tags.count).to eq 1 * 5
      expect(tags[0].sha).to eq 'c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc'
    end

    it '収集対象のツリー情報が格納されること' do
      target_id = @targets[0].id

      trees = InputTree.where(
        input_project_id: target_id
      )

      expect(trees.count).to eq 3
      expect(trees[2].path).to eq 'Gemfile'
    end

    it '収集対象の週間コミット数が格納されること' do
      target_id = @targets[0].id

      commits = InputWeeklyCommitCount.where(
        input_project_id: target_id
      ).order(index: :asc)

      expect(commits.count).to eq 52
      expect(commits[0].all_count).to eq 11
      expect(commits[51].all_count).to eq 7
      expect(commits[0].owner_count).to eq 3
      expect(commits[51].owner_count).to eq 3
    end

    it '収集対象のGemfileの内容が格納されること' do
      target_id = @targets[0].id

      contents = InputContent.where(
        input_project_id: target_id,
        path: 'Gemfile'
      )

      expect(contents.count).to eq 1
      expect(contents[0].content).not_to eq nil
    end

    it 'InputProjectのクロールステータスが2(収集済み)となること' do
      expect(@targets[0].crawl_status_id).to eq 2
    end
  end

  def dummy_faraday_response
    # Branch
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/branches*},
      header_file_name: 'github_branch_01_header',
      body_file_name: 'github_branch_01',
      status: 200
    )

    # Branch end
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/branches\?page=5&per_page=100},
      header_file_name: 'github_branch_02_header',
      body_file_name: 'github_branch_01',
      status: 200
    )

    # Tags
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/tags*},
      header_file_name: 'github_tags_01_header',
      body_file_name: 'github_tags_01',
      status: 200
    )

    # Tags end
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/tags\?page=5&per_page=100},
      header_file_name: 'github_tags_02_header',
      body_file_name: 'github_tags_01',
      status: 200
    )

    # tree
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/git/trees*},
      header_file_name: 'github_tree_01_header',
      body_file_name: 'github_tree_01',
      status: 200
    )

    # weekly_commit
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/stats/participation*},
      header_file_name: 'github_weekly_commit_count_01_header',
      body_file_name: 'github_weekly_commit_count_01',
      status: 200
    )

    # blob
    set_dummy_response(
      url: %r{https://api.github.com/repositories/123456789123456789/git/blobs*},
      header_file_name: 'github_blob_01_header',
      body_file_name: 'github_blob_01',
      status: 200
    )
  end
end
