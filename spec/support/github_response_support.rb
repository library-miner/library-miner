require 'spec_helper'
require 'json'

module GithubResponseSupport

  def readResponseHeaderFile(file_name)
    r = File.read('spec/fixtures/' + file_name + '.txt')
    results = Hash.new
    r.split(/[\r\n]+/).each do |line|
      l = line.split(":")
      results[l[0]] = l[1].to_s
    end
    results
  end

  def readJsonFile(file_name)
    File.read('spec/fixtures/' + file_name + '.json')
  end

end

