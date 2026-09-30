class Invitation < ApplicationRecord
  class AlreadyProcessedError < StandardError; end
  class ExpiredError < StandardError; end

  belongs_to :team
  belongs_to :invited_by, class_name: "User"

  # Owner is intentionally not an option here — same rule as direct-add
  # memberships (see TeamMembershipsController#reject_owner_role!).
  enum :role, { member: 0, admin: 1 }
  enum :status, { pending: 0, accepted: 1, declined: 2, revoked: 3, expired: 4 }

  validates :invited_email, presence: true, format: { with: User::EMAIL_FORMAT }
  validate :only_one_pending_invitation_per_email, on: :create

  before_validation { self.invited_email = invited_email.downcase if invited_email.present? }
  before_create :generate_token, :set_expires_at

  def accept!(user)
    raise ExpiredError, "invitation has expired" if expired_by_date?
    raise AlreadyProcessedError, "invitation was already #{status}" unless pending?

    transaction do
      begin
        team.team_memberships.create!(user: user, role: role)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        # The membership unique index (team_id, user_id) is the real guarantee
        # here — this only re-raises if the failure wasn't "already a member"
        # (e.g. a losing concurrent accept for the same invitation).
        raise unless team.team_memberships.exists?(user: user)
      end

      # Optimistic locking (lock_version) on this update is what catches a
      # genuine concurrent accept/decline/revoke of the SAME invitation:
      # ActiveRecord::StaleObjectError bubbles up to the controller as a 409.
      update!(status: :accepted)
    end
  end

  def decline!
    raise AlreadyProcessedError, "invitation was already #{status}" unless pending?

    update!(status: :declined)
  end

  def revoke!
    raise AlreadyProcessedError, "invitation was already #{status}" unless pending?

    update!(status: :revoked)
  end

  def expired_by_date?
    expires_at.present? && expires_at.past?
  end

  private

  def only_one_pending_invitation_per_email
    return unless team && invited_email.present?

    existing = team.invitations.where(invited_email: invited_email, status: :pending).exists?
    errors.add(:invited_email, "already has a pending invitation for this team") if existing
  end

  def generate_token
    self.token = SecureRandom.urlsafe_base64(24)
  end

  def set_expires_at
    self.expires_at ||= 7.days.from_now
  end
end
