OPERATION_TYPE = {
  "+": 1,
  "-": 2,
}

def validate_operation_type(value)
  raise 'invalid operation type' unless is_operation_type(value)
  value
end

# value is true when is ':+' or ':-'
def is_operation_type(value)
  OPERATION_TYPE.key?value
end




