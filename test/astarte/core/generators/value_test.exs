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

defmodule Astarte.Core.Generators.ValueTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping

  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator
  alias Astarte.Core.Generators.Mapping, as: MappingGenerator
  alias Astarte.Core.Generators.Value, as: ValueGenerator

  @moduletag :value

  defp valid?(:individual, %{value: value})
       when is_list(value) or is_float(value) or is_integer(value) or is_binary(value) or
              is_boolean(value) or is_struct(value, DateTime),
       do: true

  defp valid?(:object, %{value: value}) when is_map(value), do: true

  defp valid?(_, _), do: false

  @endpoint_param_regex ~r"%{[\w_][\w\d_]*}"
  @endpoint_param_sub ~S"[\w_][\w\d_]*"
  defp build_regex(endpoint),
    do:
      @endpoint_param_regex
      |> Regex.replace(endpoint, @endpoint_param_sub)
      |> Regex.compile!()

  defp path_matches_endpoint?(path, endpoint) do
    endpoint |> build_regex() |> Regex.match?(path)
  end

  defp path_matches_endpoint?(:individual, path, endpoint),
    do: path_matches_endpoint?(path, endpoint)

  defp path_matches_endpoint?(:object, path, endpoint),
    do: path_matches_endpoint?(path, String.replace(endpoint, ~r"/[^/]+$", ""))

  @doc false
  describe "value generator" do
    @describetag :success
    @describetag :ut

    property "generates value based on interface" do
      check all value <- InterfaceGenerator.interface() |> ValueGenerator.value() do
        assert %{path: _path, value: _value} = value
      end
    end

    property "generates valid value based on aggregation" do
      check all aggregation <- one_of([:individual, :object]),
                value <-
                  InterfaceGenerator.interface(aggregation: aggregation)
                  |> ValueGenerator.value() do
        assert valid?(aggregation, value)
      end
    end

    property "check if path matches at least one endpoint considering aggregation" do
      check all aggregation <- one_of([:individual, :object]),
                interface_type <- InterfaceGenerator.type(),
                mappings <-
                  MappingGenerator.mapping(interface_type: interface_type)
                  |> list_of(min_length: 1, max_length: 10),
                %{path: path} <-
                  InterfaceGenerator.interface(
                    type: interface_type,
                    aggregation: aggregation,
                    mappings: mappings
                  )
                  |> ValueGenerator.value() do
        assert Enum.any?(mappings, fn %Mapping{endpoint: endpoint} ->
                 path_matches_endpoint?(aggregation, path, endpoint)
               end)
      end
    end

    property "check field is present in object field (aggregation :object)" do
      check all %{mappings: mappings} = interface <-
                  InterfaceGenerator.interface(aggregation: :object),
                %{value: value} <- ValueGenerator.value(interface),
                endpoints =
                  mappings
                  |> Enum.map(fn %Mapping{endpoint: endpoint} ->
                    Regex.replace(~r"^.*/", endpoint, "")
                  end),
                fields = value |> Enum.map(fn {field, _} -> field end) do
        assert Enum.all?(fields, &(&1 in endpoints))
      end
    end
  end
end
