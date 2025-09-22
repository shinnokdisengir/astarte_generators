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

defmodule Astarte.Core.Generators.Triggers.SimpleEvents.ValueChangeAppliedEvent do
  @moduledoc """
  This module provides generators for Astarte Trigger Simple Event ValueChangeAppliedEvent struct.
  """
  use ExUnitProperties

  import Astarte.Generators.Utilities.ParamsGen

  alias Astarte.Core.Triggers.SimpleEvents.ValueChangeAppliedEvent

  alias Astarte.Core.Generators.Mapping.ValueType, as: ValueTypeGenerator

  alias Astarte.Core.Generators.Triggers.SimpleEvents.CommonDataEvent,
    as: CommonDataEventGenerator

  @spec value_change_applied_event() :: StreamData.t(ValueChangeAppliedEvent.t())
  @spec value_change_applied_event(keyword :: keyword()) ::
          StreamData.t(ValueChangeAppliedEvent.t())
  def value_change_applied_event(params \\ []) do
    gen_fields =
      params gen all %{
                       interface: interface_name,
                       path: path,
                       endpoint: endpoint,
                       type: type
                     } <- CommonDataEventGenerator.common_data_event(params),
                     old_bson_value <- ValueTypeGenerator.value_from_type(type),
                     new_bson_value <- ValueTypeGenerator.value_from_type(type),
                     params: params do
        %{
          interface: interface_name,
          path: path,
          endpoint: endpoint,
          type: type,
          old_bson_value: old_bson_value,
          new_bson_value: new_bson_value
        }
      end

    gen_fields
    |> bind(fn fields ->
      fields
      |> Map.new(fn {k, v} -> {k, constant(v)} end)
      |> optional_map()
    end)
    |> map(&struct(ValueChangeAppliedEvent, &1))
  end
end
