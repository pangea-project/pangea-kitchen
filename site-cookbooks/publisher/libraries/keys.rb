module KeyBag
  def self.load(user)
    data_bag_path = Chef::Config[:data_bag_path]
    id = File.join(data_bag_path, 'cupboard', "publisher-#{user}", "#{user}.private.key")
    data = File.read(id)
    data.gsub($/, '/n')
    data
  end
end
