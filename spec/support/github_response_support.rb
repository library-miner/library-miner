require 'spec_helper'
require 'json'

module GithubResponseSupport

  def readResponseHeaderFile(file_name)
    r = File.read('spec/fixtures/' + file_name + '.txt')
    results = Hash.new
    r.split(/[\r\n]+/).each do |line|
      first_s, *s_a = line.split(":")
      t = ""
      s_a.each do |s|
        t = t + s.to_s
      end
      results[first_s] = t
    end
    results
  end

  def readJsonFile(file_name)
    File.read('spec/fixtures/' + file_name + '.json')
  end

end

