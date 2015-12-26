class JobStatus < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/division'
  set_filename 'job_status'

  enum_accessor :type
end
