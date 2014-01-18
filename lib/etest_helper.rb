module Etest::Helper
  # returns a list of invalid attributes in a model, as symbols.
  def invalid_attributes(model)                                     #:nodoc:
    model.valid? ? [] : model.errors.keys
  end

  #
  # Verifies that a model is valid. Pass in some attributes to only
  # validate those attributes.
  def assert_valid(model, *attributes)
    if attributes.empty?
      assert(model.valid?, "#{model.inspect} should be valid, but isn't: #{model.errors.full_messages.join(", ")}.")
    else
      invalid_attributes = invalid_attributes(model) & attributes
      assert invalid_attributes.empty?,
        "Attribute(s) #{invalid_attributes.join(", ")} should be valid"
    end
  end

  #
  # Verifies that a model is invalid. Pass in some attributes to only
  # validate those attributes.
  def assert_invalid(model, *attributes)
    assert(!model.valid?, "#{model.inspect} should be invalid, but isn't.")

    return if attributes.empty?

    missing_invalids = attributes - invalid_attributes(model)

    assert missing_invalids.empty?,
      "Attribute(s) #{missing_invalids.join(", ")} should be invalid, but are not"
  end
end
