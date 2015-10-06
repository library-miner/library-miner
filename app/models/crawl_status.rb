class CrawlStatus < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'crawl_status'

  enum_accessor :type
end
