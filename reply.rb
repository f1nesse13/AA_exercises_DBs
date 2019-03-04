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
    data.nil? ? nil : data.map { |datum| Reply.new(datum) }
  end 

  def initialize(options)
    @id = options['id']
    @author_id = options['author_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
  end

end