defmodule Argon2.Base do
  @moduledoc """
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  def hash_nif(t_cost, m_cost, parallelism, password, salt, raw, hashlen, encodedlen, argon2_type)
  def hash_nif(_, _, _, _, _, _, _, _, _), do: exit(:nif_library_not_loaded)

  def verify_nif(stored_hash, password, argon2_type)
  def verify_nif(_, _, _), do: exit(:nif_library_not_loaded)

  def error_nif(error_code)
  def error_nif(_), do: exit(:nif_library_not_loaded)

  def encodedlen_nif(t_cost, m_cost, parallelism, saltlen, hashlen, argon2_type)
  def encodedlen_nif(_, _, _, _, _, _), do: exit(:nif_library_not_loaded)

end
