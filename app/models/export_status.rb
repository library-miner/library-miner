class ExportStatus < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'export_status'

  enum_accessor :type
end
