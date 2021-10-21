require 'operation'

class Trait

  attr_reader :nombre

  #TODO: Refactorizar lista de operaciones a un objeto TraitCompuesto y Trait
  def initialize(nombre, metodos, metodos_requeridos = [], operaciones = [])
    super()
    @metodos = metodos
    @metodos_requeridos = metodos_requeridos
    @operations = operaciones
    @nombre = nombre
  end

  def description
    # Eval operations
    @nombre.to_s + @operations.map(&:description).join('')
  end

  def metodos
    metodos_propios = @metodos.map { |metodo| TraitMethod.new(metodo, @nombre) }
    metodos_finales = [*metodos_propios]
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

  def <<(metodos_a_renombrar)
    operations = @operations.dup
    operations << Operation.new(:<<, metodos_a_renombrar)
    #Devolver un nuevo Trait con el nuevo cambio, es decir, hacerlo inmutable
    self.class.new(@nombre, @metodos, @metodos_requeridos, operations)
  end

  def metodos_sin_conflictos(estrategias_de_conflictos)
    metodos_particionados = metodos.partition do |metodo|
      metodos.any? { |m_op| (m_op.mismo_nombre? metodo) && (m_op.distinto_trait? metodo) }
    end
    metodos_conflictivos = metodos_particionados[0]
    metodos_sin_conflictos = metodos_particionados[1]

    estrategias_de_conflictos.each do |estrategia|

      metodos_a_aplicar_estrategia = metodos_conflictivos.select do |metodo|
        estrategia.es_para? metodo.nombre
      end

      metodos_sin_conflictos.concat(estrategia.manejar_conflicto(metodos_a_aplicar_estrategia))
      metodos_conflictivos.filter! { |m1| metodos_a_aplicar_estrategia.none? { |m2|  m1.mismo_nombre? m2 } }
    end

    raise 'Conflicto entre metodos de traits' unless metodos_conflictivos.empty?
    metodos_sin_conflictos
  end


  def to_s
    self.description
  end

end
