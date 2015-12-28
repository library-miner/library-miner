require 'spec_helper'

module GithubResponseSupport
  def json_response(file_name)
    File.open('spec/fixtures/' + file_name, 'json').read
  end

end

