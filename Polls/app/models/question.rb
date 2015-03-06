# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  poll_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Question < ActiveRecord::Base
  validates :body, :poll_id, presence: true

  belongs_to(:poll,
    foreign_key: :poll_id,
    primary_key: :id,
    class_name: 'Poll'
  )

  has_many(:answer_choices,
    foreign_key: :question_id,
    primary_key: :id,
    class_name: 'AnswerChoice',
    dependent: :destroy
  )

  has_many(
    :responses,
    through: :answer_choices,
    source: :responses,
    dependent: :destroy
  )

  def results
    # results = {}
    # answer_choices.includes(:responses).each do |answer_choice|
    #   results[answer_choice.body] = answer_choice.responses.length
    # end
    # results
    results = {}
    choices_with_count = answer_choices.select("answer_choices.*, COUNT(responses.id) AS response_count")
                  .joins('LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id')
                  .where("answer_choices.question_id = ?", self.id)
                  .group("answer_choices.id")
    choices_with_count.each do |choice|
      results[choice.body] = choice.response_count
    end
    results
  end
end

#
# SELECT
#   answer_choices.*, COUNT(responses.id)
# FROM
#   answer_choices
# LEFT OUTER JOIN
#   responses ON responses.answer_choice_id = answer_choices.id
# WHERE
#   answer_choices.question_id = #{id}
# GROUP BY
#   answer_choices.id
