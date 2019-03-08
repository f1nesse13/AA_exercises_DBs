require_relative "questions_database"
require_relative "user"
require_relative "question"
require_relative "question_like"
require_relative "question_follow"
require_relative "model_base"

class Reply < ModelBase
  attr_accessor :author_id, :question_id, :parent_reply_id, :body
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT replies.* FROM replies WHERE replies.id = :id
    SQL
    data.empty? ? nil : data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: author_id)
    SELECT replies.* FROM replies WHERE replies.author_id = :id
    SQL
    data.empty? ? nil : data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: question_id)
    SELECT replies.* FROM replies WHERE replies.question_id = :id
    SQL
    data.empty? ? nil : data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options["id"]
    @author_id = options["author_id"]
    @question_id = options["question_id"]
    @parent_reply_id = options["parent_reply_id"]
    @body = options["body"]
  end

  def attrs
    { id: id, author_id: author_id, question_id: question_id, parent_reply_id: parent_reply_id, body: body }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, author: @author_id, question: @question_id, parent: @parent_reply_id, body: @body)
        INSERT INTO replies (author_id, question_id, parent_reply_id, body)
        VALUES (:author, :question, :parent, :body)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, id: @id, author: @author_id, question: @question_id, parent: @parent_reply_id, body: @body)
      UPDATE replies
      SET
      author_id = :author,
      question_id = :question,
      parent_reply_id = :parent,
      body = :body
      WHERE
      id = :id
      SQL
    end
  end

  def author
    Question.find_by_author_id(author_id)
  end

  def question
    Question.find_by_id(id)
  end

  def parent_reply
    Reply.find_by_id(parent_reply_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT * FROM replies WHERE parent_reply_id = :id
    SQL
    data.map { |datum| Reply.new(datum) }
  end
end
