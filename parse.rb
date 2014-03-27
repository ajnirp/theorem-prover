require 'rly'

require './formula.rb'
require './derivation.rb'
require './proof.rb'

class FormulaLex < Rly::Lex
  ignore " \t\n" # ignore whitespace

  token :VARIABLE, /([A-EG-Z]|False)/
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