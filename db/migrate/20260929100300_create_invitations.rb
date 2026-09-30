class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :team, null: false, foreign_key: true
      t.string :invited_email, null: false
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.integer :role, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, :invited_email
    add_index :invitations, :status

    # Race-safe guarantee (not just app-validated): a team can only have one
    # pending invitation per email at a time. status 0 == "pending".
    add_index :invitations, [ :team_id, :invited_email ], unique: true,
      where: "status = 0", name: "index_invitations_on_team_id_and_email_when_pending"
  end
end
