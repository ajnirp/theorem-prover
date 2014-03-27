# to run: ruby main.rb

require './parse.rb'

def get_hypotheses
  hypotheses = []
  print "Number of hypotheses? " if $SHOW_OUTPUT
  gets.to_i.times do |i|
    print "Hypothesis #{i+1}? " if $SHOW_OUTPUT
    hypotheses << parse(gets.chomp)
  end
  return hypotheses
end

def get_goal
  print "Goal? " if $SHOW_OUTPUT
  return parse(gets.chomp)
end

if __FILE__ == $0
  $SHOW_OUTPUT = ARGV.empty?
  Proof.new(get_hypotheses, get_goal).prove

  # Some tests

  # tests for parse

  # tests for parsing
  # a = parse('(A -> (((A -> B))))')
  # a.print_formula
  # puts
  # a = Derivation.new(a)
  # a.shift_left_complete!
  # a.print_derivation
  # exit

  # puts a.class
  # puts a.lhs.class
  # a.print_formula
  # exit

  # parse("(((A))) -> B").print_formula
  # parse("(((A)))").print_formula
  # parse("(((A))) -> (B -> ((C)))").print_formula

  # test for logical and, or, not

  # p = Variable.new('P')
  # q = Variable.new('Q')
  # p.logical_or(q).print_formula
  # puts
  # p.logical_and(q).print_formula
  # puts
  # p.logical_not.print_formula
  # puts

  # test for shift_left_complete and shift_right_complete

  # p = Variable.new('P')
  # q = Variable.new('Q')
  # # the below formula is ((P -> Q) -> (((P -> False) -> Q) -> Q))
  # d = Derivation.new(Formula.new(Formula.new(p,q),Formula.new(Formula.new(Formula.new(p,$FALSE_VAL),q),q)))
  # d.print_derivation
  # d.shift_left_complete!
  # d.print_derivation
  # d.shift_right_complete!
  # d.print_derivation

  # test for modus ponens and equality of formulae
  # modus ponens uses substitute so these are also
  # effectively tests for substitution

  # a = Variable.new('A')
  # c = Variable.new('C')

  # b = Variable.new('B')
  # ab = Formula.new(a, b)
  # puts ab.equal?(Variable.new('A'))
  # puts a.equal?(ab)
  # puts ab.lhs.equal?(a)
  # # a.modus_ponens(b).print_formula # should raise error
  # a.modus_ponens(ab).print_formula # should work
  # puts
  # a.axiom1(ab, $FALSE_VAL).print_formula
  # puts
  # a.axiom2(a,ab,c).print_formula
  # puts
  # a.axiom3(ab).print_formula
  # puts

end