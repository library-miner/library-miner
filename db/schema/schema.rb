create_table 'input_projects', collate: 'utf8_bin', comment: '入力元_プロジェクト_基本情報' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.int :crawl_status_id, default: 0, comment: '収集ステータス'
  t.bigint :github_item_id, comment: 'Github Item ID'
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
  t.varchar :type, comment: 'ファイルタイプ'
  t.varchar :sha
  t.varchar :url
  t.foreign_key 'input_project_id', reference: 'input_projects', reference_column: 'id'

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'input_contents', collate: 'utf8_bin', comment: '入力元_プロジェクト_コンテンツ' do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment
  t.int :input_project_id, comment: 'Input project id'

  t.varchar :path, comment: 'ファイルパス'
  t.varchar :sha
  t.varchar :url
  t.text :content, comment: 'ファイル内容'
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

create_table 'schema_migrations', collate: 'utf8_bin', comment: '' do |t|
  t.varchar 'version'

  t.index 'version', name: 'unique_schema_migrations', unique: true
end
