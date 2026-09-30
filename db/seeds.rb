# Seed data for local development.
#
# Creates two teams with a mix of owner/admin/member roles, a project in
# each, tasks spread across statuses/priorities/assignees, and a few
# invitations/notifications/audit log entries so the newer endpoints have
# something realistic to work against too.
#
# Usage: bin/rails db:seed (safe to run more than once)

puts "Seeding development data..."

users = [
  { name: "Ana Moraes", email: "ana@teamflow.dev" },
  { name: "Bruno Silva", email: "bruno@teamflow.dev" },
  { name: "Carla Souza", email: "carla@teamflow.dev" },
  { name: "Diego Santos", email: "diego@teamflow.dev" },
  { name: "Elena Costa", email: "elena@teamflow.dev" }
].map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.name = attrs[:name]
    user.password = "password123"
  end
end

ana, bruno, carla, diego, elena = users

engineering = Team.find_or_create_by!(name: "Engineering")
TeamMembership.find_or_create_by!(team: engineering, user: ana) { |m| m.role = :owner }
TeamMembership.find_or_create_by!(team: engineering, user: bruno) { |m| m.role = :admin }
TeamMembership.find_or_create_by!(team: engineering, user: carla) { |m| m.role = :member }

marketing = Team.find_or_create_by!(name: "Marketing")
TeamMembership.find_or_create_by!(team: marketing, user: diego) { |m| m.role = :owner }
TeamMembership.find_or_create_by!(team: marketing, user: ana) { |m| m.role = :member }

api_revamp = Project.find_or_create_by!(team: engineering, name: "API Revamp") do |project|
  project.description = "Rebuild the internal API with proper versioning and auth."
end

landing_page = Project.find_or_create_by!(team: marketing, name: "Landing Page Launch") do |project|
  project.description = "New landing page for the Q4 campaign."
end

tasks = [
  { project: api_revamp, title: "Design database schema", status: :done, priority: :high, assignee: ana, due_date: 3.days.ago },
  { project: api_revamp, title: "Implement authentication", status: :in_progress, priority: :high, assignee: bruno, due_date: 2.days.from_now },
  { project: api_revamp, title: "Write request specs", status: :pending, priority: :medium, assignee: carla, due_date: 5.days.from_now },
  { project: api_revamp, title: "Set up CI pipeline", status: :pending, priority: :low, assignee: nil, due_date: nil },
  { project: landing_page, title: "Draft copy", status: :done, priority: :medium, assignee: diego, due_date: 1.day.ago },
  { project: landing_page, title: "Review with stakeholders", status: :in_progress, priority: :high, assignee: ana, due_date: 1.day.from_now },
  { project: landing_page, title: "Schedule launch email", status: :pending, priority: :low, assignee: nil, due_date: 7.days.from_now }
]

tasks.each do |attrs|
  Task.find_or_create_by!(project: attrs[:project], title: attrs[:title]) do |task|
    task.status = attrs[:status]
    task.priority = attrs[:priority]
    task.assignee = attrs[:assignee]
    task.due_date = attrs[:due_date]
  end
end

pending_invitation = Invitation.find_or_create_by!(team: engineering, invited_email: elena.email) do |invitation|
  invitation.invited_by = bruno
  invitation.role = :member
end

declined_invitation = Invitation.find_or_create_by!(team: marketing, invited_email: carla.email) do |invitation|
  invitation.invited_by = diego
  invitation.role = :member
end
declined_invitation.decline! if declined_invitation.pending?

Notification.find_or_create_by!(user: elena, category: "invitation_received") do |notification|
  notification.title = "You've been invited to join #{engineering.name}"
  notification.body = "#{bruno.name} invited you to join #{engineering.name} as member."
  notification.payload = { invitation_id: pending_invitation.id, team_id: engineering.id }
end

Notification.find_or_create_by!(user: carla, category: "task_assigned") do |notification|
  notification.title = "You were assigned to \"Write request specs\""
  notification.body = "In project #{api_revamp.name}."
  notification.read_at = 1.day.ago
  notification.payload = { project_id: api_revamp.id }
end

[
  { team: engineering, user: ana, action: "team.updated", auditable: engineering },
  { team: engineering, user: bruno, action: "invitation.created", auditable: pending_invitation,
    metadata: { invited_email: elena.email, role: "member" } },
  { team: marketing, user: diego, action: "invitation.declined", auditable: declined_invitation }
].each do |attrs|
  AuditLogger.record(**attrs) unless AuditLog.exists?(team: attrs[:team], action: attrs[:action], auditable: attrs[:auditable])
end

puts "Done. Sample login: ana@teamflow.dev / password123"
