class SubID
  class ID
    attr_reader :name
    attr_reader :start
    attr_reader :end
    attr_reader :length

    def initialize(line)
      parts = line.split(':')
      raise parts unless parts.size == 3
      @length = parts.pop
      @start = parts.pop
      @end = @start + @length
      @name = parts.pop
    end

    def to_s
      [@name, @start, @length].join(':')
    end
  end

  class << self
    attr_reader :path

    def path_to_config(new_path)
      @path = new_path
    end

    def ids
      ids = File.read(path).split("\n")
      ids.collect!(&:strip)
      ids.collect! { |x| x.empty? ? nil : ID.new(x) }
      ids.uniq.compact
    end

    def set(name, start, length = 65_536)
      entry = [name, start, length].join(':')
      if ids.any? { |x| x.name == name }
        data = File.read(path)
        File.write(path, data.gsub(/^#{name}:.+$/, entry))
        return
      end
      File.open(path, 'a') { |f| f.puts(entry) }
    end
  end
end

class SubUID < SubID
  path_to_config '/etc/subuid'
end

class SubGID < SubID
  path_to_config '/etc/subgid'
end
