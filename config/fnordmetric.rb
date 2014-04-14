__END__

require_relative "./environment"

FnordMetric.namespace :pipe2me do

  # -- count events -----------------------------------------------------------

  gauge :events_per_hour, :title => "Events per hour", :tick => 1.hour
  gauge :events_per_minute, :title => "Events per minute", :tick => 1.minute
  gauge :events_per_second, :title => "Events per second", :tick => 1.second

  event :"*" do
    incr :events_per_hour
    incr :events_per_minute
    incr :events_per_second
  end

  # -- traffic gauges ---------------------------------------------------------

  gauge :traffic_total,
    :group => "Traffic",
    :tick => 1.minute.to_i,
    :progressive => true,
    :title => "Traffic (total)",
    :autoupdate => 1

  gauge :activity,
    :group => "Traffic",
    :tick => 1.minute.to_i,
    :title => "Traffic (total)",
    :autoupdate => 1

  #
  gauge :traffic_per_tunnel,
    :three_dimensional => true
  # toplist_gauge :traffic_per_tunnel,
  #     :title => "Most active tunnels",
  #     :resolution => 2.minutes

  # --- event handling --------------------------------------------------------

  event :traffic do
    name, traffic = data.values_at :name, :traffic

    if name
      incr_field :traffic_per_tunnel, name, traffic
    end

    incr :traffic_total, traffic
    incr :activity, 1
  end

  event :"*" do
    puts "received event: #{data.inspect}"
  end

    # timeseries_gauge :number_of_signups,
    #    :group => "My Group",
    #    :title => "Number of Signups",
    #    :key_nouns => ["Singup", "Signups"],
    #    :series => [:via_twitter, :via_facebook],
    #    :resolution => 2.minutes
    # timeseries_gauge 'Checks',
    # :group => "Traffic",
    #   :title => "C",
    #   :gauges => [:traffic_total],
    #   :type => :timeline,
    #   :width => 100,
    #   :autoupdate => 1

  # -- The Traffic dashboard ------------------------------------------------

  widget 'Traffic',
    :title => "Traffic (total)",
    :gauges => [:traffic_total, :activity],
    :type => :timeline,
    :width => 60,
    :autoupdate => 1

    widget 'Traffic',
      :title => "Active tunnels (total)",
      :gauges => :activity,
      :type => :numbers,
      :width => 40,
      :autoupdate => 1

      widget 'Traffic',
        :title => "Active tunnels #2 (total)",
        :gauges => :activity,
        :type => :numbers,
        :width => 40,
        :autoupdate => 1

  widget 'Traffic',
    :title => "Activity",
    :gauges => [:activity],
    :type => :timeline,
    :width => 100,
    :autoupdate => 1

  # -- The Internals dashboard ------------------------------------------------

  widget 'Internals',
    :title => "Events",
    :type => :numbers,
    :width => 100,
    :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
    :offsets => [1,3,5,10],
    :autoupdate => 1
end

FnordMetric.standalone
