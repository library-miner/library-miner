create_table 'input_projects', collate: 'utf8_bin', comment: '入力元_プロジェクト_基本情報' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.int :crawl_status_id, default: 0, comment: '収集ステータス'
  t.bigint :github_item_id, comment: 'Github Item ID'
  t.int :client_node_id, null: true, comment: 'クライアントID'
  t.varchar :name
  t.varchar :full_name
  t.bigint :owner_id
  t.varchar :owner_login_name
  t.varchar :owner_type, limit: 30
  t.varchar :github_url
  t.boolean :is_fork, default: false
  t.text :github_description, null: true
  t.datetime :github_created_at
  t.datetime :github_updated_at
  t.datetime :github_pushed_at
  t.text :homepage, null: true
  t.bigint :size, default: 0
  t.bigint :stargazers_count, default: 0, comment: 'スター数'
  t.bigint :watchers_count, default: 0, comment: 'ウォッチャー数'
  t.bigint :fork_count, default: 0, comment: 'フォーク数'
  t.bigint :open_issue_count, default: 0, comment: 'イシュー数'
  t.varchar :github_score, default: '', comment: 'Github上のスコア'
  t.varchar :language, default: ''

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_branches', collate: 'utf8_bin', comment: '入力元_プロジェクト_ブランチ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :name, comment: 'ブランチ名'
  t.varchar :sha
  t.varchar :url
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_tags', collate: 'utf8_bin', comment: '入力元_プロジェクト_タグ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :name, comment: 'タグ名'
  t.varchar :sha
  t.varchar :url
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_trees', collate: 'utf8_bin', comment: '入力元_プロジェクト_ツリー' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :path, comment: 'ファイルパス'
  t.varchar :file_type, comment: 'ファイルタイプ'
  t.varchar :sha
  t.varchar :url, null: true
  t.int :size, null: true
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_contents', collate: 'utf8_bin', comment: '入力元_プロジェクト_コンテンツ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :path, comment: 'ファイルパス'
  t.varchar :sha
  t.text :content, comment: 'ファイル内容'
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_dependency_libraries', collate: 'utf8_bin', comment: '入力元_プロジェクト_依存ライブラリ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :name, comment: 'ライブラリ名'
  t.varchar :version, comment: 'ライブラリバージョン'
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_libraries', collate: 'utf8_bin', comment: '入力元_ライブラリ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, null: true, comment: 'Input project id'

  t.varchar :name, comment: 'ライブラリ名'
  t.varchar :version, comment: 'ライブラリバージョン', null: true
  t.varchar :homepage_uri, null: true
  t.varchar :source_code_uri, null: true
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_weekly_commit_counts', collate: 'utf8_bin', comment: '入力元_プロジェクト_週間コミット数' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.int :index, comment: '過去何週前 0は最新を表す'
  t.int :all_count, comment: '全体コミット数'
  t.int :owner_count, comment: 'オーナーコミット数'
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_project_checkers', collate: 'utf8_bin', comment: '入力元_プロジェクト_初回チェック用' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.varchar :crawl_date, null: true

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'projects', collate: 'utf8_bin', comment: 'プロジェクト基本情報' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.boolean :is_incomplete, default: true, comment: "不完全フラグ"
  t.bigint :github_item_id, comment: 'Github Item ID', null: true
  t.varchar :name
  t.varchar :full_name, null: true
  t.bigint :owner_id, null: true
  t.varchar :owner_login_name, default: ""
  t.varchar :owner_type, limit: 30, default: ""
  t.varchar :github_url, null: true
  t.boolean :is_fork, default: false
  t.text :github_description, null: true
  t.datetime :github_created_at, null: true
  t.datetime :github_updated_at, null: true
  t.datetime :github_pushed_at, null: true
  t.text :homepage, null: true
  t.bigint :size, default: 0
  t.bigint :stargazers_count, default: 0, comment: 'スター数'
  t.bigint :watchers_count, default: 0, comment: 'ウォッチャー数'
  t.bigint :fork_count, default: 0, comment: 'フォーク数'
  t.bigint :open_issue_count, default: 0, comment: 'イシュー数'
  t.varchar :github_score, default: '', comment: 'Github上のスコア'
  t.varchar :language, default: ''

  t.datetime :created_at
  t.datetime :updated_at

  t.index :github_item_id, unique: true
