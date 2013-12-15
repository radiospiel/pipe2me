require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord" rescue nil

module Controllers
  class Base < Sinatra::Base
  end
end


class Controllers::Base < Sinatra::Base
  if defined?(Sinatra::ActiveRecordExtension)
    register Sinatra::ActiveRecordExtension
    set :database, DATABASE_URL
  end

  # -- The sourcefile setting is used to load views relative to the
  #    controller's sourcefile(s).
  set :sourcefile, nil

  # return the path for the views. As views should be stored next
  # to the controller we try to find the controller's main source.
  set :views do
    if(!self.sourcefile)
      raise "sourcefile missing (add 'set :sourcefile, __FILE__' in your controller)"
    end
    File.dirname self.sourcefile
  end

  # -- development configuration ----------------------------------------------

  configure :development do
    # reload sources
    register Sinatra::Reloader
    also_reload "#{ROOT}/app/models/**/*"
    also_reload "#{ROOT}/lib/**/*"

    # reload translations
    if defined?(I18n)
      before do
        I18n.backend.reload!
      end
    end
  end

  # -- layout setting ---------------------------------------------------------
  set :layout, "application"

  # see also http://hawkins.io/2013/06/error-handling-in-sinatra-apis/

  # -- error handling ---------------------------------------------------------

  set :dump_errors, true
  set :show_exceptions, false

  helpers do
    def render_error(code, msg=nil)
      e = env['sinatra.error']
      msg ||= unless self.class.development?
        "#{e.message}"
      else
        "#{e.class.name}: #{e.message}"
      end

      if self.class.development?
        msg.concat "\n\nfrom #{e.backtrace.join("\n     ")}"
        msg = "== ERROR #{code} ================================\n\n#{msg}"
      end

      content_type :text
      status code

      msg
    end
  end

  error do
    render_error 500
  end

  error ActiveRecord::RecordNotFound do
    render_error 404
  end
end
