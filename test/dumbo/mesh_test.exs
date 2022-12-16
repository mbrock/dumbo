defmodule Dumbo.MeshTest do
  use Dumbo.DataCase

  alias Dumbo.Mesh

  describe "nodes" do
    alias Dumbo.Mesh.Node

    import Dumbo.MeshFixtures

    @invalid_attrs %{definition: nil, friendly_name: nil, ieee_address: nil}

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Mesh.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Mesh.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      valid_attrs = %{definition: %{}, friendly_name: "some friendly_name", ieee_address: "some ieee_address"}

      assert {:ok, %Node{} = node} = Mesh.create_node(valid_attrs)
      assert node.definition == %{}
      assert node.friendly_name == "some friendly_name"
      assert node.ieee_address == "some ieee_address"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mesh.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      update_attrs = %{definition: %{}, friendly_name: "some updated friendly_name", ieee_address: "some updated ieee_address"}

      assert {:ok, %Node{} = node} = Mesh.update_node(node, update_attrs)
      assert node.definition == %{}
      assert node.friendly_name == "some updated friendly_name"
      assert node.ieee_address == "some updated ieee_address"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Mesh.update_node(node, @invalid_attrs)
      assert node == Mesh.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Mesh.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Mesh.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Mesh.change_node(node)
    end
  end

  describe "messages" do
    alias Dumbo.Mesh.Message

    import Dumbo.MeshFixtures

    @invalid_attrs %{payload: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Mesh.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Mesh.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{payload: %{}}

      assert {:ok, %Message{} = message} = Mesh.create_message(valid_attrs)
      assert message.payload == %{}
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mesh.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{payload: %{}}

      assert {:ok, %Message{} = message} = Mesh.update_message(message, update_attrs)
      assert message.payload == %{}
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Mesh.update_message(message, @invalid_attrs)
      assert message == Mesh.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Mesh.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Mesh.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Mesh.change_message(message)
    end
  end
end
