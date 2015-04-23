require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'

class ActiveRecordLite
  extend Associatable
  extend Searchable
  def self.columns
    DBConnection.execute2(<<-SQL)[0].map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self.to_s.tableize}"
  end

  def self.all
    self.parse_all(DBConnection.execute(<<-SQL))
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    hash = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    hash[0].nil? ? nil : self.new(hash[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_sym}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = Array.new(self.class.columns.length) { "?" }.join(',')

    DBConnection.execute(<<-SQL,*attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_string = self.class.columns.map do |attr_name|
      "#{attr_name} = ?"
      end.join(',')
    DBConnection.execute(<<-SQL,*attribute_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_string}
    WHERE
      id = #{self.id}
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
