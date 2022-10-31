# frozen_string_literal: true

module Sequent
  module Core
    module Middleware
      class Chain
        attr_reader :entries

        def initialize
          clear
        end

        def add(middleware)
          @entries.push(middleware)
        end

        def clear
          @entries = []
        end

        def invoke(*args, &invoker)
          chain = @entries.dup

          traverse_chain = -> do
            if chain.empty?
              invoker.call
            else
              chain.shift.call(*args, &traverse_chain)
            end
          end

          traverse_chain.call
        end
      end
    end
  end
end
