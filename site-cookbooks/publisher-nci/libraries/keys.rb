module KeyBag
  def self.load(id)
    data_bag_path = Chef::Config[:data_bag_path]
    keys = File.join(data_bag_path, 'publisher-nci', 'keys')
    data = File.read(File.join(keys, id))
    data.gsub($/, '/n')
    data
  end
end
