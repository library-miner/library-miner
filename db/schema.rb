# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "input_branches", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4,   null: false
    t.string   "name",             limit: 255, null: false
    t.string   "sha",              limit: 255, null: false
    t.string   "url",              limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "input_branches", ["input_project_id"], name: "input_branches_input_project_id_fk", using: :btree

  create_table "input_contents", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4,     null: false
    t.string   "path",             limit: 255,   null: false
    t.string   "sha",              limit: 255,   null: false
    t.text     "content",          limit: 65535, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "input_contents", ["input_project_id"], name: "input_contents_input_project_id_fk", using: :btree

  create_table "input_dependency_libraries", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4,   null: false
    t.string   "name",             limit: 255, null: false
    t.string   "version",          limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "input_dependency_libraries", ["input_project_id"], name: "input_dependency_libraries_input_project_id_fk", using: :btree

  create_table "input_libraries", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4
    t.string   "name",             limit: 255, null: false
    t.string   "version",          limit: 255
    t.string   "homepage_uri",     limit: 255
    t.string   "source_code_uri",  limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "input_libraries", ["input_project_id"], name: "input_libraries_input_project_id_fk", using: :btree

  create_table "input_projects", force: :cascade do |t|
    t.integer  "crawl_status_id",    limit: 4,     default: 0,     null: false
    t.integer  "github_item_id",     limit: 8,                     null: false
    t.integer  "client_node_id",     limit: 4
    t.string   "name",               limit: 255,                   null: false
    t.string   "full_name",          limit: 255,                   null: false
    t.integer  "owner_id",           limit: 8,                     null: false
    t.string   "owner_login_name",   limit: 255,                   null: false
    t.string   "owner_type",         limit: 30,                    null: false
    t.string   "github_url",         limit: 255,                   null: false
    t.boolean  "is_fork",                          default: false, null: false
    t.text     "github_description", limit: 65535
    t.datetime "github_created_at",                                null: false
    t.datetime "github_updated_at",                                null: false
    t.datetime "github_pushed_at",                                 null: false
    t.text     "homepage",           limit: 65535
    t.integer  "size",               limit: 8,     default: 0,     null: false
    t.integer  "stargazers_count",   limit: 8,     default: 0,     null: false
    t.integer  "watchers_count",     limit: 8,     default: 0,     null: false
    t.integer  "fork_count",         limit: 8,     default: 0,     null: false
    t.integer  "open_issue_count",   limit: 8,     default: 0,     null: false
    t.string   "github_score",       limit: 255,   default: "",    null: false
    t.string   "language",           limit: 255,   default: "",    null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "input_tags", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4,   null: false
    t.string   "name",             limit: 255, null: false
    t.string   "sha",              limit: 255, null: false
    t.string   "url",              limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "input_tags", ["input_project_id"], name: "input_tags_input_project_id_fk", using: :btree

  create_table "input_trees", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4,   null: false
    t.string   "path",             limit: 255, null: false
    t.string   "file_type",        limit: 255, null: false
    t.string   "sha",              limit: 255, null: false
    t.string   "url",              limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "input_trees", ["input_project_id"], name: "input_trees_input_project_id_fk", using: :btree

  create_table "input_weekly_commit_counts", force: :cascade do |t|
    t.integer  "input_project_id", limit: 4, null: false
    t.integer  "index",            limit: 4, null: false
    t.integer  "all_count",        limit: 4, null: false
    t.integer  "owner_count",      limit: 4, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "input_weekly_commit_counts", ["input_project_id"], name: "input_weekly_commit_counts_input_project_id_fk", using: :btree

  create_table "project_dependencies", force: :cascade do |t|
    t.integer  "project_from_id", limit: 4,   null: false
    t.integer  "project_to_id",   limit: 4
    t.string   "library_name",    limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "projects", force: :cascade do |t|
    t.boolean  "is_incomplete",                    default: true,  null: false
    t.integer  "github_item_id",     limit: 8
    t.string   "name",               limit: 255,                   null: false
    t.string   "full_name",          limit: 255
    t.integer  "owner_id",           limit: 8
    t.string   "owner_login_name",   limit: 255,   default: "",    null: false
    t.string   "owner_type",         limit: 30,    default: "",    null: false
    t.string   "github_url",         limit: 255
    t.boolean  "is_fork",                          default: false, null: false
    t.text     "github_description", limit: 65535
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "github_pushed_at"
    t.text     "homepage",           limit: 65535
    t.integer  "size",               limit: 8,     default: 0,     null: false
    t.integer  "stargazers_count",   limit: 8,     default: 0,     null: false
    t.integer  "watchers_count",     limit: 8,     default: 0,     null: false
    t.integer  "fork_count",         limit: 8,     default: 0,     null: false
    t.integer  "open_issue_count",   limit: 8,     default: 0,     null: false
    t.string   "github_score",       limit: 255,   default: "",    null: false
    t.string   "language",           limit: 255,   default: "",    null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "projects", ["github_item_id"], name: "index_projects_on_github_item_id", unique: true, using: :btree

  add_foreign_key "input_branches", "input_projects", name: "input_branches_input_project_id_fk"
  add_foreign_key "input_contents", "input_projects", name: "input_contents_input_project_id_fk"
  add_foreign_key "input_dependency_libraries", "input_projects", name: "input_dependency_libraries_input_project_id_fk"
  add_foreign_key "input_libraries", "input_projects", name: "input_libraries_input_project_id_fk"
  add_foreign_key "input_tags", "input_projects", name: "input_tags_input_project_id_fk"
  add_foreign_key "input_trees", "input_projects", name: "input_trees_input_project_id_fk"
  add_foreign_key "input_weekly_commit_counts", "input_projects", name: "input_weekly_commit_counts_input_project_id_fk"
end
