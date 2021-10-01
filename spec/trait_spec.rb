require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait' do

  it 'cuando una clase usa un trait, luego puede responder los metodos de ese trait' do
    #TODO: Agregar otro trait para triangular
    metodos = (MethodParser.new do
      def un_metodo_del_trait
        10
      end
    end).obtener_metodos

    un_trait = Trait.new(metodos)

    una_clase = Class.new do
      uses un_trait
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(una_instancia_de_la_clase.un_metodo_del_trait).to eq 10
  end

  it 'cuando una clase usa un trait que requiere un metodo, este lanza una excepcion si la clase no implementa algun metodo requerido' do

    metodos = (MethodParser.new do
      def un_metodo_del_trait
        10
      end
    end).obtener_metodos

    metodos_requeridos_trait1 = [:metodo_requerido]
    #TODO: Revisar con profes o opiniones de esto (ESTRATEGIA DE TESTING/TRIANGULACION)
    metodos_requeridos_trait2 = [:algun_metodo, :metodo_requerido]

    trait_1 = Trait.new(metodos, metodos_requeridos_trait1)
    trait_2 = Trait.new(metodos, metodos_requeridos_trait2)

    expect do
      Class.new do
        uses trait_1
      end
    end.to raise_error("no tiene definido los metodos requeridos")

    expect do
      Class.new do
        uses trait_2

        def algun_metodo
          "sarasa"
        end
      end
    end.to raise_error("no tiene definido los metodos requeridos")

  end

  it 'asldasldjk' do

    metodos = (MethodParser.new do
      def un_metodo_del_trait
        10
      end
    end).obtener_metodos

    metodos_requeridos = [:algun_metodo]

    trait_1 = Trait.new(metodos, metodos_requeridos)

    una_clase = Class.new do
      uses trait_1

      def algun_metodo
        "sarasa"
      end
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase).to
  end
end