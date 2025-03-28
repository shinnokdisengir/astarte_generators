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

defmodule Astarte.Core.Generators.InterfaceTest do
  @moduledoc """
  Tests for Astarte Interface generator.
  """
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Astarte.Cases.Changeset

  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator

  @moduletag :interface
  @moduletag schema_module: Astarte.Core.Interface

  @doc """
  Property test for Astarte Interface generator.
  """
  describe "interface generator" do
    property "validate interface", %{validate_entity: validate_entity} do
      check all(interface <- InterfaceGenerator.interface()) do
        assert match?({:ok, _}, validate_entity.(interface))
      end
    end
  end
end
