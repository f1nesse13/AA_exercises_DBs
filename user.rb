require_relative "questions_database"
require_relative "question"
require_relative "question_follow"
require_relative "reply"
require_relative "question_like"
require_relative "model_base"

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT users.* FROM users WHERE users.id = ?
    SQL
    data.empty? ? nil : User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname: fname, lname: lname)
    SELECT users.* FROM users WHERE users.fname = :fname AND users.lname = :lname
    SQL
    data.empty? ? nil : User.new(data.first)
  end

  def initialize(options = {})
    @id, @fname, @lname = options["id"], options["fname"], options["lname"]
  end

  def attrs
    { id: id, fname: fname, lname: lname }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, fname: @fname, lname: @lname)
        INSERT INTO users (fname, lname)
        VALUES (:fname, :lname)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname: @fname, lname: @lname, id: @id)
      UPDATE users
      SET
      fname = :fname,
      lname = :lname
      WHERE id = :id
      SQL
    end
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT CAST(COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT questions.id) AS karma FROM questions LEFT OUTER JOIN question_likes ON questions.id = question_likes.question_id WHERE questions.author_id = ?
    SQL
    data.first["karma"]
  end
end
