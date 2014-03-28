require './formula.rb'

class Object
  def formula?
    is_a?(Formula) && !(is_a?(Variable))
  end

  def variable?
    is_a?(Variable)
  end
end