class EstrategiaDeConflictos
  def initialize(metodos = [])
    super()
    @metodos = [*metodos]
  end

  def es_para(metodo)
    @metodos.empty? || @metodos.include?(metodo)
  end

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar) end
end

class CualquierImplementacion < EstrategiaDeConflictos
end

#TODO: Refactorizar logica de "manejar_conflicto" codigo repetido
class ImplementacionDeAmbos < EstrategiaDeConflictos
  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_combinado = metodo.combinar_con(metodos_a_agregar.first { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo) })
    metodos_existentes.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar << metodo_combinado
  end
end

class InjectReduce < EstrategiaDeConflictos
  def initialize(metodos = [], valor_inicial, funcion_combinadora)
    super(metodos)
    @valor_inicial = valor_inicial
    @funcion_combinadora = funcion_combinadora
  end

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_de_operacion = metodos_a_agregar.first { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo) }
    resultado_de_reduccion = metodo.reducir_con(metodo_de_operacion, @valor_inicial, @funcion_combinadora)
    metodos_existentes.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar << resultado_de_reduccion
  end
end

class Personalizable < EstrategiaDeConflictos
  def initialize(metodos = [], bloque_combinador)
    super(metodos)
    @proc_resolver_conflicto = bloque_combinador
  end

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_de_operacion = metodos_a_agregar.first { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo) }
    resultado_de_combinacion = combinar(metodo, metodo_de_operacion)
    metodos_existentes.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar.reject! { |m| m.metodo.original_name == metodo.metodo.original_name }
    metodos_a_agregar << resultado_de_combinacion
  end

  private
  def combinar(metodo1, metodo2)
    modulo_temporal = Module.new
    proc_resolver_conflicto = @proc_resolver_conflicto
    modulo_temporal.define_method(metodo1.nombre) do |*args|

      proc_resolver_conflicto.call(metodo1.clonar_metodo, metodo2.clonar_metodo, *args)
    end

    metodo_resultado = modulo_temporal.instance_method(metodo1.nombre)
    TraitMethod.new(metodo_resultado, metodo1.nombre_del_trait)
  end
end