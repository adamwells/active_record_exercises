# == Schema Information
#
# Table name: responses
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  answer_choice_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class Response < ActiveRecord::Base
  validates :user_id, :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :respondent_is_not_question_author


  belongs_to(:respondent,
    foreign_key: :user_id,
    primary_key: :id,
    class_name: 'User')

  belongs_to(:answer_choice,
    foreign_key: :answer_choice_id,
    primary_key: :id,
    class_name: 'AnswerChoice')

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  def sibling_responses
    question.responses.load.where.not(id: id)
  end

  def respondent_has_not_already_answered_question
    existing_response = sibling_responses.exists?(user_id: respondent.id)
    if existing_response
      errors[:base] << "You already responded to this question!"
    end
  end

  def respondent_is_not_question_author
    if answer_choice.question.poll.author == respondent
      errors[:base] << "You can't answer your own question!"
    end
  end
end
