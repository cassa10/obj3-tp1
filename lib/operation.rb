require 'operation_type'
require 'trait_method'

class Operation
  attr_reader :operator

  def initialize(operation_type, operator)
    super()
    #OperationType = :+ | :- | :<<
    @operation_type = validate_operation_type(operation_type)
    #Operator = Trait | [:method]
    @operator = operator
  end

  def description
    ' ' + @operation_type.to_s + ' ' + @operator.to_s
  end

  def metodos_requeridos
    # Aca definitivamente falta armar subclases de operaciones para no tener que hacer estas cosas
    if operator.is_a? Trait
      operator.metodos_requeridos
    else
      []
    end
  end

  def estrategias_de_conflictos
    if operator.is_a? Trait
      operator.estrategias_de_conflictos
    else
      []
    end
  end

  def aplicar_con(metodos, estrategias_de_conflictos)
    case @operation_type
    when :+
      # operator :: Trait
      union_de_metodos(metodos, @operator.metodos, estrategias_de_conflictos)
    when :-
      # operator :: [Symbol]
      quitar_metodos(metodos, @operator)
    when :<<
      # operator :: Hash
      agregar_metodos(metodos, @operator)
    end
  end

  private

  def quitar_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait.reject { |metodo_de_trait| metodos_de_operacion.include?(metodo_de_trait.metodo.original_name) }
  end

  def union_de_metodos(metodos_de_trait, metodos_de_operacion, estrategias_de_conflictos)
    validar_conflictos(metodos_de_trait, metodos_de_operacion, estrategias_de_conflictos)
    metodos_de_trait | metodos_de_operacion
  end

  def validar_conflictos(metodos_de_trait, metodos_de_operacion, estrategias_de_conflictos)
    metodos_conflictivos = metodos_de_trait.select do |metodo|
      metodos_de_operacion.any? do |m_op|
        (m_op.mismo_nombre? metodo) && (m_op.distinto_trait? metodo)
      end
    end

    metodos_conflictivos.each do |metodo|
      estrategia_correcta = estrategias_de_conflictos.find { |estrategia| estrategia.es_para metodo.metodo.original_name }
      raise 'Conflicto entre metodos de traits' if estrategia_correcta.nil?

      estrategia_correcta.manejar_conflicto(metodo, metodos_de_trait, metodos_de_operacion)
    end
  end

  def agregar_metodos(metodos_de_trait, metodos_a_agregar)
    nuevos_metodos_de_trait = [*metodos_de_trait]
    metodos_a_agregar.each do |simbolo_metodo_trait, renombre_del_metodo|
      metodo_a_duplicar = metodos_de_trait.find { |metodo_de_trait| metodo_de_trait.mismo_simbolo? simbolo_metodo_trait }
      raise "Metodo #{simbolo_metodo_trait.inspect} no esta definido en el trait" if metodo_a_duplicar.nil?

      nuevos_metodos_de_trait << metodo_a_duplicar.duplicar_con_nombre(renombre_del_metodo)
    end
    nuevos_metodos_de_trait
  end

end
