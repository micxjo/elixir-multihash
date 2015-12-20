defmodule MultihashTest do
  use ExUnit.Case, async: true
  use ExCheck
  doctest Multihash
  import Multihash

  test "Invalid decodes" do
    assert {:error, _} = decode(<<>>)
    assert {:error, _} = decode(<<0x11>>)
    assert {:error, _} = decode(<<0x11, 1>>)
    assert {:error, _} = decode(<<0x11, 2, 0>>)
    assert {:error, _} = decode(<<0x11, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0>>)
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

  property :sha1 do
    for_all b in binary do
      {:ok, mh} = Multihash.hash(:sha1, b)
      {:ok, <<code, size, rest :: binary>>} = Multihash.encode(mh)
      (mh.algorithm == :sha1 and mh.size == 20 and code == 0x11
       and size == 20 and byte_size(rest) == 20)
    end
  end

  property :sha256 do
    for_all b in binary do
      {:ok, mh} = Multihash.hash(:sha256, b)
      {:ok, <<code, size, rest :: binary>>} = Multihash.encode(mh)
      (mh.algorithm == :sha256 and mh.size == 32 and code == 0x12
       and size == 32 and byte_size(rest) == 32)
    end
  end

  property :sha512 do
    for_all b in binary do
      {:ok, mh} = Multihash.hash(:sha512, b)
      {:ok, <<code, size, rest :: binary>>} = Multihash.encode(mh)
      (mh.algorithm == :sha512 and mh.size == 64 and code == 0x13
       and size == 64 and byte_size(rest) == 64)
    end
  end

  property :recode do
    for_all {b, alg} in {binary, oneof([:sha1, :sha256, :sha512])} do
      {:ok, mh} = Multihash.hash(alg, b)
      {:ok, enc} = Multihash.encode(mh)
      {:ok, mh2} = Multihash.decode(enc)
      mh == mh2
    end
  end
end
