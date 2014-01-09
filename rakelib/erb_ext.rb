class ERB
  def self.process(args)
    args.each do |src, dest|
      erb = ERB.new File.read(src)

      File.open dest, "w" do |io|
        io.write erb.result
      end

      puts "Created #{File.expand_path dest}"
    end
  end
end
