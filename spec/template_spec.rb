require 'rspec'
require 'template'

describe 'template tests' do

  it 'un template saluda con "Hola!"' do
    un_template = Template.new

    expect(un_template.saludar).to eq("Hola!")
  end

end