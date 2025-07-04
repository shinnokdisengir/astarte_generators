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

defmodule Astarte.Common.Generators.Timestamp do
  @moduledoc """
  Unix timestamp generator
  """
  use ExUnitProperties

  import Astarte.Generators.Utilities.ParamsGen

  @min_default 0
  @max_default 2_556_143_999_999_999

  @doc false
  @spec min_default() :: integer()
  def min_default, do: @min_default

  @doc false
  @spec max_default() :: integer()
  def max_default, do: @max_default

  @doc """
  Generates a random timestamp between min and max, defaulting to 0 and 2_556_143_999_999_999 (µs).
  """
  @spec timestamp() :: StreamData.t(integer())
  @spec timestamp(params :: keyword()) :: StreamData.t(integer())
  def timestamp(params \\ []) do
    config =
      params gen all min <- constant(min_default()),
                     max <- constant(max_default()),
                     params: params do
        {min, max}
      end

    gen all {min, max} <- config,
            timestamp <- timestamp(min, max) do
      timestamp
    end
  end

  defp timestamp(min, max) when min < @max_default and max > @min_default and min < max,
    do: integer(min..max)
end
