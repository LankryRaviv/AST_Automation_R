# frozen_string_literal: true

load_utility('Operations/MICRON/Routing/routing_operations_delegate_cosmos.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')

# RoutingOperationsDelegateCosmosLSL
class RoutingOperationsDelegateCosmosLSL < RoutingOperationsDelegateCosmos
  def initialize(print_debug)
    super('MIC_LSL', print_debug)
  end
end
