# Additional configuration for web processes.

require "metric_system"
load "config/metric_system.rb"

MetricSystem.target = METRIC_SYSTEM_DATABASE
