import ply.lex as lex
import ply.yacc as yacc

class Atomic:
	def __init__(self, expr):
		self.expr = expr
		if type(expr) is str:
			self.string = expr
		else:
			self.string = expr.string
		self.type = 'atomic'

	def print_formula(self):
		print(self.string)

	def substitute(self, variable, expr):
		if type(self.expr) is str:
			if self.expr == variable:
				self.expr = expr
			else:
				print('nothing to substitute for', self.string)
		else:
			self.expr.lhs = self.expr.lhs.substitute(variable, expr)
			self.expr.rhs = self.expr.rhs.substitute(variable, expr)


class Formula:
	def __init__(self, lhs, rhs):
		self.lhs = lhs
		self.rhs = rhs
		lhs_string = self.lhs if type(self.lhs) is str else self.lhs.string
		rhs_string = self.rhs if type(self.rhs) is str else self.rhs.string
		self.string = '(' + lhs_string + ' -> ' + rhs_string + ')'
		self.type = 'formula'

	def print_formula(self):
		print(self.string)

	def print_type(self):
		print('formula')

	def substitute(self, variable, expr):
		print('Calling on', self.string)
		self.lhs = self.lhs.substitute(variable, expr)
		self.rhs = self.rhs.substitute(variable, expr)

tokens = (
	'IMPLIES',
	'VARIABLE',
	'FALSE',
	'LPAREN',
	'RPAREN'
)

t_IMPLIES = r'->'
t_FALSE = r'F'
t_VARIABLE = r'[A-EG-Z]' # 'F' is reserved to mean 'False'
t_LPAREN = r'\('
t_RPAREN = r'\)'

t_ignore = " \t" # ignore whitespace

# skip over illegal characters
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)

lex.lex()

# Parsing rules
def p_expression_variable(t):
	'expression : VARIABLE'
	t[0] = Atomic(t[1])
	# t[0].print_formula()

def p_expression_false(t):
	'expression : FALSE'
	t[0] = Atomic('False')
	# t[0].print_formula()

def p_expression_implication(t):
	'expression : expression IMPLIES expression'
	t[0] = Formula(Atomic(t[1]), Atomic(t[3]))
	# t[0].print_formula()

def p_expression_parenthetization(t):
	'expression : LPAREN expression RPAREN'
	t[0] = Atomic(t[2])
	# t[0].print_formula()

def p_error(t):
    print("Syntax error at '%s'" % t.value)

yacc.yacc() # generate the parse table

try:
	s = input('Formula? ')
	parsed_formula = yacc.parse(s)
	print('Parsed formula:', end=' ')
	parsed_formula.print_formula()


	# parsed_formula.substitute('A', Formula('A','B'))
	# parsed_formula.print_formula()
except EOFError:
	exit(0)
