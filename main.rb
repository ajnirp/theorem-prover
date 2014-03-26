# to run: ruby main.rb

require 'rly'

require './formula.rb'
require './derivation.rb'
require './proof.rb'

#### Parsing
class FormulaLex < Rly::Lex
  ignore " \t\n" # ignore whitespace

  token :VARIABLE, /[A-Z]/
  token :IMPLIES, /\->/
  token :LPAREN, /\(/
  token :RPAREN, /\)/

  # skip erroneous character encountering while scanning
  on_error do |t|
    STDERR.puts "Illegal character #{t.value}"
    t.lexer.pos += 1
  end
end

class FormulaParse < Rly::Yacc
  rule 'statement : expression' do |st, e|
    st.value = e.value.is_a?(Variable) ? Variable.new(e.value.name) : Formula.new(e.value.lhs, e.value.rhs)
  end

  # variables
  rule 'expression : VARIABLE' do |ex, var|
    ex.value = Variable.new(var.value)
  end

  # (formula) implication
  rule 'expression : expression IMPLIES expression' do |ex, ex1, imp, ex2|
    ex.value = Formula.new(ex1.value, ex2.value)
  end

  # parentheses
  rule 'expression : LPAREN expression RPAREN' do |ex, lpar, ex1, rpar|
    ex.value = ex1.value.is_a?(Variable) ? Variable.new(ex1.value.name) : Formula.new(ex1.value.lhs, ex1.value.rhs)
  end
end

# construct the parser object
$PARSER = FormulaParse.new(FormulaLex.new)

def parse(s)
  $PARSER.parse(s)
end

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
  # Some tests

  # tests for the proof and proofstep classes

  $SHOW_OUTPUT = ARGV.empty?
  Proof.new(get_hypotheses, get_goal).prove

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