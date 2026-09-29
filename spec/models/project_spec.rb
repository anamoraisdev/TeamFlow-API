require "rails_helper"

RSpec.describe Project, type: :model do
  it "has a valid factory" do
    expect(build(:project)).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:team) }

  it "destroys dependent tasks when destroyed" do
    project = create(:project)
    create(:task, project: project)

    expect { project.destroy }.to change(Task, :count).by(-1)
  end
end
