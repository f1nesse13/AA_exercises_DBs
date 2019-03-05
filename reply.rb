require_relative 'questions_database'
require_relative 'user'
require_relative 'question'
require_relative 'question_like'
require_relative 'question_follow'


class Reply
  attr_accessor :id, :author_id, :question_id, :parent_reply_id, :body
  
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
    @id = options['id']
    @author_id = options['author_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
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
    data.map { |datum| Reply.new(datum)}
  end
    
end