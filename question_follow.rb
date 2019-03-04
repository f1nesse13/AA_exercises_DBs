require_relative 'questions_database'
require_relative 'user'
require_relative 'question'

class QuestionFollow

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT question_follows.* FROM question_follows WHERE question_follows.id = :id
    SQL
    data.nil? ? nil : data.map { |datum| QuestionFollow.new(datum) }
  end 

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end