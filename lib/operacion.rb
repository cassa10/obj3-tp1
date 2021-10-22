require 'trait_method'

class Operacion

  def metodos_requeridos(_)
    []
  end

  def aplicar(trait, operador)
    raise 'this method should be overriden in subclass'
  end

  def to_s
    description
  end

end

class OperacionComposicion < Operacion
  def description
    "+"
  end

  def metodos_requeridos(trait)
    trait.metodos_requeridos
  end

  def aplicar(trait, trait_a_componer)
    union_de_metodos(trait.metodos, trait_a_componer.metodos)
  end

  private

  def union_de_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait | metodos_de_operacion
  end
end

class OperacionSubstraccion < Operacion
  def description
    "-"
  end

  def aplicar(trait, metodos)
    # metodos :: Array
    quitar_metodos(trait.metodos, metodos)
  end

  private

  def quitar_metodos(metodos_de_trait, metodos_de_operacion)
    metodos_de_trait.reject { |metodo_de_trait| metodos_de_operacion.include?(metodo_de_trait.metodo.original_name) }
  end
end

class OperacionRenombre < Operacion
  def description
    "<<"
  end

  def aplicar(trait, metodos_a_renombrar)
    # metodos_a_renombrar :: Hash
    agregar_metodos(trait.metodos, metodos_a_renombrar)
  end

  private

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
