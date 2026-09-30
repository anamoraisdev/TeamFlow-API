class User < ApplicationRecord
  has_secure_password

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify
  has_many :notifications, dependent: :destroy

  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_FORMAT }
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_save { email.downcase! }

  def role_in(team)
    team_memberships.find_by(team: team)&.role
  end
end
