require_relative "questions_database"
require_relative "user"
require_relative "question_follow"
require_relative "reply"
require_relative "question_like"
require_relative "model_base"

class Question < ModelBase
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT questions.* FROM questions WHERE questions.id = :id
    SQL
    data.empty? ? nil : Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: author_id)
      SELECT questions.* FROM questions WHERE questions.author_id = :id
      SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def attrs
    { id: id, title: title, body: body, author_id: author_id }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, title: @title, body: @body, author: @author_id)
        INSERT INTO questions (title, body, author)
        VALUES (:title, :body, :author)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, title: @title, body: @body, author: @author_id, id: @id)
      UPDATE questions
      SET
      @title = :title,
      @body = :body,
      @author_id = :author
      WHERE @id = :id
      SQL
    end
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, id: author_id)
        SELECT fname, lname FROM users WHERE id = :id
      SQL
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
end
