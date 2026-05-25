class Project < ApplicationRecord
  belongs_to :team
  has_many :tasks, dependent: :destroy
end
