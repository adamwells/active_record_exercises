# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string           not null
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  validates :user_name, presence: true, uniqueness: true

  has_many(:authored_polls,
    foreign_key: :author_id,
    primary_key: :id,
    class_name: 'Poll',
    dependent: :destroy
  )

  has_many(:responses,
    foreign_key: :user_id,
    primary_key: :id,
    class_name: 'Response',
    dependent: :destroy
  )

  def completed_polls

    subquery = Response.where('user_id = ?', self.id).to_sql

    Poll.select("polls.*")
         .joins('JOIN questions ON questions.poll_id = polls.id')
         .joins('JOIN answer_choices ON answer_choices.question_id = questions.id')
         .joins("LEFT OUTER JOIN (#{subquery}) AS user_responses ON user_responses.answer_choice_id = answer_choices.id")
         .group("polls.id")
         .having('COUNT(DISTINCT questions.id) = COUNT(user_responses.*)')

    # Poll.find_by_sql([<<-SQL, self.id])
    # SELECT
    #   polls.*, COUNT(DISTINCT questions.id), COUNT(user_responses.*)
    # FROM
    #   polls
    # JOIN
    #   questions ON questions.poll_id = polls.id
    # JOIN
    #   answer_choices ON answer_choices.question_id = questions.id
    # LEFT OUTER JOIN
    #   (
    #     SELECT
    #       responses.*
    #     FROM
    #       responses
    #     WHERE
    #       responses.user_id = 54
    #   ) AS user_responses ON user_responses.answer_choice_id = answer_choices.id
    # GROUP BY
    #   polls.id
    # HAVING
    #   COUNT(DISTINCT questions.id) = COUNT(user_responses.*)
    # SQL

  end

  def uncompleted_polls
    subquery = Response.where('user_id = ?', self.id).to_sql

    Poll.select("polls.*")
         .joins('JOIN questions ON questions.poll_id = polls.id')
         .joins('JOIN answer_choices ON answer_choices.question_id = questions.id')
         .joins("LEFT OUTER JOIN (#{subquery}) AS user_responses ON user_responses.answer_choice_id = answer_choices.id")
         .group("polls.id")
         .having('COUNT(DISTINCT questions.id) > COUNT(user_responses.*) AND COUNT(user_responses.*) > 0')
  end
end
