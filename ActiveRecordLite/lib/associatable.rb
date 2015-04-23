require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name.to_s.singularize}_id".to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.camelcase
    }

    defaults.merge(options).each do |k, v|
      send("#{k}=", v)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore.singularize}_id".to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.camelcase
    }

    defaults.merge(options).each do |k, v|
      send("#{k}=", v)
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      fk = send(self.class.assoc_options[name].foreign_key)
      self.class.assoc_options[name].model_class.where(
        {
          self.class.assoc_options[name].primary_key => fk
        }
      )[0]
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      pk = send(options.primary_key)
      options.model_class.where(options.foreign_key => pk)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      fk = through_options.foreign_key
      model = source_options.model_class
      model.parse_all(DBConnection.execute(<<-SQL, send(fk))).first
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key} =
            #{source_options.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL
    end
  end
end
