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

defmodule Astarte.Core.Generators.Mapping.ValueType do
  @moduledoc """
  This module provides generators for any ValueType.
  """
  use ExUnitProperties

  alias Astarte.Core.Mapping.ValueType

  @valid_atoms [
    :double,
    :integer,
    :boolean,
    :longinteger,
    :string,
    :binaryblob,
    :datetime,
    :doublearray,
    :integerarray,
    :booleanarray,
    :longintegerarray,
    :stringarray,
    :binaryblobarray,
    :datetimearray
  ]

  @doc """
  List of all astarte's ValueType atoms
  """
  @spec valid_atoms() :: list(atom())
  def valid_atoms, do: @valid_atoms

  @doc """
  Generates a valid ValueType
  """
  @spec value_type() :: StreamData.t(ValueType.t())
  def value_type, do: member_of(valid_atoms())
end
