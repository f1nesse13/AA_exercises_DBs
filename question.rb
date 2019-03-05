require_relative 'questions_database'
require_relative 'user'
require_relative 'question_follow'
require_relative 'reply'
require_relative 'question_like'

class Question
  attr_accessor :id, :title, :body, :author_id
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

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
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

end