class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category, null: false
      t.string :title, null: false
      t.text :body
      t.jsonb :payload, null: false, default: {}
      t.datetime :read_at
      t.datetime :created_at, null: false
    end

    add_index :notifications, [ :user_id, :read_at ]
  end
end
