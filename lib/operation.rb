require 'operation_type'

class Operation

  def initialize(operation_type, operator)
    super()
    #OperationType = :+ | :- | :<<
    @operation_type = validate_operation_type(operation_type)
    #Operator = Trait | [:method]
    @operator = operator
  end

  def description
    " " + @operation_type.to_s + " " + @operator.to_s
  end


end
