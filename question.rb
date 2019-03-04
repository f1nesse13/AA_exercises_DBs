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
    data.nil? ? nil : data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end


end