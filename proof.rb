require 'set'

class Proof
  attr_accessor :hypotheses

  # goal: what we need to prove
  # hypotheses: array of Formulae
  # steps: array of proof steps
  def initialize(hypotheses, goal)
    @steps = []

    goal_derivation = Derivation.new(goal)
    goal_derivation.shift_left_complete!

    # two kinds of hypotheses: initial hypotheses
    # and hypotheses that came from shifting the goal left
    unique_hypotheses = get_unique_formulae(hypotheses, goal_derivation.lhs_list)
    add_hypotheses(unique_hypotheses)

    # @steps.each {|x| p x}

    @goal = goal_derivation.rhs
  end

  # hypotheses_list is a array of arrays of Formulae
  # each of which should be used as a Hypothesis
  def add_hypotheses(*hypotheses_list)
    hypotheses_list.each do |hypotheses|
      @steps.concat(hypotheses.map { |h| Hypothesis.new(h) })
    end
  end

  def get_unique_formulae(*hypotheses_list)
    result = []
    hypotheses_list.flatten.each { |h| result << h }
    result.uniq! { |item| item.is_a?(Variable) ? item.name : item }
    return result.map { |item| item.is_a?(String) ? Variable.new(item) : item }
  end

  # def try_modus_ponens(step)
  #   # 'step' is a possible source for modus ponens

  #   # print "You are trying to apply modus ponens using: "
  #   # step.formula.print_formula
  #   # puts

  #   if step.formula.is_a?(Formula)
  #     if step.formula.rhs == @goal
  #       parents = @steps.select { |st| st.formula == step.formula.lhs }
  #       unless parents.empty? 
  #         @steps << ModusPonens.new(step.formula, parents.first.formula)
  #         puts "found"
  #         return true # found the two "parent" steps in modus ponens for goal
  #       end
  #     end
  #   end
  #   return false
  # end

  def add_modus_ponens
    new_steps = Set.new
    for i in 0...(@steps.length)
      for j in (i+1)...(@steps.length)
        new_step = ModusPonens.new(@steps[i].formula, @steps[j].formula) rescue nil
        new_steps.add(new_step) unless new_step.nil? or @steps.include?(new_step)
      end
    end
    return new_steps.to_a
  end

  def request_help
    print "Use axiom: (1, 2 or 3) "
    axiom = gets.to_i
    case axiom
    when 1
    when 2
    when 3
    else
      raise "error: please enter either 1, 2 or 3"
    end
  end

  def prove
    # iterate until goal found
    until @steps.any? { |step| step.formula == @goal }
      modus_ponens_results = add_modus_ponens
      unless modus_ponens_results.empty?
        @steps.concat(modus_ponens_results)
      else
        request_help
      end
    end
    print_proof
  end

  def print_proof
    @steps.each_with_index do |step, index|
      print "#{index}: "
      step.print_step
    end
  end
end

class ProofStep
  attr_accessor :formula

  def ==(proofstep)
    self.class == proofstep.class && @formula == proofstep.formula
  end

  def print_step
    @formula.print_formula
    print " "
    print_reason
  end
end

class Hypothesis < ProofStep
  def initialize(wff)
    @formula = wff
  end

  def print_reason
    puts "Hypothesis"
  end

  def print_formula
    @formula.print_formula
  end
end

class Axiom1 < ProofStep
  def initialize(a_val, b_val)
    @formula = Formula.axiom1(a_val, b_val)
  end

  def print_reason
    print "Axiom 1 with A substituted as "
    a_val.print_formula
    print ", B substituted as "
    b_val.print_formula
    puts
  end
end

class Axiom2 < ProofStep
  def initialize(a_val, b_val, c_val)
    @formula = Formula.axiom2(a_val, b_val, c_val)
  end

  def print_reason
    print "Axiom 2 with A substituted as "
    a_val.print_formula
    print ", B substituted as "
    b_val.print_formula
    print ", C substituted as "
    c_val.print_formula
    puts
  end
end

class Axiom3 < ProofStep
  def initialize(a_val)
    @formula = Formula.axiom3(a_val)
  end

  def print_reason
    print "Axiom 3 with A substituted as "
    a_val.print_formula
    puts
  end
end

class ModusPonens < ProofStep
  attr_accessor :step1, :step2
  def initialize(step1, step2)
    @step1, @step2 = step1, step2 # no order implied: either can be bigger
    @formula = Formula.modus_ponens(step1, step2)
  end

  def print_reason
    print "Modus ponens between "
    @step1.print_formula
    print " and "
    @step2.print_formula
    puts
  end
end