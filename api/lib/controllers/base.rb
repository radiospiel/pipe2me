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

    # reload translations
    if defined?(I18n)
      before do
        I18n.backend.reload!
      end
    end
  end

  # -- layout setting ---------------------------------------------------------
  set :layout, "application"
end

require_relative "./auto_renderer"
