require 'operation'

class Trait

  attr_reader :nombre

  def initialize(nombre, metodos, metodos_requeridos = [], operaciones = [], estrategias_de_conflictos = [])
    super()
    @metodos = metodos
    @metodos_requeridos = metodos_requeridos
    @operations = operaciones
    @nombre = nombre
    @estrategias_de_conflictos = estrategias_de_conflictos
  end

  def description
    # Eval operations
    @nombre.to_s + @operations.map(&:description).join('')
  end

  def estrategias_de_conflictos
    @operations.flat_map(&:estrategias_de_conflictos).push(*@estrategias_de_conflictos)
  end

  def metodos
    metodos_propios = @metodos.map { |metodo| TraitMethod.new(metodo, @nombre) }
    metodos_finales = [*metodos_propios]
    @operations.each { |operation| metodos_finales = operation.aplicar_con(metodos_finales, estrategias_de_conflictos) }
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

  def <<(metodos_a_renombrar)
    operations = @operations.dup
    operations << Operation.new(:<<, metodos_a_renombrar)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@nombre, @metodos, @metodos_requeridos, operations)
  end

  def on_conflict(estrategia)
    estrategias_de_conflictos = [*estrategia]
    self.class.new(@nombre, @metodos, @metodos_requeridos, [], estrategias_de_conflictos)
  end

  def to_s
    self.description
  end

end
