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

defmodule Astarte.Core.Generators.Mapping.ValueTypeTest do
  @moduledoc """
  Tests for Astarte Mapping ValueTypeTest
  """
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Core.Mapping.ValueType

  alias Astarte.Core.Generators.Mapping.ValueType, as: ValueTypeGenerator

  @moduletag :core
  @moduletag :mapping
  @moduletag :value_type

  defp valid_cast({:ok, _}), do: true
  defp valid_cast(:error), do: false
  defp valid_cast(type) when is_atom(type), do: ValueType.cast(type) |> valid_cast()

  @doc false
  describe "value_type generator" do
    @describetag :success
    @describetag :ut

    test "validate all valid_atoms in value_type generator" do
      assert ValueTypeGenerator.valid_atoms() |> Enum.all?(&valid_cast/1)
    end

    property "validate generated value_type using validate_value/2" do
      check all value_type <- ValueTypeGenerator.value_type() do
        assert valid_cast(value_type)
      end
    end
  end
end
