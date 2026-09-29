class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user

  enum :role, { member: 0, admin: 1, owner: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :team_id, message: "is already a member of this team" }
  validate :only_one_owner_per_team

  private

  def only_one_owner_per_team
    return unless owner?

    existing_owner = team&.team_memberships&.where(role: :owner)&.where&.not(id: id)&.exists?
    errors.add(:role, "already has an owner") if existing_owner
  end
end
