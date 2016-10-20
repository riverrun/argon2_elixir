defmodule Argon2 do
  @moduledoc """
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  def argon2_hash_nif(password, salt)
  def argon2_hash_nif(_, _), do: exit(:nif_library_not_loaded)

  def argon2_hash(password) do
    salt = :crypto.strong_rand_bytes(16)
    argon2_hash_nif(password, salt)
  end
end
