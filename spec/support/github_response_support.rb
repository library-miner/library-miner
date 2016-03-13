require 'spec_helper'
require 'json'
require 'webmock/rspec'

module GithubResponseSupport
  def read_response_header_file(file_name)
    r = File.read('spec/fixtures/' + file_name + '.txt')
    results = {}
    r.split(/[\r\n]+/).each do |line|
      first_s, *s_a = line.split(':')
      t = ''
      s_a.each do |s|
        t += s.to_s
      end
      results[first_s] = t
    end
    results
  end

  def read_json_file(file_name)
    File.read('spec/fixtures/' + file_name + '.json')
  end

  # 設定したURLを実行時にダミーのResponseを返却する
  def set_dummy_response(url: '', header_file_name: '', body_file_name: '', status: 200)
    WebMock.stub_request(
      :get,
      url
    )
           .with(
             headers: {
               'Accept' => /.*/,
               'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
               'Authorization' => /token */,
               'User-Agent' => /Faraday */
             }
           )
           .to_return(
             status: status,
             body: read_json_file(body_file_name.to_s),
             headers: read_response_header_file(header_file_name.to_s)
           )
  end
end
