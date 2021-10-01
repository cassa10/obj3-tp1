class Trait
  attr_reader :metodos, :metodos_requeridos

  def initialize(metodos, metodos_requeridos = [], operaciones = [])
    super()
    @metodos = metodos
    @metodos_requeridos = metodos_requeridos
    @operations = operaciones
  end

  def description
    # Eval operations
    @operations.map {|op| op.description}.join("")
  end

  def +(trait)
    #No mutar la lista original
    operations = @operations.dup
    operations << Operation.new(:+, trait)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@cosas, operations)
  end

  def -(argMethods)
    #validate empty array?
    methods = [*argMethods]
    operations = @operations.dup
    operations << Operation.new(:-, methods)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@cosas, operations)
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

# Not working :(
def requires(*methods)
  #  unless methods.all? { |met| self.respond_to? met }
  #    throw "not implemented all required methods"
  #  end
end

def Object.const_missing(name)
  # Que deberia hacer aca? Ya el mensaje `uses` de clase define la constante, asi que no se que retornar
  name
end

