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
  validate :does_not_respond_to_own_poll

  belongs_to(:respondent,
    foreign_key: :user_id,
    primary_key: :id,
    class_name: 'User'
  )

  belongs_to(:answer_choice,
    foreign_key: :answer_choice_id,
    primary_key: :id,
    class_name: 'AnswerChoice'
  )

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  def sibling_responses
    question.responses.load.where.not(id: id)
  end
  def sibling_responses2
    subquery = Question.select("questions.id")
                       .joins("JOIN answer_choices ON answer_choices.question_id = questions.id")
                       .where("answer_choices.id = ?", self.answer_choice_id).to_sql

    Response.select("responses.*")
            .joins("JOIN answer_choices ON answer_choices.id = responses.answer_choice_id")
            .joins("JOIN questions ON questions.id = answer_choices.question_id")
            .where("questions.id = (#{subquery}) AND responses.id != ?", self.id)

  # SELECT
  #   responses.*
  # FROM
  #   responses
  # JOIN
  #   answer_choices ON answer_choices.id = responses.answer_choice_id
  # JOIN
  #   questions ON questions.id = answer_choices.question_id
  # WHERE
  #   questions.id = (
  #     SELECT
  #       q2.id
  #     FROM
  #       questions q2
  #     JOIN
  #       answer_choices ac ON ac.question_id = q2.id
  #     WHERE
  #       ac.id = 1
  #   )
  #   AND responses.id != 1

  end

  def respondent_has_not_already_answered_question
    existing_response = sibling_responses.exists?(user_id: respondent.id)
    if existing_response
      errors[:base] << "You already responded to this question!"
    end
  end

  def does_not_respond_to_own_poll
    poll = Poll.select('polls.*')
               .joins('JOIN questions ON questions.poll_id = polls.id')
               .joins('JOIN answer_choices ON answer_choices.question_id = questions.id')
               .where('answer_choices.id = ?', answer_choice_id)
               .first

    if poll.author_id == respondent.id
      errors[:base] << "You can't answer your own question!"
    end
  end

  # def does_not_respond_to_own_poll
  #   if answer_choice.question.poll.author == respondent
  #     errors[:base] << "You can't answer your own question!"
  #   end
  # end
end
