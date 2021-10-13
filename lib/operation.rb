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

  def metodos
    operator.metodos
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
      union_de_metodos(metodos, self.metodos)
    when :-
      quitar_metodos(metodos, @operator)
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
      (m_op.metodo.original_name.eql? metodo.metodo.original_name) && (!m_op.trait.eql? metodo.trait)
    end
  end

end
