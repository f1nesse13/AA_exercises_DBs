require_relative 'questions_database'
require_relative 'question'
require_relative 'question_follow'
require_relative 'reply'
require_relative 'question_like'
class User
  attr_accessor :id, :fname, :lname

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

  def initialize(options={})
    @id, @fname, @lname = options['id'], options['fname'], options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO users (fname, lname)
      VALUES (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
    UPDATE users
    SET fname = ?, lname = ? WHERE id = ? 
    SQL
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


end