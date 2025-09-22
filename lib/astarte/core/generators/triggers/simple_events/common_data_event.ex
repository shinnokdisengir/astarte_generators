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

  import Astarte.Generators.Utilities.ParamsGen

  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping

  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator
  alias Astarte.Core.Generators.Mapping.Value, as: ValueGenerator

  @spec common_data_event() :: StreamData.t(map())
  @spec common_data_event(keyword :: keyword()) :: StreamData.t(map())
  def common_data_event(params \\ []) do
    params gen all interface <- InterfaceGenerator.interface(),
                   %Interface{
                     name: interface_name,
                     aggregation: aggregation,
                     mappings: mappings
                   } = interface,
                   path <-
                     ValueGenerator.value(interface: interface)
                     |> map(fn %{path: path} -> path end),
                   %Mapping{type: type, endpoint: endpoint} =
                     mappings
                     |> Enum.find(fn %Mapping{endpoint: endpoint} ->
                       ValueGenerator.path_matches_endpoint?(aggregation, endpoint, path)
                     end),
                   params: params do
      %{
        interface: interface_name,
        path: path,
        endpoint: endpoint,
        type: type
      }
    end
  end
end
