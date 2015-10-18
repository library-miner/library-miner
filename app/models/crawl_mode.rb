class CrawlMode < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'crawl_mode'

  enum_accessor :type
end
