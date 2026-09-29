# Seed data for local development.
#
# Creates two teams with a mix of owner/admin/member roles, a project in
# each, and tasks spread across statuses/priorities/assignees so filtering
# and pagination have something realistic to work against.
#
# Usage: bin/rails db:seed (safe to run more than once)

puts "Seeding development data..."

users = [
  { name: "Ana Moraes", email: "ana@teamflow.dev" },
  { name: "Bruno Silva", email: "bruno@teamflow.dev" },
  { name: "Carla Souza", email: "carla@teamflow.dev" },
  { name: "Diego Santos", email: "diego@teamflow.dev" }
].map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.name = attrs[:name]
    user.password = "password123"
  end
end

ana, bruno, carla, diego = users

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

puts "Done. Sample login: ana@teamflow.dev / password123"
