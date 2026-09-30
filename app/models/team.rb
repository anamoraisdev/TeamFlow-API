class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  has_many :projects, dependent: :destroy
  has_many :audit_logs, dependent: :destroy

  validates :name, presence: true

  def owner
    team_memberships.find_by(role: :owner)&.user
  end
end
