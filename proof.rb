require 'set'
require './step.rb'
require './monkeypatches.rb'

class Proof
  attr_accessor :hypotheses

  # goal: what we need to prove
  # hypotheses: array of Formulae
  # steps: array of proof steps
  def initialize(hypotheses, goal)
    @steps = []

    goal_derivation = Derivation.new(goal.reduce_negations)
    goal_derivation.shift_left_complete!

    # two kinds of hypotheses: initial hypotheses
    # and hypotheses that came from shifting the goal left
    unique_hypotheses = get_unique_formulae(hypotheses.map(&:reduce_negations), goal_derivation.lhs_list)
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
      print "C? "; c = parse(gets.chomp)
       Axiom2.new(a,b,c)
    when 3
      print "A? "; a = parse(gets.chomp)
      Axiom3.new(a)
    end
    if [1,2,3].include?(axiom)
      print "Adding "
      new_step.print_formula
      print " to the list of steps\n"
      @steps << new_step unless @steps.include?(new_step)
    else
      STDERR.puts "Please enter either 1, 2 or 3"
    end
  end

  def add_axioms
    possible_parents = @steps.select { |step| step.formula.formula? && step.formula.rhs == @goal }
    needed = possible_parents.map { |x| x.formula.lhs }
    
    found_new = false
    needed.each do |n|
      if n.formula?
        @steps << Axiom1.new(n.rhs, n.lhs) if @steps.any? { |step| step.formula == n.rhs }
        found_new = true
        if n.lhs.formula? && n.rhs.formula? && n.lhs.lhs == n.rhs.lhs
          if @steps.any? { |step| step.formula == n.lhs.lhs }
            @steps << Axiom2.new(n.lhs.lhs, n.lhs.rhs, n.rhs.rhs)
          end
        end
      end
      @steps << Axiom3.new(n)
    end
    return found_new
  end

  def add_contrapositives
    contrapositives = @steps.map { |step| Contrapositive.new(step.formula) }
    contrapositives.each { |c| @steps << c unless @steps.any? { |step| step.formula == c.formula } }
  end

  # the main function
  def prove
    puts "\nHypotheses\n----------"
    @steps.each { |x| x.formula.print_formula ; puts }

    # exit

    print "\nGoal: "
    @goal.print_formula ; puts

    # iterate until goal found
    until @steps.any? { |step| step.formula == @goal }
      add_contrapositives
      modus_ponens_results = add_modus_ponens
      # break
      if modus_ponens_results.empty?
        found_new = add_axioms
        if not found_new
          request_help
        end
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

