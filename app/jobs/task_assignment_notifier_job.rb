class TaskAssignmentNotifierJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task&.assignee

    Notification.create!(
      user: task.assignee,
      category: "task_assigned",
      title: "You were assigned to \"#{task.title}\"",
      body: "In project #{task.project.name}.",
      payload: { task_id: task.id, project_id: task.project_id }
    )
  end
end
