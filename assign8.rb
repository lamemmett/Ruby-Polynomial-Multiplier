# Emmett Lam
# CSE 341 Autumn 2012
# Assignment 8: Polynomials

# A polynomial holds an array of Terms, each term has a coefficient and variable bindings
class Polynomial
  attr_accessor :terms

  # initialize polynomials to have coefficient 1 and no variable bindings
  def initialize(coef = 1, varName = nil)
    @terms = [Term.new(coef, varName)]
    return self
  end

  # String representation of polynomials, does not display leading 1's and handles + and - between terms
  def to_s
    result = ""
    if @terms[0].coef < 0
      result += "-"
    end
    for i in 0..@terms.size-1
      result += @terms[i].to_s
      if !@terms[i+1].nil?
        if @terms[i+1].coef > 0
          result += " + "
        else
          result += " - "
        end
      end
    end
    return "Polynomial(" + result + ")"
  end
  
  # Returns a new polynomial that is the result of a+b if a and b are both polynomials
  #    - Simplifies polynomial after performing operations
  def + other
    if other.class != Polynomial
      return self + Polynomial.new(other)
    end
    newTerms = []
    @terms.each {|x| i = Term.new; i.coef = x.coef;
                 i.varCounts = x.varCounts; newTerms.push(i)}
    other.terms.each {|x| i = Term.new; i.coef = x.coef;
                      i.varCounts = x.varCounts; newTerms.push(i)}
    temp = Polynomial.new
    temp.terms = newTerms
    return temp.simplify
  end

  # Returns a new polynomial that is the result of a-b if a and b are polynomials
  #    - Simplifies polynomial after performing operations
  def - other
    if other.class != Polynomial
      return self - Polynomial.new(other)
    end
    newTerms = []
    @terms.each {|x| i = Term.new; i.coef = x.coef;
                 i.varCounts = x.varCounts; newTerms.push(i)}
    other.terms.each {|x| i = Term.new; i.coef = x.coef * -1; 
                       i.varCounts = x.varCounts; newTerms.push(i)}
    temp = Polynomial.new
    temp.terms = newTerms
    return temp.simplify
  end

  # Returns a new polynomial that is the result of a*b if a and b are polynomials
  #    - Simplifies polynomial after performing operations
  def * other
    if other.class != Polynomial
      return self * Polynomial.new(other)
    end
    newTerms = []
    @terms.each do |term1|
      other.terms.each do |term2|
        temp = Term.new
        temp.coef = term1.coef * term2.coef
        #a.merge(b) {|x,y,z| y+z} merges hash tables a & b and combines values of duplicate keys
        temp.varCounts = term1.varCounts.merge(term2.varCounts){|x,y,z| y+z}
        newTerms.push(temp)
      end
    end
    temp = Polynomial.new
    temp.terms = newTerms
    return temp.simplify
  end

  # Returns a new polynomial that is the result of a^c if a is a polynomial and c is a positive integer
  #    - Simplifies polynomial after performing operations
  def ** exponent
    newPoly = Polynomial.new
    temp = self
    for i in 1..exponent
      newPoly *= temp
    end
    return newPoly
  end

protected
  # Returns a simplified polynomial to the calller
  #    - Removes terms with coefficient 0
  #    - Combines terms with same variable bindings
  def simplify
    # combine like terms (aka x^2 + x^2 becames 2*x^2)
    @terms.each do|term|
      @terms.each do|other|
        if term != other && term.varCounts == other.varCounts
          term.coef += other.coef
          @terms.delete other
        end
      end
      #delete terms with coefficient 0
      if term.coef == 0
        # keep at least 1 term for the 0 polynomial, however delete its variable bindings
        if @terms.size == 1
          term.varCounts = Hash[]
        else
          @terms.delete term
        end
      end
    end
    return self
  end
  
  # Allow Integer*Polynomial and String*Polynomial to work properly
  def coerce(n)
    return [n.asPolynomial, self]
  end
  
end

# A term holds an integer coefficient, and a hash table representing variable bindings
class Term
  attr_accessor :coef, :varCounts

  # Term default coefficient is 1, default variable bindings are empty
  def initialize(coef = 1, varName = nil)
    @coef = coef
    @varCounts = Hash[]
    if (!varName.nil?)
      @varCounts = Hash[varName, 1]
    end
  end

  # String representation of terms
  #    - Omits leading 1's
  #    - Sample Ouput: 3*x*z...x*y*y
  def to_s
    result = ""
    if @coef.abs != 1 || varCounts.empty?
      result += @coef.abs.to_s + "*"
    end
    varCounts.each_key do|x|
      result += x
      if varCounts.fetch(x) > 1
        result += "**" + varCounts.fetch(x).to_s
      end
      result += "*"
    end
    # remove the extrenuous '*' symbol if there is one
    if result.end_with?("*")
      result = result.chop
    end
    return result
  end
end

class Numeric
 def asPolynomial
   return Polynomial.new(self)
 end
end

class String
  def asPolynomial
    return Polynomial.new(1, self)
  end
end
