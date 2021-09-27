class Trait
  attr_reader :cosas, :name

  def initialize(name, cosas, operations = [])
    super()
    @name = name
    @cosas = cosas
    # Agregar todos los traits a combinar (para eliminar los duplicados)
    @operations = operations
  end

  def description
    # Eval operations
    @name.to_s + @operations.map {|op| op.description}.join("")
  end

  def +(trait)
    #No mutar la lista original
    operations = @operations.dup
    operations << Operation.new(:+, trait)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@name, @cosas, operations)
  end

  def -(argMethods)
    #validate empty array?
    methods = [*argMethods]
    operations = @operations.dup
    operations << Operation.new(:-, methods)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@name, @cosas, operations)
  end

  def to_s
    self.description
  end
end

class Operation
  def initialize(operationType, operator)
    super()
    #OperationType = :+ | :-
    @operationType = operationType
    #Operator = Trait | [:method]
    @operator = operator
  end

  def description
    " " + @operationType.to_s + " " + @operator.to_s
  end
end

class Class
  def uses(trait)
    class_eval(&trait.cosas)
  end
end

def trait(traitName, &definitions)
  Object.const_set(traitName, Trait.new(traitName, definitions))
end

# Not working :(
def requires(*methods)
  #  unless methods.all? { |met| self.respond_to? met }
  #    throw "not implemented all required methods"
  #  end
end

