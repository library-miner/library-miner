require 'rails_helper'

RSpec.describe GithubProjectDetailCrawler, type: :model do
  include GithubResponseSupport

  describe "Github Repository Response の正常系テスト"
    context "正常リクエスト取得時(ブランチ)" do
      before :each do
        # Faraday dummy Responseを返すように設定
        dummy_faraday_response
        # Input Project に テストデータ投入
        create(:input_project)
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
      WebMock.stub_request(
        :get,
        "https://api.github.com/repositories/123456789123456789/branches?page=1&per_page=100").
      with(
        :headers => {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'token 229ba8b7116bc902c0122ed6f34e58464eebdeaa',
          'User-Agent'=>'Faraday v0.9.2'
        }
      ).
      to_return(
        status: 200,
        body: readJsonFile("github_branch_01"),
        headers: readResponseHeaderFile("github_branch_01_header")
      )

    end

end
