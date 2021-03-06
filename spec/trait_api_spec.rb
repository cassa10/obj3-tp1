require 'rspec'
require 'trait'
require 'trait_api'
require 'estrategia_de_conflictos'
require 'trait_simple'
require 'trait_compuesto'

describe 'Trait API' do

  around do |test|
    constantes_ya_definidas = Object.constants

    test.run

    constantes_definidas_por_el_test = Object.constants - constantes_ya_definidas
    constantes_definidas_por_el_test.each do |nombre_constante|
      Object.send(:remove_const, nombre_constante)
    end
  end

  it 'cuando una clase usa un trait con sus metodos, luego puede responder los metodos de ese trait' do
    trait :UnTrait do
      def metodo_del_trait
        10
      end
    end

    class UnaClase
      uses UnTrait
    end

    una_instancia_de_clase = UnaClase.new

    expect(una_instancia_de_clase.metodo_del_trait).to eq 10

  end

  it 'cuando una clase usa un trait que requiere ciertos metodos y esta clase no los implementa,
      pero estos metodos no se usan, no se levanta excepcion' do
    trait :UnTrait do
      requires :metodo_requerido

      def metodo_del_trait
        10
      end
    end

    class UnaClase
      uses UnTrait
    end

    expect do
      UnaClase.new.metodo_del_trait
    end.to_not raise_error

  end

  it 'cuando una clase implementa un trait con un metodo que utiliza self, luego self hace referencia a la instancia de la clase' do
    trait :UnTrait do

      def metodo_del_trait
        self
      end
    end

    class Cosa
      uses UnTrait
    end

    instancia = Cosa.new
    expect(instancia.metodo_del_trait).to eq instancia
  end

  it 'cuando una clase usa un trait que requiere un metodo, este lanza una excepcion si la clase no implementa algun metodo requerido' do
    trait :UnTrait do
      requires 'un_metodo'

      def metodo_del_trait
        un_metodo
      end
    end

    class Cosa
      uses UnTrait
    end

    expect { Cosa.new.metodo_del_trait }.to raise_error
  end

  it 'cuando una clase compone dos traits, luego sabe responder los metodos de ambos traits' do
    trait :UnTrait do
      def metodo_del_trait_1
        10
      end
    end

    trait :OtroTrait do
      def metodo_del_trait_2
        20
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait
    end

    expect(UnaClase.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase.new.metodo_del_trait_2).to eq(20)
  end

  it 'la composicion de traits es asociativa' do
    trait :UnTrait do
      def metodo_del_trait_1
        10
      end
    end

    trait :OtroTrait do
      def metodo_del_trait_2
        20
      end
    end

    trait :OtroTraitMas do
      def metodo_del_trait_3
        30
      end
    end

    class UnaClase
      uses UnTrait + (OtroTrait + OtroTraitMas)
    end

    class UnaClase2
      uses (UnTrait + OtroTrait) + OtroTraitMas
    end

    expect(UnaClase.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase.new.metodo_del_trait_2).to eq(20)
    expect(UnaClase.new.metodo_del_trait_3).to eq(30)

    expect(UnaClase2.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase2.new.metodo_del_trait_2).to eq(20)
    expect(UnaClase2.new.metodo_del_trait_3).to eq(30)
  end

  it 'cuando una clase compone dos traits con metodos requeridos y este no implementa alguno, entonces se lanza una excepcion al tratar de utilizarlo' do
    trait :UnTrait do
      requires :metodo_del_trait_2

      def metodo_del_trait_1
        metodo_del_trait_2
      end
    end

    trait :OtroTrait do
      requires :metodo_requerido

      def metodo_del_trait_2
        metodo_requerido
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait
    end

    expect(UnaClase.new.respond_to?(:metodo_del_trait_1)).to be_truthy
    expect(UnaClase.new.respond_to?(:metodo_del_trait_2)).to be_truthy
    expect { UnaClase.new.metodo_del_trait_1 }.to raise_error 'Metodo requerido no implementado'
    expect { UnaClase.new.metodo_del_trait_2 }.to raise_error 'Metodo requerido no implementado'
  end

  it 'cuando una clase compone dos traits que implementan el mismo metodo, se levanta una excepcion' do
    trait :UnTrait do

      def un_metodo
        "Vengo de UnTrait"
      end
    end

    trait :OtroTrait do

      def un_metodo
        "Vengo de OtroTrait"
      end
    end

    expect do
      class UnaClase
        uses UnTrait + OtroTrait
      end
    end.to raise_error("Conflicto entre metodos de traits")
  end

  it 'cuando una clase compone el mismo trait varias veces, luego la clase sabe responder los mensajes correctamente' do
    trait :UnTrait do

      def un_metodo
        10
      end
    end

    class UnaClase
      uses UnTrait + UnTrait
    end

    expect(UnaClase.new.un_metodo).to eq(10)
  end

  it 'cuando una clase compone varios trait varias veces, luego la clase sabe responder los mensajes correctamente' do
    trait :UnTrait do
      def un_metodo
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_metodo
        "otro_trait"
      end
    end

    class UnaClase
      uses (UnTrait + OtroTrait) + (OtroTrait + UnTrait)
    end

    instancia_de_una_clase = UnaClase.new
    expect(instancia_de_una_clase.un_metodo).to eq("un_trait")
    expect(instancia_de_una_clase.otro_metodo).to eq("otro_trait")
  end

  it 'cuando una clase compone un trait excluyendo un metodo, luego la clase no sabe responder a este metodo' do
    trait :UnTrait do
      def un_metodo
        10
      end

      def otro_metodo
        50
      end
    end

    class UnaClase
      uses UnTrait - :otro_metodo
    end

    instancia_de_una_clase = UnaClase.new
    expect(instancia_de_una_clase.respond_to?(:un_metodo)).to be_truthy
    expect(instancia_de_una_clase.respond_to?(:otro_metodo)).to be_falsey
  end

  it 'cuando una clase compone un trait excluyendo una lista de metodos, luego la instancia no sabe responder a los metodos de la lista' do
    trait :UnTrait do
      def un_metodo
        10
      end

      def otro_metodo
        50
      end

      def sarasa
        1234
      end
    end

    class UnaClase
      uses UnTrait - [:otro_metodo, :sarasa]
    end

    instancia_de_una_clase = UnaClase.new
    expect(instancia_de_una_clase.respond_to?(:un_metodo)).to be_truthy
    expect(instancia_de_una_clase.respond_to?(:otro_metodo)).to be_falsey
    expect(instancia_de_una_clase.respond_to?(:sarasa)).to be_falsey
  end

  it 'cuando una clase usa un trait excluyendo sucesivamente metodos, luego la instancia de la clase no sabe responder a estos metodos excluidos' do
    trait :UnTrait do
      def metodo_1
        10
      end

      def metodo_2
        50
      end

      def metodo_3
        1234
      end

      def metodo_4
        777
      end
    end

    class UnaClase
      uses UnTrait - :metodo_2 - :metodo_3 - :metodo_4
    end

    instancia_de_una_clase = UnaClase.new
    expect(instancia_de_una_clase.respond_to?(:metodo_1)).to be_truthy
    expect(instancia_de_una_clase.respond_to?(:metodo_2)).to be_falsey
    expect(instancia_de_una_clase.respond_to?(:metodo_3)).to be_falsey
    expect(instancia_de_una_clase.respond_to?(:metodo_4)).to be_falsey
  end

  it 'cuando una clase usa un trait y redefine metodos que implementa dicho trait con otros nombres, luego la instancia
      de clase sabe responder a los metodos originales y a los renombrados' do
    trait :UnTrait do
      def un_metodo_1
        "un_trait_met_1"
      end

      def un_metodo_2
        "un_trait_met_2"
      end

      def un_metodo_3
        self
      end
    end

    class UnaClase
      uses UnTrait << { un_metodo_1: :un_metodo_renombrado_1, un_metodo_3: :un_metodo_renombrado_3 }
    end

    instancia_de_una_clase = UnaClase.new
    expect(instancia_de_una_clase.un_metodo_1).to eq("un_trait_met_1")
    expect(instancia_de_una_clase.un_metodo_renombrado_1).to eq("un_trait_met_1")
    expect(instancia_de_una_clase.un_metodo_2).to eq("un_trait_met_2")
    expect(instancia_de_una_clase.un_metodo_3).to eq(instancia_de_una_clase)
    expect(instancia_de_una_clase.un_metodo_renombrado_3).to eq(instancia_de_una_clase)
  end

  it 'cuando una clase usa un trait renombrando un metodo que no define,
      luego se levanta una excepcion por metodo a renombrar no existente en el trait a operar' do
    trait :UnTrait do
      def un_metodo_1
        "un_trait_met_1"
      end
    end

    expect do
      class OtraClase
        uses UnTrait << { un_metodo_1: :renombrar_metodo_1, metodo_inexistente: :metodo_renombrado }
      end
    end.to raise_error("Metodo :metodo_inexistente no esta definido en el trait")
  end

  it 'cuando una clase usa un trait renombrando un metodo definido en la clase y no en el trait,
  luego se levanta una excepcion por metodo a renombrar no existente en el trait a operar' do
    trait :UnTrait do
      def un_metodo_1
        "un_trait_met_1"
      end
    end

    expect do
      class UnaClase
        uses UnTrait << { metodo_inexistente: :metodo_renombrado }

        def metodo_inexistente
          "sarasa"
        end
      end
    end.to raise_error("Metodo :metodo_inexistente no esta definido en el trait")
  end

  it 'cuando una clase implementa la composicion de dos traits donde alguno de estos se le esta substrayendo metodos, entonces
        la clase implementa la union de los metodos del que se le esta substrayendo juntos con los del otro trait' do
    trait :UnTrait do
      def un_trait_metodo
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_trait_metodo_0
        "otro_trait"
      end

      def otro_trait_metodo_1
        "otro_trait"
      end

      def otro_trait_metodo_2
        "otro_trait"
      end
    end

    class UnaClase
      uses UnTrait + (OtroTrait - [:otro_trait_metodo_0, :otro_trait_metodo_2])
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.respond_to?(:otro_trait_metodo_0)).to be_falsey
    expect(una_instancia_de_una_clase.respond_to?(:otro_trait_metodo_2)).to be_falsey
    expect(una_instancia_de_una_clase.un_trait_metodo).to eq("un_trait")
    expect(una_instancia_de_una_clase.otro_trait_metodo_1).to eq("otro_trait")
  end

  it 'cuando una clase implementa la composicion de dos traits y luego a este se le substrae metodos, entonces
        la clase implementa la union de los metodos de los traits compuestos menos los metodos substraidos' do
    trait :UnTrait do
      def un_trait_metodo_1
        "un_trait"
      end

      def un_trait_metodo_2
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_trait_metodo_1
        "otro_trait"
      end

      def otro_trait_metodo_2
        "otro_trait"
      end
    end

    class UnaClase
      uses (UnTrait + OtroTrait) - [:un_trait_metodo_1, :otro_trait_metodo_2]
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.respond_to?(:un_trait_metodo_1)).to be_falsey
    expect(una_instancia_de_una_clase.respond_to?(:otro_trait_metodo_2)).to be_falsey
    expect(una_instancia_de_una_clase.un_trait_metodo_2).to eq("un_trait")
    expect(una_instancia_de_una_clase.otro_trait_metodo_1).to eq("otro_trait")
  end

  it 'cuando una clase implementa la composicion de dos traits donde uno de estos se le esta renombrando metodos, entonces
        la clase implementa la union de los metodos de ambos traits junto a los metodos renombrados de dicho trait operado' do
    trait :UnTrait do
      def un_trait_metodo
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_trait_metodo_1
        "otro_trait_met_1"
      end

      def otro_trait_metodo_2
        "otro_trait_met_2"
      end
    end

    class UnaClase
      uses UnTrait + (OtroTrait << { otro_trait_metodo_1: :renombre_met_1, otro_trait_metodo_2: :renombre_met_2 })
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.un_trait_metodo).to eq("un_trait")
    expect(una_instancia_de_una_clase.otro_trait_metodo_1).to eq("otro_trait_met_1")
    expect(una_instancia_de_una_clase.renombre_met_1).to eq("otro_trait_met_1")
    expect(una_instancia_de_una_clase.otro_trait_metodo_2).to eq("otro_trait_met_2")
    expect(una_instancia_de_una_clase.renombre_met_2).to eq("otro_trait_met_2")
  end

  it 'cuando una clase implementa la composicion de dos traits y luego se le renombran metodos, entonces
        la clase implementa la union de los metodos de ambos traits junto a los metodos renombrados' do
    trait :UnTrait do
      def un_trait_metodo
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_trait_metodo_1
        "otro_trait_met_1"
      end

      def otro_trait_metodo_2
        "otro_trait_met_2"
      end
    end

    class UnaClase
      uses (OtroTrait + UnTrait) << { otro_trait_metodo_1: :renombre_met_1, un_trait_metodo: :renombre_met_2 }
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.un_trait_metodo).to eq("un_trait")
    expect(una_instancia_de_una_clase.renombre_met_2).to eq("un_trait")
    expect(una_instancia_de_una_clase.otro_trait_metodo_1).to eq("otro_trait_met_1")
    expect(una_instancia_de_una_clase.renombre_met_1).to eq("otro_trait_met_1")
    expect(una_instancia_de_una_clase.otro_trait_metodo_2).to eq("otro_trait_met_2")
  end

  it 'cuando una clase implementa el renombre de de algunos metodos de algun trait y luego se le restan algunos otros que existen, entonces la clase implementa
        la union de los metodos del trait original junto a los renombrados menos los metodos que se quieren substraer' do
    trait :UnTrait do
      def trait_metodo_1
        "trait_met_1"
      end

      def trait_metodo_2
        "trait_met_2"
      end

      def trait_metodo_3
        "trait_met_3"
      end
    end

    class UnaClase
      uses (UnTrait << { trait_metodo_1: :renombre_met_1, trait_metodo_3: :renombre_met_3 }) - [:trait_metodo_3, :renombre_met_1]
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.respond_to?(:trait_metodo_3)).to be_falsey
    expect(una_instancia_de_una_clase.respond_to?(:renombre_met_1)).to be_falsey
    expect(una_instancia_de_una_clase.trait_metodo_1).to eq("trait_met_1")
    expect(una_instancia_de_una_clase.trait_metodo_2).to eq("trait_met_2")
    expect(una_instancia_de_una_clase.renombre_met_3).to eq("trait_met_3")
  end

  it 'cuando una clase quiere implementar el renombre de algunos metodos de un trait que ya fueron substraidos,
        entonces se levanta una excepcion que dicho metodo no existe en el trait a renombrar' do
    trait :UnTrait do
      def trait_metodo_1
        "trait_met_1"
      end

      def trait_metodo_2
        "trait_met_2"
      end
    end

    expect do
      class UnaClase
        uses UnTrait - :trait_metodo_1 << { trait_metodo_2: :trait_metodo_2_renombrado, trait_metodo_1: :trait_metodo_1_renombrado }
      end
    end.to raise_error("Metodo :trait_metodo_1 no esta definido en el trait")
  end

  it 'cuando una clase implementa la composicion de dos traits donde algun metodo original se repite y uno de estos renombra y tambien elimina
        dicho metodo repetido, entonces la clase implementa la union de los metodos de ambos traits junto a los metodos renombrados de dicho trait operado' do
    trait :UnTrait do
      def metodo_1
        "un_trait"
      end
    end

    trait :OtroTrait do
      def metodo_1
        "otro_trait_met_1"
      end

      def metodo_2
        "otro_trait_met_2"
      end
    end

    class UnaClase
      uses UnTrait + ((OtroTrait << { metodo_1: :metodo_1_from_otro_trait }) - :metodo_1)
    end

    una_instancia_de_una_clase = UnaClase.new

    expect(una_instancia_de_una_clase.metodo_1).to eq("un_trait")
    expect(una_instancia_de_una_clase.metodo_1_from_otro_trait).to eq("otro_trait_met_1")
    expect(una_instancia_de_una_clase.metodo_2).to eq("otro_trait_met_2")
  end

  it "cuando una clase implementa la composicion de dos traits con metodos conflictivos, puedo usar una
      estrategia para que se use cualquiera de las dos implementaciones" do
    trait :UnTrait do
      def metodo_1
        "un_trait"
      end
    end

    trait :OtroTrait do
      def metodo_1
        "otro_trait"
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait, on_conflict: [CualquierImplementacion.new([:metodo_1])]
    end

    instancia = UnaClase.new
    expect(instancia.respond_to?(:metodo_1)).to be_truthy
    expect(instancia.metodo_1 == "un_trait" || instancia.metodo_1 == "otro_trait").to be_truthy
  end

  it "cuando una clase implementa la composicion de dos traits con metodos conflictivos y una estrategia para resolverlos
      pero los metodos que entran en conflicto no son los contemplados por la estrategia, se levanta una excepcion" do
    trait :UnTrait do
      def metodo_1
        "un_trait"
      end
    end

    trait :OtroTrait do
      def metodo_1
        "otro_trait"
      end
    end

    expect do
      class UnaClase
        uses UnTrait + OtroTrait, on_conflict: [CualquierImplementacion.new(:metodo_2)]
      end
    end.to raise_error("Conflicto entre metodos de traits")
  end

  it "cuando una clase implementa la composicion de dos traits con metodos conflictivos, puedo usar una
      estrategia para que se ejecuten todas las implementaciones" do
    trait :UnTrait do
      def metodo_1
        ejecutados << "un trait"
      end
    end

    trait :OtroTrait do
      def metodo_1
        ejecutados << "otro trait"
      end
    end

    trait :AlgunTrait do
      def metodo_1
        ejecutados << "algun trait"
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait + AlgunTrait, on_conflict: [ImplementacionDeTodos.new(:metodo_1)]

      attr_reader :ejecutados

      def initialize
        super
        @ejecutados = []
      end
    end

    instancia = UnaClase.new
    instancia.metodo_1
    expect(instancia.ejecutados).to contain_exactly("un trait", "otro trait", "algun trait")
  end

  it "cuando una clase implementa la composicion de dos traits con metodos conflictivos, puedo usar una
      estrategia para que se combinen todas las implementaciones y se retorne el resultado" do
    trait :UnTrait do
      def metodo_1(n)
        n + 10
      end
    end

    trait :OtroTrait do
      def metodo_1(n)
        n + 20
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait, on_conflict: [
        InjectReduce.new(:metodo_1, 0, proc { |acc, n| acc + n })
      ]
    end

    instancia = UnaClase.new
    expect(instancia.metodo_1(100)).to eq(230)
  end

  it "cuando una clase implementa la composicion de multiples traits con metodos conflictivos, puedo usar una
      estrategia para que se combinen todas las implementaciones y se retorne el resultado" do
    trait :UnTrait do
      def metodo_1(s)
        s + " untrait"
      end
    end

    trait :OtroTrait do
      def metodo_1(s)
        s + " otrotrait"
      end
    end

    trait :OtroTraitMas do
      def metodo_1(s)
        s + " otrotraitmas"
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait + OtroTraitMas, on_conflict: [
        InjectReduce.new(:metodo_1, "", proc { |acc, s| "(" + acc + s + ")" })
      ]
    end

    instancia = UnaClase.new
    expect(instancia.metodo_1("hola")).to eq("(((hola untrait)hola otrotrait)hola otrotraitmas)")
  end

  it "cuando una clase implementa la composicion de dos traits con algun metodo conflictivo y este se define que se resuelve con una
        estrategia personalizable, luego se resuelve dicho conflicto con esta nueva definicion creada en la estrategia" do
    trait :UnTrait do
      def metodo_parametrizado_1(n)
        n + 10
      end

      def metodo_parametrizado_2(x)
        "z) " + x
      end
    end

    trait :OtroTrait do
      def metodo_parametrizado_1(n)
        n + 20
      end

      def metodo_parametrizado_2(x)
        "a) " + x
      end
    end

    trait :AlgunTrait do
      def metodo_parametrizado_1(n)
        n + 50
      end

      def metodo_parametrizado_2(x)
        "b) " + x
      end
    end

    class UnaClase
      uses UnTrait + AlgunTrait + OtroTrait, on_conflict: [
        Personalizable.new([:metodo_parametrizado_1, :metodo_parametrizado_2], proc do |metodos, x|
          metodos.map { |metodo| metodo.call(x) }.max
        end)
      ]
    end

    instancia = UnaClase.new
    expect(instancia.metodo_parametrizado_1(100)).to eq(150)
    #max agarra el ultimo string por orden alfabetico
    expect(instancia.metodo_parametrizado_2('item')).to eq("z) item")
  end

  it "cuando una clase implementa la composicion de dos traits con metodos conflictivos, puede usar una estrategia
    para resolver conflictos con un metodo y una estrategia distinta para otro metodo" do
    trait :UnTrait do
      def metodo_parametrizado_1(n)
        n + 10
      end

      def metodo_2
        90
      end

      def metodo_parametrizado_3(n)
        n + 1
      end
    end

    trait :OtroTrait do
      def metodo_parametrizado_1(n)
        n + 20
      end

      def metodo_2
        190
      end

      def metodo_parametrizado_3(n)
        n * 2
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait, on_conflict: [
        InjectReduce.new(:metodo_parametrizado_1, 0, proc { |acc, n| acc + n }),
        CualquierImplementacion.new(:metodo_2),
        Personalizable.new(:metodo_parametrizado_3, proc { |_, n| n })
      ]
    end

    instancia = UnaClase.new
    expect(instancia.metodo_parametrizado_1(100)).to eq(230)
    expect(instancia.metodo_2 == 90 || instancia.metodo_2 == 190).to be_truthy
    expect(instancia.metodo_parametrizado_3(5)).to eq(5)
  end

  it 'cuando se le pide la description a un trait, luego este devuelve su nombre junto a el conjunto de operaciones aplicado' do
    trait :UnTrait do
      def m1
        "un_trait"
      end

      def m2
        "un_trait"
      end

      def m3
        "un_trait"
      end
    end

    trait :OtroTrait do
      def otro_m1
        "otro_trait"
      end
    end

    expect(UnTrait.description).to eq "UnTrait"
    expect((UnTrait + OtroTrait).description).to eq "UnTrait + OtroTrait"
    expect((UnTrait - :m1 + OtroTrait).description).to eq "UnTrait - [:m1] + OtroTrait"
    expect((UnTrait - [:m1, :m2] + OtroTrait).description).to eq "UnTrait - [:m1, :m2] + OtroTrait"
    expect((OtroTrait << { otro_m1: :renombre_m1 }).description).to eq "OtroTrait << {:otro_m1=>:renombre_m1}"
    expect((UnTrait << { m1: :renombre_m1, m3: :renombre_m3 }).description).to eq "UnTrait << {:m1=>:renombre_m1, :m3=>:renombre_m3}"
  end


  it 'cuando una clase usa un trait donde este usa a otro trait, luego la clase compone a ambos traits' do
    trait :OtroTrait do
      def otro_m1
        "otro_trait"
      end
    end

    trait :UnTrait do
      uses OtroTrait
      def m1
        "un_trait"
      end

      def m2
        "un_trait"
      end

      def m3
        "un_trait"
      end
    end

    class UnaClase
      uses UnTrait
    end

    instancia = UnaClase.new
    expect(instancia.m1).to eq("un_trait")
    expect(instancia.m2).to eq("un_trait")
    expect(instancia.m3).to eq("un_trait")
    expect(instancia.otro_m1).to eq("otro_trait")
  end

end