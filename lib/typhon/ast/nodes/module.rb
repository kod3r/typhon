module Typhon
  module AST

    class Body < ClosedScope
      def initialize(statement, line)
        @statement = statement
        @line = line
      end

      def bytecode(g)
        pos(g)

        @statement.bytecode(g)
        # dont pop if last node result was already popped (by
        # DiscardNode) or if no statements were present on this body.
        unless @statement.empty? || @statement.nodes.last.kind_of?(DiscardNode)
          g.pop
        end

        g.push_self
      end
    end

    class ModuleBody < Body
      def module?
        true
      end
    end

    class ModuleNode < ClosedScope
      attr_reader :parent #always nil for now.

      def bytecode(g)
        pos(g)

        g.push_const(:Typhon)
        g.find_const(:Environment)
        g.send(:get_python_module, 0)

        if (@doc)
          g.dup
          g.push_literal(:__doc__)
          g.push_literal(@doc)
          g.send(:[]=, 2)
          g.pop
        end

        @body = ModuleBody.new(@node, @line)
        attach_and_call(g, :__module_init__, false)
        g.ret # Actually want to return the module object to the enclosing scope.
      end
    end
  end
end