create_table "input_projects", collate: "utf8_bin", comment: "入力元_プロジェクト_基本情報" do |t|
  t.int :id, comment: 'Id', primary_key: true, extra: :auto_increment

  t.int :github_item_id, comment: "Github Item ID"
  t.int :name
  t.int :full_name
  t.int :owner_id
  t.varchar :owner_login_name
  t.varchar :owner_type, limit: 30
  t.varchar :github_url
  t.boolean :is_fork, default: false
  t.text :github_description, null: true
  t.datetime :github_created_at
  t.datetime :github_updated_at
  t.datetime :github_pushed_at
  t.text :homepage, null: true
  t.int :size, default: 0
  t.int :stargazers_count, default: 0, comment: "スター数"
  t.int :watchers_count, default: 0, comment: "ウォッチャー数"
  t.int :fork_count, default: 0, comment: "フォーク数"
  t.int :open_issue_count, default: 0, comment: "イシュー数"
  t.varchar :github_score, default: "", comment: "Github上のスコア"
  t.varchar :language, default: ""

  t.datetime :created_at
  t.datetime :updated_at
end

create_table 'schema_migrations', collate: 'utf8_bin', comment: '' do |t|
  t.varchar 'version'

  t.index 'version', name: 'unique_schema_migrations', unique: true
end
