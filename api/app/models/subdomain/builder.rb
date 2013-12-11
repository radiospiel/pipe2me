module Subdomain::Builder
  extend self

  # -- generate names and ports ----------------------------------------------

  private

  def generate_name
    Wordize.wordize(rand(100000)) + ".#{DOMAIN}"
  end

  public

  def choose_name
    3.times do
      name = generate_name
      return name unless Subdomain.where(name: name).first
    end

    8.times do
      name = generate_name
      return name unless Subdomain.where(name: name).first
      name += "-#{rand(10)}"
      return name unless Subdomain.where(name: name).first
    end

    raise "Cannot choose a new name"
  end

  def choose_port
    recs = ActiveRecord::Base.connection.select_all(choose_port_sql)

    port = (recs.first && recs.first["port"]) || PORTS.min
    return port if PORTS.cover?(port)
  end

  def choose_token
    "#{SecureRandom.hex(8)}-#{SecureRandom.hex(8)}"
  end

  private

  def choose_port_sql
    return @choose_port_sql if @choose_port_sql

    conditions = PORTS_PER_SUBDOMAIN.times.map do |idx|
      "port+#{idx} NOT IN (SELECT port FROM subdomains)"
    end

    @choose_port_sql = <<-SQL
      SELECT * FROM (
        SELECT port+#{PORTS_PER_SUBDOMAIN} AS port FROM subdomains
          UNION
        SELECT #{PORTS.min} AS port
      )
      WHERE  #{conditions.join(" AND ")}
      ORDER BY port
      LIMIT 1
    SQL
  end
end
