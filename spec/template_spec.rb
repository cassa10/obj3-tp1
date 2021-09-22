require 'rspec'
require 'template'

class Prueba
  # uses Dummy
end


describe 'template tests' do

  it 'xd' do
    trait :Dummy do
      def un_metodo_del_trait
        10
      end
    end

    expect(Prueba.new.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(Prueba.new.un_metodo_del_trait).to be(10)
  end

end