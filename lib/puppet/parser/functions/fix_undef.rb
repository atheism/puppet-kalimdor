module Puppet::Parser::Functions
  newfunction(:fix_undef, :type => :rvalue, :arity => 1, :doc => "transforms '' to undef") do |args|
    case args[0]
    when ''
      nil
    else
      args[0]
    end
  end
end
