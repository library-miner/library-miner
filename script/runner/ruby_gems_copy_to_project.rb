# input_libraries に入っている情報をprojectに移す
# 初回に使用する

libraries = InputLibrary.all

libraries.each do |library|
  # name で検索し、すでにプロジェクトに入っている場合は実施しない
  next unless Project.where(name: library.name).first.nil?
  full_name = nil

  if library.homepage_uri.present? &&
     library.homepage_uri.include?('/github.com/')
    full_name = library.homepage_uri
                       .gsub('http://github.com/', '')
                       .gsub('https://github.com/', '')
  end

  if library.source_code_uri.present? &&
     library.source_code_uri.include?('/github.com/')
    full_name = library.source_code_uri
                       .gsub('http://github.com/', '')
                       .gsub('https://github.com/', '')
  end

  project = Project.new(
    name: library.name,
    full_name: full_name,
    project_type: ProjectType::RUBYGEM
  )

  project.save
end
