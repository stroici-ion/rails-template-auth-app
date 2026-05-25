class Task < ApplicationRecord
  belongs_to :project
  
  # 1. The join table relationship
  has_many :task_assignments, dependent: :destroy
  
  # 2. The "through" relationship that defines 'assignees'
  # We use 'source: :user' because the association is called assignees but points to the User model
  has_many :assignees, through: :task_assignments, source: :user

  # 3. Self-referential associations for subtasks
  belongs_to :parent, class_name: 'Task', optional: true
  has_many :subtasks, class_name: 'Task', foreign_key: :parent_id, dependent: :destroy

  validates :title, presence: true

  scope :by_position, -> { order(Arel.sql('position ASC NULLS LAST')) }
end
