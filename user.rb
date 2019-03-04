require_relative 'questions_database'

class User

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT users.* FROM users WHERE users.id = :id
    SQL
    data.nil? ? nil : data.map { |datum| User.new(datum) }
  end 

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  
end