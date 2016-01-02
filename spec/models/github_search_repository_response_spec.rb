require 'rails_helper'

RSpec.describe GithubSearchRepositoryResponse, type: :model do
  include GithubResponseSupport

  describe 'Github search repositories の正常系テスト'
  context '正常リクエスト取得時(データは複数ページに渡り存在する)' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_project_base_info01_header')
      response_body = read_json_file('github_project_base_info01')

      # Faraday Stub 準備
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/test') { |_env| [200, response_header, response_body] }
      end
      test = Faraday.new do |builder|
        builder.adapter :test, stubs do |stub|
        end
      end
      # Faraday Stub で準備したresponse取得
      @resp = test.get do |req|
        req.url '/test', page: 1, per_page: 10
      end

      # テスト対象実行
      @result = GithubSearchRepositoryResponse.parse(@resp, 1)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'items に 検索結果が格納されること' do
      expect(@result.items.count).to eq 2
    end

    it 'current_page に現在のページ番号が格納されること' do
      expect(@result.current_page).to eq 1
    end

    it '件数が320件のため、has_next_page が trueであること' do
      expect(@result.has_next_page).to eq true
    end

    it '件数が取得できていること' do
      expect(@result.total_count).to eq 320
    end

    it 'rate_limit_remaining(API取得可能残数)が取得できていること' do
      expect(@result.rate_limit_remaining).to eq 9
    end

    context '最終ページにいる場合' do
      it 'has_next_pageがfalseであること' do
        @result = GithubSearchRepositoryResponse.parse(@resp, 4)
        expect(@result.has_next_page).to eq false
      end
    end
  end
end
