class MembershipRoleChangeNotifierJob < ApplicationJob
  queue_as :default

  def perform(team_membership_id, previous_role)
    membership = TeamMembership.find_by(id: team_membership_id)
    return unless membership

    Notification.create!(
      user: membership.user,
      category: "membership_role_changed",
      title: "Your role in #{membership.team.name} changed",
      body: "Your role changed from #{previous_role} to #{membership.role}.",
      payload: { team_id: membership.team_id, from: previous_role, to: membership.role }
    )
  end
end
