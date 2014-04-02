class FnordMetric::Widget
  def ticks
    ensure_has_tick!
    range.step(@tick).to_a
  end
end
