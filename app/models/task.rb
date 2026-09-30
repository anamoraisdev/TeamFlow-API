class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true

  enum :status, { pending: 0, in_progress: 1, done: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validate :assignee_must_belong_to_project_team

  after_update_commit :notify_assignee_change, if: :saved_change_to_assignee_id?

  private

  def notify_assignee_change
    TaskAssignmentNotifierJob.perform_later(id) if assignee_id.present?
  end

  def assignee_must_belong_to_project_team
    return if assignee.nil? || project.nil?

    unless project.team.users.exists?(id: assignee_id)
      errors.add(:assignee, "must be a member of the project's team")
    end
  end
end
