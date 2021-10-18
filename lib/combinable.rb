module Combinable
  def reemplazar_metodo(metodo_viejo, metodo_nuevo, lista_metodos_nuevos, lista_metodos_existentes)
    lista_metodos_existentes.reject! { |m| m.mismo_nombre? metodo_viejo }
    lista_metodos_nuevos.reject! { |m| m.mismo_nombre? metodo_viejo }
    lista_metodos_nuevos << metodo_nuevo
  end
end
