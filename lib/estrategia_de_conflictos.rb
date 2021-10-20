require 'combinable'

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

class ImplementacionDeAmbos < EstrategiaDeConflictos
  include Combinable

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_combinado = metodo.combinar_con(metodos_a_agregar.first { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo) })
    reemplazar_metodo(metodo, metodo_combinado, metodos_a_agregar, metodos_existentes)
  end

end

class InjectReduce < EstrategiaDeConflictos
  include Combinable

  def initialize(metodos = [], valor_inicial, funcion_combinadora)
    super(metodos)
    @valor_inicial = valor_inicial
    @funcion_combinadora = funcion_combinadora
  end

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_de_operacion = metodos_a_agregar.find { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo.nombre) }
    resultado_de_reduccion = metodo.reducir_con(metodo_de_operacion, @valor_inicial, @funcion_combinadora)
    reemplazar_metodo(metodo, resultado_de_reduccion, metodos_a_agregar, metodos_existentes)
  end
end

class Personalizable < EstrategiaDeConflictos
  include Combinable

  def initialize(metodos = [], bloque_combinador)
    super(metodos)
    @proc_resolver_conflicto = bloque_combinador
  end

  def manejar_conflicto(metodo, metodos_existentes, metodos_a_agregar)
    metodo_de_operacion = metodos_a_agregar.first { |metodo_a_agregar| metodo_a_agregar.mismo_simbolo?(metodo) }
    resultado_de_combinacion = combinar(metodo, metodo_de_operacion)
    reemplazar_metodo(metodo, resultado_de_combinacion, metodos_a_agregar, metodos_existentes)
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
