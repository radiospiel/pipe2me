require "shell_format"

class Controllers::InspectSh < Controllers::Base
  helpers ShellFormat

  get "/" do
    config = request.env.select { |key,v| key !~ /[a-z]/ }
    shell(config, "PIPE2ME")
  end
end
