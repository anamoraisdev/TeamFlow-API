class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 0
      t.date :due_date
      t.references :assignee, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :tasks, :status
    add_index :tasks, :priority
  end
end
