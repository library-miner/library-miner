require 'rails_helper'

RSpec.describe GithubRepositoryResponse, type: :model do
  include GithubResponseSupport

  describe 'Github Repository Response の正常系テスト'
  context '正常リクエスト取得時(ブランチ)' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_branch_01_header')
      response_body = read_json_file('github_branch_01')

      # Faraday Dummy Response取得
      @resp = dummy_faraday_response(response_header, response_body)
      # テスト対象実行
      @result = GithubRepositoryResponse.parse(@resp, 1)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'current_page に現在のページ番号が格納されること' do
      expect(@result.current_page).to eq 1
    end

    it '複数ページに渡るためhas_next_page が trueであること' do
      expect(@result.has_next_page).to eq true
    end

    it 'rate_limit_remaining(API取得可能残数)が取得できていること' do
      expect(@result.rate_limit_remaining).to eq 4999
    end

    it 'items (ブランチ情報) が取得できること' do
      expect(@result.items.count).to eq 1
      expect(@result.items[0].name).to eq 'master'
    end

    context '最終ページにいる場合' do
      it 'has_next_pageがfalseであること' do
        # Responseの内容をファイルより取得
        response_header = read_response_header_file('github_branch_02_header')
        response_body = read_json_file('github_branch_01')

        # Faraday Dummy Response取得
        @resp = dummy_faraday_response(response_header, response_body)
        # テスト対象実行
        @result = GithubRepositoryResponse.parse(@resp, 1)
        expect(@result.has_next_page).to eq false
      end
    end
  end

  context '正常リクエスト取得時(Tag)' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_tags_01_header')
      response_body = read_json_file('github_tags_01')

      # Faraday Dummy Response取得
      @resp = dummy_faraday_response(response_header, response_body)
      # テスト対象実行
      @result = GithubRepositoryResponse.parse(@resp, 1)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'current_page に現在のページ番号が格納されること' do
      expect(@result.current_page).to eq 1
    end

    it '複数ページに渡るためhas_next_page が trueであること' do
      expect(@result.has_next_page).to eq true
    end

    it 'rate_limit_remaining(API取得可能残数)が取得できていること' do
      expect(@result.rate_limit_remaining).to eq 4999
    end

    it 'items (Tag情報) が取得できること' do
      expect(@result.items.count).to eq 1
      expect(@result.items[0].name).to eq 'v0.1'
    end
  end

  context '正常リクエスト取得時(Tree)' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_tree_01_header')
      response_body = read_json_file('github_tree_01')

      # Faraday Dummy Response取得
      @resp = dummy_faraday_response(response_header, response_body)
      # テスト対象実行
      @result = GithubRepositoryResponse.parse(@resp, 1)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'current_page に現在のページ番号が格納されること' do
      expect(@result.current_page).to eq 1
    end

    it 'has_next_page が false であること' do
      expect(@result.has_next_page).to eq false
    end

    it 'rate_limit_remaining(API取得可能残数)が取得できていること' do
      expect(@result.rate_limit_remaining).to eq 4999
    end

    it 'items (Tree情報) が取得できること' do
      expect(@result.items.count).to eq 3
      expect(@result.items[0].path).to eq 'file.rb'
    end
  end

  context '正常リクエスト取得時(Blob)' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_blob_01_header')
      response_body = read_json_file('github_blob_01')

      # Faraday Dummy Response取得
      @resp = dummy_faraday_response(response_header, response_body)
      # テスト対象実行
      @result = GithubRepositoryResponse.parse_blob(@resp)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'current_page に現在のページ番号が格納されること' do
      expect(@result.current_page).to eq 1
    end

    it 'has_next_page が false であること' do
      expect(@result.has_next_page).to eq false
    end

    it 'rate_limit_remaining(API取得可能残数)が取得できていること' do
      expect(@result.rate_limit_remaining).to eq 4999
    end

    it 'items (Blob情報) が取得できること' do
      expect(@result.items).not_to eq nil
    end
  end

  context '情報が見つからない場合' do
    before :each do
      # Responseの内容をファイルより取得
      response_header = read_response_header_file('github_tree_01_header')
      response_body = read_json_file('github_not_found')

      # Faraday Dummy Response取得
      @resp = dummy_faraday_response(response_header, response_body, status: 404)
      # テスト対象実行
      @result = GithubRepositoryResponse.parse(@resp, 1)
    end

    it 'is_success が trueであること' do
      expect(@result.is_success).to eq true
    end

    it 'items が空([]) であること' do
      expect(@result.items).to eq []
    end
  end

  def dummy_faraday_response(response_header, response_body, status: 200)
    # Faraday Stub 準備
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') { |_env| [status, response_header, response_body] }
    end
    test = Faraday.new do |builder|
      builder.adapter :test, stubs do |stub|
      end
    end
    # Faraday Stub で準備したresponse取得
    resp = test.get do |req|
      req.url '/test', page: 1, per_page: 10
    end
    resp
  end
end
