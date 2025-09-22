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

defmodule Astarte.Core.Generators.Triggers.SimpleEvents.CommonDataEventTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Core.Generators.Triggers.SimpleEvents.CommonDataEvent,
    as: CommonDataEventGenerator

  @moduletag :trigger
  @moduletag :simple_event
  @moduletag :common_data_event

  @doc false
  describe "triggers common_data_event generator" do
    @describetag :success
    @describetag :ut
    property "generates valid common_data_event" do
      check all data <- CommonDataEventGenerator.common_data_event() do
        assert %{
                 interface: _interface,
                 mapping: _mapping,
                 value: _value,
                 path: _path,
                 endpoint: _endpoint,
                 type: _type
               } = data
      end
    end
  end
end
