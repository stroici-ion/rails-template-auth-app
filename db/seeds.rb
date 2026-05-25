# 1. Clear existing data to prevent duplicates
puts "Cleaning database..."
TaskAssignment.destroy_all
Task.destroy_all
Project.destroy_all
TeamMembership.destroy_all
Team.destroy_all

# 2. Create a Team
team = Team.create!(
  name: "Horizon Design Team",
  description: "Core team for the Horizon productivity suite."
)

# 3. Create a Project
project = Project.create!(
  name: "Mobile App Launch",
  description: "Phase 1 of the Horizon mobile rollout.",
  color_code: "#6366f1", # Indigo
  status: "active",
  team: team
)

# 4. Create Parent Tasks
puts "Creating parent tasks..."
design_task = Task.create!(
  title: "Design System Updates",
  description: "Update the primary color palette and component library.",
  status: "in_progress",
  start_date: DateTime.now,
  due_date: DateTime.now + 5.days,
  project: project,
  parent_id: nil
)

marketing_task = Task.create!(
  title: "Marketing Campaign",
  description: "Prepare assets for the Product Hunt launch.",
  status: "todo",
  start_date: DateTime.now + 2.days,
  due_date: DateTime.now + 10.days,
  project: project,
  parent_id: nil
)

analytics_task = Task.create!(
  title: "Set up Analytics",
  description: "Integrate Mixpanel and Segment.",
  status: "todo",
  start_date: DateTime.now + 1.day,
  due_date: DateTime.now + 3.days,
  project: project,
  parent_id: nil
)

# 5. Create Subtasks (Infinite nesting potential)
puts "Creating subtasks..."
Task.create!(
  title: "Export Icon Set",
  description: "Export all Lucide icons as SVGs.",
  status: "done",
  start_date: DateTime.now,
  due_date: DateTime.now + 1.day,
  project: project,
  parent: design_task # This sets parent_id automatically
)

Task.create!(
  title: "Review Accessibility Contrast",
  description: "Ensure all new indigo shades meet WCAG AA standards.",
  status: "in_progress",
  start_date: DateTime.now + 1.day,
  due_date: DateTime.now + 2.days,
  project: project,
  parent: design_task
)

puts "Seeding complete! Created #{Project.count} project and #{Task.count} tasks."