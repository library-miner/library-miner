class ProjectType < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'project_type'

  enum_accessor :type
end
