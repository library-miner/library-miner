class GeneralStatus < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'general_status'

  enum_accessor :type
end