end

create_table 'project_dependencies', collate: 'utf8_bin', comment: 'プロジェクト依存関係' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.int :project_from_id
  t.int :project_to_id, null: true
  t.varchar :library_name

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'project_readmes', collate: 'utf8_bin', comment: 'プロジェクト_README' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :project_id, comment: 'Project id'

  t.varchar :path, comment: 'ファイルパス'
  t.varchar :sha
  t.text :content, comment: 'ファイル内容'
  t.foreign_key 'project_id', reference: 'projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'project_branches', collate: 'utf8_bin', comment: 'プロジェクト_ブランチ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :project_id, comment: 'Project id'

  t.varchar :name, comment: 'ブランチ名'
  t.varchar :sha
  t.varchar :url
  t.foreign_key 'project_id', reference: 'projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'project_tags', collate: 'utf8_bin', comment: 'プロジェクト_タグ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :project_id, comment: 'Project id'

  t.varchar :name, comment: 'タグ名'
  t.varchar :sha
  t.varchar :url
  t.foreign_key 'project_id', reference: 'projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'project_trees', collate: 'utf8_bin', comment: 'プロジェクト_ツリー' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :project_id, comment: 'Project id'

  t.varchar :path, comment: 'ファイルパス'
  t.varchar :file_type, comment: 'ファイルタイプ'
  t.varchar :sha
  t.varchar :url, null: true
  t.int :size, null: true
  t.foreign_key 'Project_id', reference: 'projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'project_weekly_commit_counts', collate: 'utf8_bin', comment: 'プロジェクト_週間コミット数' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :project_id, comment: 'Project id'

  t.int :index, comment: '過去何週前 0は最新を表す'
  t.int :all_count, comment: '全体コミット数'
  t.int :owner_count, comment: 'オーナーコミット数'
  t.foreign_key 'project_id', reference: 'projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'library_relation_errors', collate: 'utf8_bin', comment: 'プロジェクト依存関係紐付け失敗' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.varchar :library_name
  t.int :error_count, comment: 'いくつのプロジェクトから紐付け失敗したか'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table :delayed_jobs, comment: "Delayed Job" do |t|
  t.int :id, primary_key: true, extra: 'auto_increment'
  t.int :priority, default: 0, null: false
  t.int :attempts, default: 0, null: false
  t.text :handler
  t.text :last_error, null: true
  t.datetime :run_at, null: true
  t.datetime :locked_at, null: true
  t.datetime :failed_at, null: true
  t.varchar :locked_by, null: true
  t.varchar :queue, null: true

  t.datetime :created_at, null: true, comment: '作成日時'
  t.datetime :updated_at, null: true, comment: '更新日時'

  t.index [:priority, :run_at], name: "delayed_jobs_priority"
end

create_table :management_jobs, comment: "ジョブ管理" do |t|
  t.int :id, primary_key: true, extra: 'auto_increment'
  t.varchar :job_id, null: true
  t.varchar :job_name, null: true
  t.text :error_message, null: true
  t.datetime :started_at, null: true
  t.datetime :ended_at, null: true
  t.int :job_status_id

  t.datetime :created_at, null: true, comment: '作成日時'
  t.datetime :updated_at, null: true, comment: '更新日時'

  t.index [:job_id], name: "management_jobs_job_id"
end

create_table 'schema_migrations', collate: 'utf8_bin', comment: '' do |t|
  t.varchar 'version'

  t.index 'version', name: 'unique_schema_migrations', unique: true
end
