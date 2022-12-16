defmodule Dumbo.MeshFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dumbo.Mesh` context.
  """

  @doc """
  Generate a unique node friendly_name.
  """
  def unique_node_friendly_name, do: "some friendly_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique node ieee_address.
  """
  def unique_node_ieee_address, do: "some ieee_address#{System.unique_integer([:positive])}"

  @doc """
  Generate a node.
  """
  def node_fixture(attrs \\ %{}) do
    {:ok, node} =
      attrs
      |> Enum.into(%{
        definition: %{},
        friendly_name: unique_node_friendly_name(),
        ieee_address: unique_node_ieee_address()
      })
      |> Dumbo.Mesh.create_node()

    node
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        payload: %{}
      })
      |> Dumbo.Mesh.create_message()

    message
  end
end
