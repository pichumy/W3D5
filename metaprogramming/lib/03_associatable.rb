require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.constantize
  end

  def table_name
    # ...
    @class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
      @foreign_key = options[:foreign_key] || "#{name.downcase}_id".to_sym
      @primary_key = options[:primary_key] || :id
      @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
      @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
      @primary_key = options[:primary_key] || :id
      @class_name = options[:class_name] || name.capitalize.singularize
  end
end

# belongs to :name, primary_key: :id, foreign_key: :other_class_id, class_name: :other_class_name
# SELECT OTHER_TABLE.* from OWN_TABLE JOIN ON FOREIGN_TABLE ON FOREIGN_KEY = FOREIGN_TABLE_PRIMARY_KEY
# WHERE FOREIGN_KEY = FOREIGN_TABLE_PRIMARY_KEY

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    # p self.table_name
    # # p name.table_name
    #
    # p "#{self.table_name}.#{options[:foreign_key]}"
    # p "#{self.send(options[:foreign_key])}"
    object = BelongsToOptions.new(name, options)
    p object.table_name
    p self.name
    p object.model_class
    p object
    DBConnection.execute(<<-SQL)
      SELECT
        #{name}s.*
      FROM
        #{object.table_name}
      JOIN
        #{self.name.downcase}s
      ON
        #{self.name.downcase}s.#{object.foreign_key} = #{name}s.id
      -- WHERE
      --   #{name}s.id = ?
    SQL
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
