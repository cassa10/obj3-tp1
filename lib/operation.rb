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
    " " + @operation_type.to_s + " " + @operator.to_s
  end

  def metodos_requeridos
    # Aca definitivamente falta armar subclases de operaciones para no tener que hacer estas cosas
    if operator.is_a? Trait
      operator.metodos_requeridos
    else
      []
    end
  end

  def aplicar_con(metodos)
    case @operation_type
    when :+
      # operator :: Trait
      union_de_metodos(metodos, @operator.metodos)
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

  def union_de_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait.each do |metodo|
      validar_conflictos(metodo, metodos_de_operacion)
    end
    metodos_de_trait | metodos_de_operacion
  end

  def validar_conflictos(metodo, metodos_de_operacion)
    raise 'Conflicto entre metodos de traits' if metodos_de_operacion.any? do |m_op|
      (m_op.mismo_nombre? metodo) && (m_op.distinto_trait? metodo)
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
