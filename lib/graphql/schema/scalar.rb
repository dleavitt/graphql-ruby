# frozen_string_literal: true
module GraphQL
  class Schema
    class Scalar < GraphQL::Schema::Member
      extend GraphQL::Schema::Member::ValidatesInput

      class << self
        def coerce_input(val, ctx)
          val
        end

        def coerce_result(val, ctx)
          val
        end

        def kind
          GraphQL::TypeKinds::SCALAR
        end

        def specified_by_url(new_url = nil)
          if new_url
            @specified_by_url = new_url
          elsif defined?(@specified_by_url)
            @specified_by_url
          elsif superclass.respond_to?(:specified_by_url)
            superclass.specified_by_url
          else
            nil
          end
        end

        def default_scalar(is_default = nil)
          if !is_default.nil?
            @default_scalar = is_default
          end
          @default_scalar
        end

        def default_scalar?
          @default_scalar ||= false
        end

        def validate_non_null_input(value, ctx)
          result = Query::InputValidationResult.new
          coerced_result = begin
            ctx.query.with_error_handling do
              coerce_input(value, ctx)
            end
          rescue GraphQL::CoercionError => err
            err
          end

          if coerced_result.nil?
            str_value = if value == Float::INFINITY
              ""
            else
              " #{GraphQL::Language.serialize(value)}"
            end
            result.add_problem("Could not coerce value#{str_value} to #{graphql_name}")
          elsif coerced_result.is_a?(GraphQL::CoercionError)
            result.add_problem(coerced_result.message, message: coerced_result.message, extensions: coerced_result.extensions)
          end
          result
        end
      end
    end
  end
end
