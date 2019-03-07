require_relative "questions_database"
require_relative "user"
require_relative "question"
require_relative "reply"
require_relative "question_like"

class QuestionFollow
  attr_reader :id, :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT question_follows.* FROM question_follows WHERE question_follows.id = :id
    SQL
    data.empty? ? nil : data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: question_id)
    SELECT users.* FROM users JOIN question_follows ON question_follows.user_id = users.id
    WHERE question_follows.question_id = :id
    SQL
    data.empty? ? nil : data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: user_id)
    SELECT questions.* FROM questions JOIN question_follows ON question_follows.question_id = questions.id
    WHERE question_follows.user_id = :id
    SQL
    data.empty? ? nil : data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n: n)
    SELECT DISTINCT questions.* FROM questions JOIN question_follows ON question_follows.question_id = questions.id GROUP BY questions.id ORDER BY COUNT(question_follows.question_id) DESC LIMIT :n
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed
    QuestionFollow.most_followed_questions(1)
  end

  def initialize(options)
    @id = options["id"]
    @user_id = options["user_id"]
    @question_id = options["question_id"]
  end
end
