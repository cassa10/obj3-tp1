require 'operation_type'
require 'trait_method'

class Operation
  attr_reader :operator

  def initialize(operation_type)
    super()
    #OperationType = :+ | :- | :<<
    # TODO: Refactorizar a subclasses de OperacionComposicion (+), OperacionSubstraccion (-), OperacionRenombre (<<)
    @operation_type = validate_operation_type(operation_type)
    #Operator = Trait | [:method]
    @operator = operator
  end

  def description
    ' ' + @operation_type.to_s + ' ' + @operator.to_s
  end

  def metodos_requeridos(operador)
    # Aca definitivamente falta armar subclases de operaciones para no tener que hacer estas cosas
    if operador.is_a? Trait
      operador.metodos_requeridos
    else
      []
    end
  end

  def aplicar_metodos_con(trait, operador)
    case @operation_type
    when :+
      # operator :: Trait
      union_de_metodos(trait.metodos, operador.metodos)
    when :-
      # operator :: [Symbol]
      quitar_metodos(trait.metodos, operador)
    when :<<
      # operator :: Hash
      agregar_metodos(trait.metodos, operador)
    end
  end

  def to_s()
    @operation_type.to_s
  end

  private

  def quitar_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait.reject { |metodo_de_trait| metodos_de_operacion.include?(metodo_de_trait.metodo.original_name) }
  end

  def union_de_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait | metodos_de_operacion
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
