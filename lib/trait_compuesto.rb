require 'trait'

class TraitCompuesto < Trait

  def initialize(trait, operador, operacion)
    super()
    @trait = trait
    @operador = operador
    @operacion = operacion
  end

  def description
    "#{@trait.to_s} #{@operacion.to_s} #{@operador.to_s}"
  end

  def metodos
    @operacion.aplicar(@trait, @operador)
  end

  def metodos_requeridos
    @trait.metodos_requeridos | @operacion.metodos_requeridos(@operador)
  end

  def +(trait)
    TraitCompuesto.new(self, trait, OperacionComposicion.new)
  end

  def -(arg_methods)
    methods = [*arg_methods]
    TraitCompuesto.new(self, methods, OperacionSubstraccion.new)
  end

  def <<(metodos_a_renombrar)
    TraitCompuesto.new(self, metodos_a_renombrar, OperacionRenombre.new)
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
      metodos_conflictivos.filter! { |m1| metodos_a_aplicar_estrategia.none? { |m2| m1.mismo_nombre? m2 } }
    end

    raise 'Conflicto entre metodos de traits' unless metodos_conflictivos.empty?
    metodos_sin_conflictos
  end

end