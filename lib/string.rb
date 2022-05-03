# frozen_string_literal: true

class String
  def camelize
    split(/[^a-z0-9]/i).collect(&:capitalize).join
  end
end
