class Derivation
  attr_accessor :lhs_list, :rhs

  def initialize(formula)
    @lhs_list = []
    @rhs = formula
  end

  def shift_left!
    if @rhs.class == Formula
      @lhs_list << @rhs.lhs
      @rhs = @rhs.rhs
    else
      # if the rhs is only a variable, use the trick mentioned in class
      # write q as ((q -> F) -> F), then shift (q -> F)
      @lhs_list << Formula.new(@rhs, $FALSE_VAL)
      @rhs = $FALSE_VAL
    end
  end

  def shift_right!
    raise "lhs list is empty!" if @lhs_list.empty?
    last = @lhs_list.pop
    @rhs = Formula.new(last, @rhs)
  end

  def shift_left_complete!
    until @rhs == $FALSE_VAL
      shift_left!
    end
  end

  def shift_right_complete!
    until @lhs_list.empty?
      shift_right!
    end
  end

  def print_derivation
    @lhs_list.each_with_index { |f,i| f.print_formula ; print ', ' unless i ==  @lhs_list.length-1 }
    print ' derives '
    @rhs.print_formula
    puts
  end
end