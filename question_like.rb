require_relative 'questions_database'
require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'


class QuestionLike
  attr_accessor :id, :user_id, :question_id
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT question_likes.* FROM question_likes WHERE question_likes.id = :id
    SQL
    data.empty? ? nil : data.map { |datum| QuestionLike.new(datum) }
  end 

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
    SELECT DISTINCT users.* FROM question_likes JOIN users on users.id = question_likes.user_id JOIN questions ON questions.id = question_likes.question_id WHERE questions.id = :question_id GROUP BY question_likes.user_id
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
    SELECT DISTINCT COUNT(DISTINCT question_likes.user_id) AS likes FROM question_likes JOIN questions on questions.id = question_likes.question_id WHERE questions.id = :question_id GROUP BY question_likes.question_id
    SQL
    data.first['likes']
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end