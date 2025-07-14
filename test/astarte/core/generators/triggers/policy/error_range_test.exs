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

defmodule Astarte.Core.Generators.Triggers.Policy.ErrorRangeTest do
  @moduledoc """
  Tests for Astarte Triggers Policy ErrorRange generator.
  """
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Astarte.Support.Cases.Validator

  alias Astarte.Core.Generators.Triggers.Policy.ErrorRange, as: ErrorRangeGenerator
  alias Astarte.Core.Triggers.Policy.ErrorRange

  @moduletag :trigger
  @moduletag :policy
  @moduletag :error_range
  # Fixtures params
  @moduletag validation_module: ErrorRange

  @doc false
  describe "triggers policy error_range generator" do
    @describetag :success
    @describetag :ut

    property "validate triggers policy error_range using Changeset", %{
      changeset_validate: changeset_validate
    } do
      check all(
              error_range <- ErrorRangeGenerator.error_range(),
              changeset = changeset_validate.(error_range)
            ) do
        assert changeset.valid?, "Invalid error_range: #{inspect(changeset.errors)}"
      end
    end

    property "valid use of to_change" do
      gen_change = ErrorRangeGenerator.error_range() |> ErrorRangeGenerator.to_changes()

      check all %{"error_codes" => error_codes} <- gen_change do
        assert Enum.all?(error_codes, &is_integer/1)
      end
    end
  end
end
