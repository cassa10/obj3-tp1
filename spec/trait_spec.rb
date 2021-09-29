require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait' do

  it 'cuando una clase usa un trait, luego puede responder los metodos de ese trait' do
    proc = proc do
      def un_metodo_del_trait
        10
      end
    end
    un_trait = Trait.new(&proc)

    una_clase = Class.new do
      uses un_trait
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(una_instancia_de_la_clase.un_metodo_del_trait).to eq 10
  end

end