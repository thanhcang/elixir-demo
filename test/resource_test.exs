defmodule Maru.Builder.ResourceTest do
  use ExUnit.Case, async: true

  alias Maru.Resource
  alias Maru.Builder.Parameter
  alias Maru.Builder.Parameter.Information

  test "namespaces" do
    defmodule Test do
      use Maru.Builder

      resources :p1 do
        def r1, do: @resource

        resource :p2 do
          def r2, do: @resource
        end

        route_param :p3, type: Integer do
          def r3, do: @resource

          segment :p4 do
            def r4, do: @resource
          end
        end

        group :p5 do
          def r5, do: @resource
        end
      end

      route_param :p6 do
        def r6, do: @resource
      end
    end

    assert %Resource{path: ["p1"]} = Test.r1()
    assert %Resource{path: ["p1", "p2"]} = Test.r2()

    assert %Resource{
             path: ["p1", :p3],
             parameters: [
               %Parameter{
                 information: %Information{
                   attr_name: :p3
                 }
               }
             ]
           } = Test.r3()

    assert %Resource{
             path: ["p1", :p3, "p4"],
             parameters: [
               %Parameter{
                 information: %Information{
                   attr_name: :p3
                 }
               }
             ]
           } = Test.r4()

    assert %Resource{path: ["p1", "p5"], parameters: []} = Test.r5()

    assert %Resource{
             path: [:p6],
             parameters: [
               %Parameter{
                 information: %Information{
                   attr_name: :p6
                 }
               }
             ]
           } = Test.r6()
  end

  test "methods" do
    defmodule MethodsTest do
      use Maru.Builder

      get do
        text(conn, "get")
      end

      match do
        text(conn, "match")
      end

      def route, do: @routes
    end

    assert [
             %{method: :match, path: []},
             %{method: :get, path: []}
           ] = MethodsTest.route()
  end
end
