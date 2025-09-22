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

defmodule Astarte.Core.Generators.Triggers.SimpleEvents.ValueStoredEventTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping
  alias Astarte.Core.Mapping.ValueType
  alias Astarte.Core.Triggers.SimpleEvents.ValueStoredEvent

  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator
  alias Astarte.Core.Generators.Mapping.Value, as: ValueGenerator

  alias Astarte.Core.Generators.Triggers.SimpleEvents.ValueStoredEvent,
    as: ValueStoredEventGenerator

  @moduletag :trigger
  @moduletag :simple_event
  @moduletag :value_stored_event

  @doc false
  describe "triggers value_stored_event generator" do
    @describetag :success
    @describetag :ut
    property "generates valid value_stored_event" do
      check all value_stored_event <- ValueStoredEventGenerator.value_stored_event() do
        assert %ValueStoredEvent{} = value_stored_event
      end
    end

    property "check mapping types using passed interface generator" do
      check all interface <- InterfaceGenerator.interface(),
                %Interface{
                  aggregation: aggregation,
                  mappings: mappings
                } = interface,
                %ValueStoredEvent{
                  path: path,
                  bson_value: bson_value
                } <-
                  ValueStoredEventGenerator.value_stored_event(interface: interface)
                  |> filter(
                    fn %ValueStoredEvent{path: path} -> not is_nil(path) end,
                    1_000_000
                  ),
                %Mapping{type: type} =
                  mappings
                  |> Enum.find(fn %Mapping{endpoint: endpoint} ->
                    ValueGenerator.path_matches_endpoint?(aggregation, endpoint, path)
                  end) do
        assert is_nil(bson_value) or :ok == ValueType.validate_value(type, bson_value)
      end
    end
  end
end
