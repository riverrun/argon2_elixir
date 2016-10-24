defmodule Argon2.Errors do
  @moduledoc """
  Error handling for Argon2.
  """

  error_messages = [{-1, "Output pointer is NULL"},
                    {-2, "Output is too short"},
                    {-3, "Output is too long"},
                    {-4, "Password is too short"},
                    {-5, "Password is too long"},
                    {-6, "Salt is too short"},
                    {-7, "Salt is too long"},
                    {-8, "Associated data is too short"},
                    {-9, "Associated data is too long"},
                    {-10, "Secret is too short"},
                    {-11, "Secret is too long"},
                    {-12, "Time cost is too small"},
                    {-13, "Time cost is too large"},
                    {-14, "Memory cost is too small"},
                    {-15, "Memory cost is too large"},
                    {-16, "Too few lanes"},
                    {-17, "Too many lanes"},
                    {-18, "Password pointer is NULL, but password length is not 0"},
                    {-19, "Salt pointer is NULL, but salt length is not 0"},
                    {-20, "Secret pointer is NULL, but secret length is not 0"},
                    {-21, "Associated data pointer is NULL, but ad length is not 0"},
                    {-22, "Memory allocation error"},
                    {-23, "The free memory callback is NULL"},
                    {-24, "The allocate memory callback is NULL"},
                    {-25, "Argon2_Context context is NULL"},
                    {-26, "There is no such version of Argon2"},
                    {-27, "Output pointer mismatch"},
                    {-28, "Not enough threads"},
                    {-29, "Too many threads"},
                    {-30, "Missing arguments"},
                    {-31, "Encoding failed"},
                    {-32, "Decoding failed"},
                    {-33, "Threading failure"},
                    {-34, "Some of encoded parameters are too long or too short"}]

  for {error_code, message} <- error_messages do
    def handle_error(unquote(error_code)) do
      raise ArgumentError, unquote(message)
    end
  end
  def handle_error(_) do
    raise ArgumentError, "Unknown error code"
  end

end
