#
# This file is part of Astarte.
#
# Copyright 2025 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Generators.Utilities.ParamsGenTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Astarte.Generators.Utilities.ParamsGen

  @moduletag :params
  @moduletag :fans

  defp gen_helper do
    gen all a <- integer(0..0),
            b <- string(?a..?a, length: 1),
            c <- constant("friend") do
      {a, b, c}
    end
  end

  defp param_gen_helper(params) do
    params gen all a <- integer(0..0),
                   b <- string(?a..?a, length: 1),
                   c <- constant("friend"),
                   params: params do
      {a, b, c}
    end
  end

  defp param_gen_eq_helper(params) do
    params gen all a <- integer(0..0),
                   {:ok, 0} = {:ok, a},
                   a1 = a,
                   b <- string(?a..?a, length: 1),
                   b1 = b,
                   c <- constant("friend"),
                   c1 = c,
                   params: params do
      {a1, b1, c1}
    end
  end

  defp gen_params do
    gen all a <- integer(), b <- string(:ascii) do
      [a: a, b: b]
    end
  end

  defp function_params(b) do
    [a: 10, b: b]
  end

  defp gen_fixtures(_context) do
    {
      :ok,
      gen: &gen_helper/0,
      param_gen: &param_gen_helper/1,
      param_gen_eq: &param_gen_eq_helper/1,
      gen_params: &gen_params/0,
      function_params: &function_params/1
    }
  end

  setup_all :gen_fixtures

  @doc false
  describe "gen_param unit tests" do
    @describetag :success
    @describetag :ut

    property "gen_param does not intervene", %{gen: gen} do
      check all {a, b, c} <- gen_param(gen.(), :value, other_value: "a") do
        assert a == 0
        assert b == "a"
        assert c == "friend"
      end
    end

    property "gen_param constant override", %{gen: gen} do
      check all value <- gen_param(gen.(), :value, value: "a") do
        assert value == "a"
      end
    end

    property "gen_param function override", %{gen: gen, function_params: function_params} do
      check all value <- gen_param(gen.(), :value, value: function_params.("a")) do
        assert [a: 10, b: "a"] == value
      end
    end

    property "gen_param generator override", %{gen: gen, gen_params: gen_params} do
      check all [
                  a: int_value,
                  b: string_value
                ] <- gen_param(gen.(), :value, value: gen_params.()) do
        assert is_integer(int_value) and is_binary(string_value)
      end
    end
  end

  @doc false
  describe "param gen all unit tests" do
    @describetag :success
    @describetag :ut

    property "gen all parity features (without override)",
             %{
               gen: gen,
               param_gen: param_gen
             } do
      check all {a1, b1, c1} <- gen.(),
                {a2, b2, c2} <- param_gen.([]),
                max_runs: 1 do
        assert a1 == a2
        assert b1 == b2
        assert c1 == c2
      end
    end

    @tag :issue
    property "param gen all does not crash using = op",
             %{
               gen: gen,
               param_gen_eq: param_gen_eq
             } do
      check all {a1, b1, c1} <- gen.(),
                {a2, b2, c2} <- param_gen_eq.([]),
                max_runs: 1 do
        assert a1 == a2
        assert b1 == b2
        assert c1 == c2
      end
    end

    property "param gen all overridden by kw", %{
      param_gen: param_gen,
      gen_params: gen_params
    } do
      check all params <- gen_params.(),
                {a, b, _} <- param_gen.(params) do
        assert params[:a] == a
        assert params[:b] == b
      end
    end

    property "param gen all overridden by generators", %{
      param_gen: param_gen
    } do
      check all {a, _, _} <- param_gen.(a: string(?c..?c, length: 1)) do
        assert a == "c"
      end
    end

    property "param gen all overridden by function", %{
      param_gen: param_gen,
      function_params: function_params
    } do
      check all s <- string(:ascii),
                {a, b, _} <- param_gen.(function_params.(s)) do
        assert a == 10
        assert b == s
      end
    end

    property "param gen all overridden by static value for c", %{param_gen: param_gen} do
      check all string_value <- string(:utf8),
                {_, _, c} <- param_gen.(c: string_value) do
        assert c == string_value
      end
    end
  end
end
