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

defmodule Astarte.Core.Generators.Triggers.Policy.ErrorKeywordTest do
  @moduledoc """
  Tests for Astarte Triggers Policy ErrorKeyword generator.
  """
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Core.Generators.Triggers.Policy.ErrorKeyword, as: ErrorKeywordGenerator
  alias Astarte.Core.Triggers.Policy.ErrorKeyword
  alias Ecto.Changeset

  @moduletag :trigger
  @moduletag :policy
  @moduletag :error_keyword

  defp validation_helper(error_keyword) do
    changes = Map.from_struct(error_keyword)

    %ErrorKeyword{}
    |> Changeset.change(changes)
    |> ErrorKeyword.validate()
  end

  defp validation_fixture(_context), do: {:ok, validate: &validation_helper/1}

  @doc false
  describe "triggers policy error_keyword generator" do
    @describetag :success
    @describetag :ut

    setup :validation_fixture

    property "validate triggers policy error_keyword using Changeset", %{validate: validate} do
      check all error_keyword <- ErrorKeywordGenerator.error_keyword(),
                changeset = validate.(error_keyword) do
        assert changeset.valid?, "Invalid error_keyword: #{inspect(changeset.errors)}"
      end
    end
  end
end
