require 'rspec'
require 'template'

trait :Dummy do
  def un_metodo_del_trait
    10
  end
end

class Prueba
  uses Dummy
end

describe 'template tests' do

  it 'xd' do
    prueba = Prueba.new

    expect(prueba.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(prueba.un_metodo_del_trait).to eq 10
  end
end