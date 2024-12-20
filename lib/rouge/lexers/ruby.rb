# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Ruby < Lexer
      title "Ruby"
      desc "The Ruby programming language (ruby-lang.org)"
      tag 'ruby'
      aliases 'rb'
      filenames '*.rb', '*.ruby', '*.rbw', '*.rake', '*.gemspec', '*.podspec',
                'Rakefile', 'Guardfile', 'Gemfile', 'Capfile', 'Podfile',
                'Vagrantfile', '*.ru', '*.prawn', 'Berksfile', '*.arb',
                'Dangerfile', 'Fastfile', 'Deliverfile', 'Appfile'

      mimetypes 'text/x-ruby', 'application/x-ruby'

      def self.detect?(text)
        return true if text.shebang? 'ruby'
      end

      def stream_tokens(string, &block)
        require "prism"

        v = RougeVisitor.new
        Prism.parse(string).value.accept(v)
        v.tokens.each(&block)
      end

      class RougeVisitor < Prism::BasicVisitor
        include Rouge::Token::Tokens

        attr_reader :tokens

        def initialize
          @tokens = []
          @last_location = nil
        end

        def visit_program_node(node)
          program_location = node.location

          @tokens << [Text::Whitespace, "\n" * program_location.start_line]
          @tokens << [Text::Whitespace, " " * program_location.start_column]
          @last_location = node.location

          visit_child_nodes(node)
        end

        alias visit_statements_node visit_child_nodes

        def visit_array_node(node)
        end

        def visit_call_node(node)
        end
        
        def visit_class_node(node)
        end

        def visit_def_node(node)
        end

        def visit_float_node(node)
          append_whitespace_until(node)

          @tokens << [Literal::Number::Float, node.location.slice]
          @last_location = node.location
        end

        def visit_if_node(node)
        end

        def visit_local_variable_write_node(node)
        end

        def visit_missing_node(node)
        end

        def visit_module_node(node)
        end

        def visit_parentheses_node(node)
        end

        def visit_range_node(node)
        end

        def visit_symbol_node(node)
          append_whitespace_until(node)

          @tokens << [Literal::String::Symbol, "#{node.opening}#{node.value}"]
          @last_location = node.location
        end

        def visit_unless_node(node)
        end

        def visit_while_node(node)
        end

        private

        def append_whitespace_until(node)
          lines_to_append = node.location.start_line - @last_location.end_line
          return unless lines_to_append > 0
          
          @tokens << [Text::Whitespace, "\n" * lines_to_append]
          
          spaces_to_append = node.location.start_column - @last_location.end_column
          return unless spaces_to_append > 0

          @tokens << [Text::Whitespace, " " * spaces_to_append]
        end
      end
    end
  end
end
