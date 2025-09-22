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

defmodule Astarte.Core.Generators.Triggers.SimpleEvents.CommonDataEvent do
  @moduledoc false
  use ExUnitProperties

  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping

  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator
  alias Astarte.Core.Generators.Mapping.Value, as: ValueGenerator

  @spec common_data_event() :: StreamData.t(map())
  def common_data_event do
    gen all %Interface{
              aggregation: aggregation,
              mappings: mappings
            } = interface <- InterfaceGenerator.interface(),
            %{path: path} = value <- ValueGenerator.value(interface: interface),
            %Mapping{type: type, endpoint: endpoint} =
              mapping =
              mappings
              |> Enum.find(fn %Mapping{endpoint: endpoint} ->
                ValueGenerator.path_matches_endpoint?(aggregation, endpoint, path)
              end),
            endpoint = InterfaceGenerator.endpoint_by_aggregation(aggregation, endpoint) do
      %{
        interface: interface,
        mapping: mapping,
        value: value,
        path: path,
        endpoint: endpoint,
        type: type
      }
    end
  end
end
