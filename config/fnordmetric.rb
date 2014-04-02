require_relative "./environment"

FnordMetric.namespace :myapp do

  # render a timeseries graph
  widget 'Checks',
    :title => "Checks",
    :gauges => [:checks],
    :type => :timeline,
    :width => 100,
    :autoupdate => 1
end

FnordMetric.standalone
