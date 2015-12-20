defmodule Multihash do
  @moduledoc """
  A [multihash](https://github.com/jbenet/multihash) implementation.
  """

  defstruct algorithm: :sha512, size: 0, digest: <<>>

  @type algorithm :: :sha1 | :sha256 | :sha512 | :sha3 | :blake2b | :blake2s
  @type t :: %Multihash{algorithm: algorithm,
                        size: non_neg_integer,
                        digest: binary}

  defp codes do
    %{sha1: 0x11,
      sha256: 0x12,
      sha512: 0x13,
      sha3: 0x14,
      blake2b: 0x40,
      blake2s: 0x41}
  end

  @doc ~S"""
  Calculate a multihash given an algorithm, digest size and binary.

  ## Examples

      iex> Multihash.hash(:sha1, "Hello")
      {:ok, %Multihash{algorithm: :sha1,
                       size: 20,
                       digest: <<247, 255, 158, 139, 123, 178, 224,
                                 155, 112, 147, 90, 93, 120, 94, 12,
                                 197, 217, 208, 171, 240>>}}
  """
  @spec hash(algorithm, iodata) :: {:ok, t} | {:error, any}
  def hash(algoritm, data)
  def hash(:sha1, data), do: hash(:sha1, 20, data)
  def hash(:sha256, data), do: hash(:sha256, 32, data)
  def hash(:sha512, data), do: hash(:sha512, 64, data)
  def hash(_, _), do: {:error, "Invalid hash algorithm"}

  @spec hash(algorithm, non_neg_integer, iodata) :: {:ok, t} | {:error, any}
  defp hash(:sha1, 20, data) do
    {:ok, %Multihash{algorithm: :sha1,
                     size: 20,
                     digest: :crypto.hash(:sha, data)}}
  end
  defp hash(:sha1, _, _), do: {:error, "Invalid digest length"}

  defp hash(:sha256, 32, data) do
    {:ok, %Multihash{algorithm: :sha256,
                     size: 32,
                     digest: :crypto.hash(:sha256, data)}}
  end
  defp hash(:sha256, _, _), do: {:error, "Invalid digest length"}

  defp hash(:sha512, 64, data) do
    {:ok, %Multihash{algorithm: :sha512,
                     size: 64,
                     digest: :crypto.hash(:sha512, data)}}
  end
  defp hash(:sha512, _, _), do: {:error, "Invalid digest length"}

  @type mh_binary :: <<_ :: 16>>

  @doc ~S"""
  Encodes a Multihash as a binary.

  ## Examples

      iex> Multihash.encode(%Multihash{algorithm: :sha1, size: 20, digest: <<247, 255, 158, 139, 123, 178, 224, 155, 112, 147, 90, 93, 120, 94, 12, 197, 217, 208, 171, 240>>})
      {:ok, <<17, 20, 247, 255, 158, 139, 123, 178, 224, 155, 112, 147,
              90, 93, 120, 94, 12, 197, 217, 208, 171, 240>>}
  """
  @spec encode(t) :: {:ok, mh_binary} | {:error, any}
  def encode(%Multihash{algorithm: algorithm, size: size, digest: digest}) do
    code = Map.get(codes, algorithm)
    cond do
      code == nil -> {:error, "Invalid algorithm"}
      size != byte_size(digest) -> {:error, "Invalid digest length"}
      true -> {:ok, <<code, size>> <> digest}
    end
  end

  @doc ~S"""
  Tries to decode a multihash binary.

  ## Examples

      iex> Multihash.decode(<<17, 20, 247, 255, 158, 139, 123, 178, 224, 155, 112, 147, 90, 93, 120, 94, 12, 197, 217, 208, 171, 240>>)
      {:ok, %Multihash{algorithm: :sha1,
                       size: 20,
                       digest: <<247, 255, 158, 139, 123, 178, 224,
                                 155, 112, 147, 90, 93, 120, 94, 12,
                                 197, 217, 208, 171, 240>>}}
  """
  @spec decode(binary) :: {:ok, t} | {:error, any}
  def decode(<<code, size, digest :: binary>> = binary) do
    algorithm = from_code(code)
    cond do
      algorithm == nil -> {:error, "Invalid algorithm code"}
      size != byte_size(digest) -> {:error, "Invalid digest length"}
      true-> {:ok, %Multihash{algorithm: algorithm,
                              size: size,
                              digest: digest}}
    end
  end
  def decode(_), do: {:error, "Invalid multihash length (too short)"}

  @spec from_code(integer) :: algorithm | nil
  defp from_code(code) do
    case Enum.find(codes, fn {_, v} -> v == code end) do
      nil -> nil
      {algorithm, ^code} -> algorithm
    end
  end
end
