# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  author_id  :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Poll < ActiveRecord::Base
  validates :title, :author_id, presence: true


  belongs_to(:author,
    foreign_key: :author_id,
    primary_key: :id,
    class_name: 'User'
  )

  has_many(:questions,
    foreign_key: :poll_id,
    primary_key: :id,
    class_name: 'Question',
    dependent: :destroy
  )

end
