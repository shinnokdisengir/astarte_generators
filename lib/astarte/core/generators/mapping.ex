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

defmodule Astarte.Core.Generators.Mapping do
  @moduledoc """
  This module provides generators for Astarte Mapping structs.

  See https://docs.astarte-platform.org/astarte/latest/040-interface_schema.html#mapping
  """
  use Astarte.Generators.Utilities.ParamsGen

  alias Astarte.Core.Mapping
  alias Astarte.Core.Generators.Interface, as: InterfaceGenerator

  @doc """
  Generates a Mapping struct.
  See https://docs.astarte-platform.org/astarte/latest/040-interface_schema.html#mapping
  """

  # @spec mapping(
  #         :datastream | :properties,
  #         %{
  #           :aggregation => :individual | :object,
  #           :allow_unset => boolean(),
  #           :expiry => non_neg_integer(),
  #           :explicit_timestamp => boolean(),
  #           :prefix => String.t(),
  #           :reliability => :unreliable | :guaranteed | :unique,
  #           optional(:retention) => :discard | :volatile | :stored
  #         },
  #         Keyword.t()
  #       ) :: StreamData.t(Mapping.t())
  # def mapping(interface_type \\ :datastream, config, params \\ []) do
  #   gen all(
  #         required <- required_fields(config, params),
  #         database_retention <- database_retention_fields(interface_type, params),
  #         optional <- optional_fields(config, params)
  #       ) do
  #     fields = Enum.reduce([required, database_retention, optional], &Map.merge/2)
  #     struct(Mapping, fields)
  #   end
  # end

  def mapping(params \\ []) do
    config =
      params gen all interface_type <- InterfaceGenerator.type(),
                     params: params do
      end

    gen all a <- string(:ascii) do
      fields = %{a: a}

      struct(Mapping, fields)
    end
  end

  defp endpoint(aggregation, prefix) do
    generator =
      case aggregation do
        :individual -> repeatedly(fn -> "/individual_#{System.unique_integer([:positive])}" end)
        :object -> repeatedly(fn -> "/object_#{System.unique_integer([:positive])}" end)
      end

    gen all(postfix <- generator) do
      prefix <> postfix
    end
  end

  defp type do
    member_of([
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
    ])
  end

  @spec reliability() :: StreamData.t(:unreliable | :guaranteed | :unique)
  def reliability, do: member_of([:unreliable, :guaranteed, :unique])

  @spec explicit_timestamp() :: StreamData.t(boolean())
  def explicit_timestamp, do: boolean()

  @spec retention() :: StreamData.t(:discard | :volatile | :stored)
  def retention, do: member_of([:discard, :volatile, :stored])

  @spec expiry() :: StreamData.t(0 | pos_integer())
  def expiry, do: one_of([constant(0), integer(1..10_000)])

  @spec database_retention_policy() :: StreamData.t(:no_ttl | :use_ttl)
  def database_retention_policy, do: member_of([:no_ttl, :use_ttl])

  @spec database_retention_ttl() :: StreamData.t(non_neg_integer())
  def database_retention_ttl, do: integer(60..1_048_576)

  @spec allow_unset() :: StreamData.t(boolean())
  def allow_unset, do: boolean()

  defp description, do: string(:ascii, min_length: 1, max_length: 1000)

  defp doc, do: string(:ascii, min_length: 1, max_length: 100_000)

  defp required_fields(
         %{
           aggregation: aggregation,
           prefix: prefix,
           retention: retention,
           reliability: reliability,
           explicit_timestamp: explicit_timestamp,
           allow_unset: allow_unset,
           expiry: expiry
         },
         params
       ) do
    params gen all endpoint <- endpoint(aggregation, prefix),
                   value_type <- type(),
                   retention <- constant(retention),
                   reliability <- constant(reliability),
                   explicit_timestamp <- constant(explicit_timestamp),
                   allow_unset <- constant(allow_unset),
                   expiry <- constant(expiry),
                   params: params do
      %{
        endpoint: endpoint,
        value_type: value_type,
        retention: retention,
        reliability: reliability,
        explicit_timestamp: explicit_timestamp,
        allow_unset: allow_unset,
        expiry: expiry
      }
    end
  end

  defp optional_fields(_config, params) do
    params gen all description <- optional(description()),
                   doc <- optional(doc()),
                   params: params do
      %{description: description, doc: doc}
    end
  end

  defp optional(generator), do: one_of([generator, nil])

  defp database_retention_fields(:properties, _params), do: constant(%{})

  defp database_retention_fields(:datastream, params) do
    params gen all database_retention_policy <- database_retention_policy(),
                   database_retention_ttl <-
                     if(database_retention_policy == :use_ttl, do: database_retention_ttl()),
                   params: params do
      %{
        database_retention_policy: database_retention_policy,
        database_retention_ttl: database_retention_ttl
      }
    end
  end
end
