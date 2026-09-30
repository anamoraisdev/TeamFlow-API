class EnablePgTrgmAndAddSearchIndexes < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm"

    add_index :tasks, :title, using: :gin, opclass: :gin_trgm_ops, name: "index_tasks_on_title_trgm"
    add_index :projects, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_projects_on_name_trgm"
  end
end
