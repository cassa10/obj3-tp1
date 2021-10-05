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
    @operations.map { |op| op.description }.join("")
  end

  def validar_metodos(clase)
    raise "no tiene definido los metodos requeridos" unless metodos_requeridos.all? do |metodo_req|
      clase.instance_methods.include? metodo_req
    end
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
