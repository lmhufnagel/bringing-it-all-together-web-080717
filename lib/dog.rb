class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end


  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

def self.new_from_db(row)
  new_dog = Dog.new(name: row[0], breed: row[1], id: row[2]) # self.new is the same as running Song.new
  new_dog.id = row[0]
  new_dog.name =  row[1]
  new_dog.breed = row[2]
  new_dog  # return the newly created instance
end

  #  def self.find_by_id(id)
  #   sql = "SELECT * FROM dogs WHERE id = ?"
  #   result = DB[:conn].execute(sql, id)[0]
  #   Dog.new(result[0], result[1], result[2])
  #   self
  # end

   def self.find_by_id(id)
     sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE id = ?
       LIMIT 1
     SQL

     DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
   end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


   def self.find_or_create_by(hash)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed]).first

     if dog
       dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0] )

    else
      dog = self.create(name: hash[:name], breed: hash[:breed])
    end
    dog
  end

  def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end


end
