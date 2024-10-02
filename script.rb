# frozen_string_literal: true

class Connection
  attr_reader :id

  def initialize(id)
    @id = id
    @in_use = false
  end

  def use
    @in_use = true
  end

  def release
    @in_use = false
  end

  def in_use?
    @in_use
  end
end

class ConnectionPool
  def initialize(size)
    @pool = Array.new(size) { |i| Connection.new(i) }
    @available_connections = @pool.dup
  end

  def acquire
    raise "No available connections" if @available_connections.empty?

    conn = @available_connections.pop
    conn.use
    conn
  end

  def release(conn)
    conn.release
    @available_connections.push(conn) unless @available_connections.include?(conn)
  end
end

# Приклад використання
pool = ConnectionPool.new(3)

# отримаємо з'єднення
conn1 = pool.acquire
puts "Acquired connection ID: #{conn1.id}"

conn2 = pool.acquire
puts "Acquired connection ID: #{conn2.id}"

# повертаємо
pool.release(conn1)
puts "Released connection ID: #{conn1.id}"

conn3 = pool.acquire
puts "Acquired connection ID: #{conn3.id}"

# можемо спробувати отримати з'єднання, якщо немає достуних
begin
  conn4 = pool.acquire
  puts "Acquired connection ID: #{conn4.id}"
rescue => e
  puts e.message
end

pool.release(conn2)
pool.release(conn3)

puts "All connections released."
