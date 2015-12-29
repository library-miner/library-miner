require 'rails_helper'

RSpec.describe GithubRepositoryStatsParticipationResponse, type: :model do
  include GithubResponseSupport

  describe "Github Repository Stats Participation Response の正常系テスト"
    context "正常リクエスト取得時(週間コミット数)" do
      before :each do
        # Responseの内容をファイルより取得
        response_header = readResponseHeaderFile("github_weekly_commit_count_01_header")
        response_body = readJsonFile("github_weekly_commit_count_01")

        # Faraday Dummy Response取得
        @resp = dummy_faraday_response(response_header, response_body)
        # テスト対象実行
        @result = GithubRepositoryStatsParticipationResponse.parse(@resp,1)
      end

      it "is_success が trueであること" do
        expect(@result.is_success).to eq true
      end

      it "current_page が 1 であること" do
        expect(@result.current_page).to eq 1
      end

      it "has_next_page が falseであること" do
        expect(@result.has_next_page).to eq false
      end

      it "rate_limit_remaining(API取得可能残数)が取得できていること" do
        expect(@result.rate_limit_remaining).to eq 4999
      end

      it "items (週間コミット数) が取得できること" do
        expect(@result.items.count).to eq 52
        expect(@result.items[0][:all]).to eq 11
        expect(@result.items[51][:all]).to eq 7
        expect(@result.items[0][:owner]).to eq 3
        expect(@result.items[51][:owner]).to eq 3
      end

    end

    context "Github側で情報が作成されておらず結果が空で帰ってくる場合" do
      before :each do
        # Responseの内容をファイルより取得
        response_header = readResponseHeaderFile("github_weekly_commit_count_01_header")
        response_body = readJsonFile("github_weekly_commit_count_02")

        # Faraday Dummy Response取得
        @resp = dummy_faraday_response(response_header, response_body, status: 202)
        # テスト対象実行
        @result = GithubRepositoryStatsParticipationResponse.parse(@resp,1)
      end

      it "is_success が falseであること" do
        expect(@result.is_success).to eq false
      end

      it "items が空([]) であること" do
        expect(@result.items).to eq []
      end

    end

    def dummy_faraday_response(response_header, response_body, status: 200)
        # Faraday Stub 準備
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/test') { |env| [status,response_header,response_body] }
        end
        test = Faraday.new do |builder|
          builder.adapter :test, stubs do |stub|
          end
        end
        # Faraday Stub で準備したresponse取得
        resp = test.get do |req|
          req.url '/test',page: 1, per_page: 10
        end
        resp
    end

end
