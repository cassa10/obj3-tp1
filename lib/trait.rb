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

  def union_de_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait.each do |metodo|
      validar_conflictos(metodo, metodos_de_operacion)
    end
    metodos_de_trait | metodos_de_operacion
  end

  def metodos
    union_de_metodos(@metodos.map { |metodo| TraitMethod.new(metodo, @nombre) }, @operations.flat_map(&:metodos))
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
    self.class.new(@metodos, @metodos_requeridos, operations)
  end

  def to_s
    self.description
  end

  private

  def validar_conflictos(metodo, metodos_de_operacion)
    raise 'Conflicto entre metodos de traits' if metodos_de_operacion.any? do |m_op|
      (m_op.metodo.original_name.eql? metodo.metodo.original_name) && (!m_op.trait.eql? @nombre)
    end
  end

end
