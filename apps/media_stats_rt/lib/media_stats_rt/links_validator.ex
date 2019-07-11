defmodule MediaStatsRT.LinksValidator do
  @moduledoc """
  Module to check if a link is valid

  # Examples
  {:ok, url} = MediaStatsRT.LinkValidator.validate("https://foo.com")
  {:error, reason} = MediaStatsRT.LinkValidator.validate("foo.com")
  """

  @spec validate(String.t) :: {Atom.t, String.t}
  @spec validate_with_inet(String.t) :: {Atom.t, String.t}

  @doc """
  Check if is a valid link
  """
  def validate(url) do
    case URI.parse(url) do
      %URI{authority: nil} -> {:error, "Authority must be provided"}
      %URI{host: nil}      -> {:error, "Host must be provided"}
      %URI{port: nil}      -> {:error, "Port must be provided"}
      %URI{scheme: nil}    -> {:error, "Scheme must be provided"}
      _ -> {:ok, url}
    end
  end

  @doc """
  Check if is a valid link checking inet
  """
  def validate_with_inet(url) do
    case URI.parse(url) do
      %URI{authority: nil} -> {:error, "Authority must be provided"}
      %URI{host: nil}      -> {:error, "Host must be provided"}
      %URI{port: nil}      -> {:error, "Port must be provided"}
      %URI{scheme: nil}    -> {:error, "Scheme must be provided"}
      %URI{host: host}     ->
        case :inet.gethostbyname(Kernel.to_charlist host) do
          {:ok, _}    -> {:ok}
          {:error, _} -> {:error, "Invalid host"}
        end
    end
    |> case do
         {:error, error} when is_binary(error) -> {:error, error}
         _ -> {:ok, url}
       end
  end

  def ping, do: :pong
end