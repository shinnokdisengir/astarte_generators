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

defmodule Astarte.Core.Generators.Value do
  @moduledoc """
  This module provides generators for any Value type.
  """
  use ExUnitProperties

  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping

  alias Astarte.Common.Generators.DateTime, as: DateTimeGenerator
  alias Astarte.Common.Generators.Timestamp, as: TimestampGenerator
  alias Astarte.Core.Generators.Mapping, as: MappingGenerator

  @doc """
  Generates a valid value based on interface
  """
  @spec value(Interface.t()) :: StreamData.t(map())
  def value(%Interface{} = interface) when not is_struct(interface, StreamData) do
    interface |> constant() |> value()
  end

  @spec value(StreamData.t(Interface.t())) :: StreamData.t(map())
  def value(gen) do
    gen all %Interface{
              mappings: mappings,
              aggregation: aggregation
            } <- gen,
            %Mapping{
              endpoint: endpoint
            } <- member_of(mappings),
            endpoint = interface_endpoint(aggregation, endpoint),
            path <- endpoint_path(endpoint),
            value <- build_value(aggregation, mappings) do
      %{
        path: path,
        value: value
      }
    end
  end

  defp interface_endpoint(:individual, endpoint), do: endpoint
  defp interface_endpoint(:object, endpoint), do: String.replace(endpoint, ~r"/[^/]+$", "")

  defp endpoint_path(endpoint) do
    endpoint
    |> String.split("/")
    |> Enum.map(&convert_token/1)
    |> fixed_list()
    |> map(&Enum.join(&1, "/"))
  end

  defp convert_token(token) do
    case(Mapping.is_placeholder?(token)) do
      true -> MappingGenerator.endpoint_segment()
      false -> constant(token)
    end
  end

  defp build_value(:individual, [%Mapping{value_type: value_type} | _]) do
    value_from_type(value_type)
  end

  defp build_value(:object, [%Mapping{} | _] = mappings) do
    mappings |> Map.new(&object_value/1) |> optional_map()
  end

  defp type_array(:doublearray), do: :double
  defp type_array(:integerarray), do: :integer
  defp type_array(:longintegerarray), do: :longinteger
  defp type_array(:booleanarray), do: :boolean
  defp type_array(:stringarray), do: :string
  defp type_array(:binaryblobarray), do: :binaryblob
  defp type_array(:datetimearray), do: :datetime

  defp value_from_type(:double), do: float()
  defp value_from_type(:integer), do: integer(-0x7FFFFFFF..0x7FFFFFFF)
  defp value_from_type(:boolean), do: boolean()
  defp value_from_type(:longinteger), do: integer(-0x7FFFFFFFFFFFFFFF..0x7FFFFFFFFFFFFFFF)
  defp value_from_type(:string), do: string(:utf8, max_length: 65_535)
  defp value_from_type(:binaryblob), do: map(binary(max_length: 65_535), &Base.encode64/1)

  defp value_from_type(:datetime),
    do:
      one_of([
        TimestampGenerator.timestamp(),
        DateTimeGenerator.date_time() |> map(&DateTime.to_iso8601/1)
      ])

  defp value_from_type(array) when is_atom(array),
    do: type_array(array) |> value_from_type() |> list_of(max_legth: 1023)

  defp object_value(%Mapping{} = mapping) do
    %Mapping{endpoint: endpoint, value_type: value_type} = mapping
    {String.replace(endpoint, ~r"^.*/", ""), value_from_type(value_type)}
  end
end
