require 'rails_helper'

RSpec.describe GithubProjectDetailCrawler, type: :model do
  include GithubResponseSupport

  describe "Github Repository Response の正常系テスト"
    context "正常リクエスト取得時(ブランチ)" do
      before :each do
        # Faraday dummy Responseを返すように設定
        dummy_faraday_response
        # Input Project に テストデータ投入
        create(
          :input_project,
          github_updated_at: Date.today
        )
        targets = InputProject.get_project_detail_crawl_target(
          1,
          1
        )
        # テスト対象実行
        GithubProjectDetailCrawler.new.main(targets[0])
      end

      it "test" do

      end
    end

    def dummy_faraday_response
      # Branch
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/branches*/,
        header_file_name: "github_branch_01_header",
        body_file_name: "github_branch_01",
        status: 200
      )

      # Branch end
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/branches\?page=5\&per_page=100/,
        header_file_name: "github_branch_02_header",
        body_file_name: "github_branch_01",
        status: 200
      )

      # Tags
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/tags*/,
        header_file_name: "github_tags_01_header",
        body_file_name: "github_tags_01",
        status: 200
      )

      # Tags end
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/tags\?page=5\&per_page=100/,
        header_file_name: "github_tags_02_header",
        body_file_name: "github_tags_01",
        status: 200
      )

      # tree
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/git\/trees*/,
        header_file_name: "github_tree_01_header",
        body_file_name: "github_tree_01",
        status: 200
      )

      # weekly_commit
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/stats\/participation*/,
        header_file_name: "github_weekly_commit_count_01_header",
        body_file_name: "github_weekly_commit_count_01",
        status: 200
      )

      # blob
      set_dummy_response(
        url: /https:\/\/api.github.com\/repositories\/123456789123456789\/git\/blobs*/,
        header_file_name: "github_blob_01_header",
        body_file_name: "github_blob_01",
        status: 200
      )

    end

end
