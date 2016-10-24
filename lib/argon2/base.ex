defmodule Argon2.Base do
  @moduledoc """
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  def argon2_hash_nif(t_cost, m_cost, parallelism, password, salt, hashlen, encoded, argon2_type)
  def argon2_hash_nif(_, _, _, _, _, _, _, _), do: exit(:nif_library_not_loaded)

  def argon2_verify_nif(stored_hash, password, argon2_type)
  def argon2_verify_nif(_, _, _), do: exit(:nif_library_not_loaded)

  def argon2_error_nif(error_code)
  def argon2_error_nif(_), do: exit(:nif_library_not_loaded)

end
