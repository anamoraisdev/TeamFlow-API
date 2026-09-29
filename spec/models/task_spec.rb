require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to define_enum_for(:status).with_values(pending: 0, in_progress: 1, done: 2) }
  it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }

  it "allows an assignee who belongs to the project's team" do
    team = create(:team)
    project = create(:project, team: team)
    member = create(:user)
    create(:team_membership, team: team, user: member)

    task = build(:task, project: project, assignee: member)

    expect(task).to be_valid
  end

  it "rejects an assignee who does not belong to the project's team" do
    project = create(:project)
    outsider = create(:user)

    task = build(:task, project: project, assignee: outsider)

    expect(task).not_to be_valid
    expect(task.errors[:assignee]).to be_present
  end

  it "allows a task with no assignee" do
    task = build(:task, assignee: nil)
    expect(task).to be_valid
  end
end
