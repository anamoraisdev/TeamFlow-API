class AddUniqueIndexForTeamOwner < ActiveRecord::Migration[8.1]
  def change
    # The app-level "only_one_owner_per_team" validation (TeamMembership) is
    # race-prone under concurrent requests; this index makes the guarantee a
    # real DB constraint. role 2 == "owner".
    add_index :team_memberships, :team_id, unique: true,
      where: "role = 2", name: "index_team_memberships_on_team_id_when_owner"
  end
end
