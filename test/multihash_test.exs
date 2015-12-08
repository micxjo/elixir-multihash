defmodule MultihashTest do
  use ExUnit.Case, async: true
  doctest Multihash
  import Multihash

  test "Invalid decodes" do
    assert {:error, _} = decode(<<>>)
    assert {:error, _} = decode(<<0x11>>)
    assert {:error, _} = decode(<<0x11, 1>>)
    assert {:error, _} = decode(<<0x11, 2, 0>>)
    assert {:error, _} = decode(<<0>>)
  end

  test "Valid decode" do
    <<_, _, digest :: binary>> = encoded = Hexate.decode(
      "11140beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
    assert {:ok, %Multihash{algorithm: :sha1,
                            size: 20,
                            digest: digest} = multihash} = decode(encoded)
    assert {:ok, ^encoded} = encode(multihash)
  end
end
