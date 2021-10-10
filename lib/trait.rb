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
      #TODO: Fijarse de obtener todos los metodos junto a sus operaciones
      clase.instance_methods.include? metodo_req
    end
  end

  def +(trait)
    #No mutar la lista original
    operations = @operations.dup
    operations << Operation.new(:+, trait)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@metodos, @metodos_requeridos, operations)
  end

  def -(arg_methods)
    #validate empty array?
    methods = [*arg_methods]
    operations = @operations.dup
    operations << Operation.new(:-, methods)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@metodos, @metodos_requeridos, operations)
  end

  def to_s
    self.description
  end
end
