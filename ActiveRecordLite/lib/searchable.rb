require_relative 'db_connection'

module Searchable
  def where(params)
    where_line = params.keys.map{ |k| "#{k} = ?" }.join(' AND ')
    self.parse_all(DBConnection.execute(<<-SQL,*params.values))
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL
  end
end
