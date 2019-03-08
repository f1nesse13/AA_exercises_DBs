require "activesupport/inflector"

class ModelBase
  def self.table
    self.to_s.tableize
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT * FROM #{table} WHERE id = :id
    SQL
    data.nil? ? nil : self.new(data)
  end

  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM #{table}
    SQL
    data.empty? ? nil : map_data(data)
  end

  def attrs
    attrs_hash = Hash.new
    instance_variables.each do |var|
      attrs_hash[var.to_s[1..-1]] = instance_variable_get(var)
    end
    attrs_hash
  end

  def save
    self.id.nil? create : update
  end

  def create
    raise "Already exists in table" unless id.nil?

    instance_vars = attrs
    instance_vars.delete("id")
    columns = instance_vars.keys.join(", ")
    question_marks = (["?"] * instance_vars.count).join(", ")
    values = instance_vars.values
    QuestionsDatabase.instance.execute(<<-SQL, *values)
      INSERT INTO 
      #{self.class.table} (#{columns})
      VALUES
      (#{question_marks})
      SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "Entry does not exist" if id.nil?
    instance_vars = attrs
    instance_vars.delete("id")
    set_keys = instance_vars.keys.map { |var| "#{var} = ?" }.join(", ")
    values = instance_vars.values
    QuestionsDatabase.instance.execute(<<-SQL, *values, id)
    UPDATE TABLE #{self.class.table}
    SET
      #{set_keys}
    WHERE
      id = ?
    SQL
    self
  end

  def self.where(options)
    if options.is_a?(Hash)
      where_vals = options.keys.map { |val| "#{val} = ?" }.join(" AND ") 
      vals = options.values
    else
      where_vals = options
      vals = []
    end
    data = QuestionsDatabase.instance.execute(<<-SQL, *vals)
    SELECT * FROM #{self.class.table}
    WHERE #{where_vals}
    SQL
    map_data(data)
  end

  def self.find_by(options)
    self.where(options)
  end

  def self.map_data(data)
    data.map { |datum| self.new(datum) }
  end
end
