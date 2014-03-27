require 'set'
require './step.rb'

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

  # for every pair of Proofsteps in @steps
  # try to generate a new formula using modus ponens
  # if it succeeds, add it to @steps
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

  # ask the user for which axiom to use
  # and what formulae to pass to that axiom
  def request_help
    print "Need help! Use which axiom? (1, 2 or 3) "
    axiom = gets.to_i
    new_step = case axiom
    when 1
      print "A? "; a = parse(gets.chomp)
      print "B? "; b = parse(gets.chomp)
      Axiom1.new(a,b)
    when 2
      print "A? "; a = parse(gets.chomp)
      print "B? "; b = parse(gets.chomp)
      print "C? "; b = parse(gets.chomp)
       Axiom2.new(a,b,c)
    when 3
      print "A? "; a = parse(gets.chomp)
      Axiom3.new(a)
    else
      axiom
    end
    if [1,2,3].include?(axiom)
      print "Adding "
      new_step.print_formula
      print " to the list of steps\n"
      @steps << new_step unless @steps.include?(new_step)
    elsif new_step.zero?
      puts "No help used"
      return
    else
      STDERR.puts "Please enter either 1, 2 or 3"
    end
  end

  # the main function
  def prove
    # iterate until goal found
    # until @steps.any? { |step| step.formula == @goal }
    until @steps.map(&:formula).include?(@goal)
      modus_ponens_results = add_modus_ponens
      if modus_ponens_results.empty?
        request_help
      else
        @steps.concat(modus_ponens_results)
      end
    end
    print_proof
  end

  def print_proof
    header =<<-EOS

 Step | Formula / Reason
------+------------------
    EOS
    puts header
    @steps.each_with_index do |step, index|
      # print "| #{index} | "
      printf "  %-2s  | ", index
      step.print_step
      puts
    end
  end
end

