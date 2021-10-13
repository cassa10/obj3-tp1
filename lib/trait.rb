require 'operation'

class Trait

  attr_reader :nombre

  def initialize(nombre, metodos, metodos_requeridos = [], operaciones = [])
    super()
    @metodos = metodos
    @metodos_requeridos = metodos_requeridos
    @operations = operaciones
    @nombre = nombre
  end

  def description
    # Eval operations
    @operations.map(&:description).join('')
  end

  def metodos
    metodos_propios = @metodos.map { |metodo| TraitMethod.new(metodo, @nombre) }
    metodos_finales = [].push(*metodos_propios)
    @operations.each { |operation| metodos_finales = operation.aplicar_con(metodos_finales) }
    metodos_finales
  end

  def metodos_requeridos
    @metodos_requeridos | @operations.flat_map(&:metodos_requeridos)
  end

  def +(trait)
    #No mutar la lista original
    operations = @operations.dup
    operations << Operation.new(:+, trait)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@nombre, @metodos, @metodos_requeridos, operations)
  end

  def -(arg_methods)
    #validate empty array?
    methods = [*arg_methods]
    operations = @operations.dup
    operations << Operation.new(:-, methods)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@nombre, @metodos, @metodos_requeridos, operations)
  end

  def to_s
    self.description
  end

end
