# Elixir Multihash
[![Build Status](https://travis-ci.org/micxjo/elixir-multihash.svg)](https://travis-ci.org/micxjo/elixir-multihash)

A [multihash](https://github.com/jbenet/multihash) implementation in Elixir.

## Usage

```elixir
iex> {:ok, mh} = Multihash.hash(:sha1, "Hello")
{:ok, %Multihash{algorithm: :sha1,
                 size: 20,
                 digest: <<247, 255, 158, 139, 123, 178, 224,
                           155, 112, 147, 90, 93, 120, 94, 12,
                           197, 217, 208, 171, 240>>}}
iex> {:ok, enc} = Multihash.encode(mh)
{:ok, <<17, 20, 247, 255, 158, 139, 123, 178, 224, 155, 112, 147,
        90, 93, 120, 94, 12, 197, 217, 208, 171, 240>>}
iex> Multihash.decode(enc)
{:ok, %Multihash{algorithm: :sha1,
                 size: 20,
                 digest: <<247, 255, 158, 139, 123, 178, 224,
                           155, 112, 147, 90, 93, 120, 94, 12,
                           197, 217, 208, 171, 240>>}}
```