# Runs async (Solid Queue) so creating an invitation doesn't block the
# request on writing the recipient's notification.
class InvitationNotifierJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    invitation = Invitation.find_by(id: invitation_id)
    return unless invitation

    recipient = User.find_by(email: invitation.invited_email)
    return unless recipient

    Notification.create!(
      user: recipient,
      category: "invitation_received",
      title: "You've been invited to join #{invitation.team.name}",
      body: "#{invitation.invited_by.name} invited you to join #{invitation.team.name} as #{invitation.role}.",
      payload: { invitation_id: invitation.id, team_id: invitation.team_id }
    )
  end
end
