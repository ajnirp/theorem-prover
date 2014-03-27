class ProofStep
  attr_accessor :formula

  def ==(proofstep)
    self.class == proofstep.class && @formula == proofstep.formula
  end

  def print_step
    @formula.print_formula
    print " / "
    print_reason
  end

  def print_formula
    @formula.print_formula
  end
end

class Hypothesis < ProofStep
  def initialize(wff)
    @formula = wff
  end

  def print_reason
    print "Hypothesis"
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
  end
end

class Axiom3 < ProofStep
  def initialize(a_val)
    @formula = Formula.axiom3(a_val)
  end

  def print_reason
    print "Axiom 3 with A substituted as "
    a_val.print_formula
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
  end
end