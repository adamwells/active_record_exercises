# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
Poll.destroy_all
Question.destroy_all
AnswerChoice.destroy_all
Response.destroy_all


cj = User.create!(user_name: 'CJ')
jeff = User.create!(user_name: 'Jeff')
ryan = User.create!(user_name: 'Ryan')

poll = Poll.create!(title: 'Favorite food?', author_id: cj.id)
question = Question.create!(body: 'What is your favorite food?', poll_id: poll.id)
choice1 = AnswerChoice.create!(body: 'Pizza', question_id: question.id)
choice2 = AnswerChoice.create!(body: 'Soup', question_id: question.id)

response1 = Response.create!(user_id: jeff.id, answer_choice_id: choice1.id)
response1 = Response.create!(user_id: ryan.id, answer_choice_id: choice2.id)

# create users
50.times do |i|
  User.create!(user_name: "Student #{i}")
end

10.times do |i|
  author_id = [1,2,3].sample
  Poll.create!(title: "Poll # #{i}", author_id: author_id)
end

10.times do |i|
  poll_id = (2...10).to_a.sample
  Question.create!(body: "Random text #{i}", poll_id: poll_id)
end

20.times do |i|
  question_id = (1...10).to_a.sample
  AnswerChoice.create!(body: "Choice #{i}", question_id: question_id)
end

4.upto(50) do |i|

  user_id = i
  answer_choice_id = (1...20).to_a.sample
  Response.create!(user_id: user_id, answer_choice_id: answer_choice_id)
end


david = User.create!(user_name: 'david')
Response.create!(user_id: david.id, answer_choice_id: 1)
