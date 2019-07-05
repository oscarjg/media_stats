defmodule MediaStats.Accounts.ApplicationCredential do
  use Ecto.Schema
  import Ecto.Changeset

  @spec allowed_hosts_to_enum(MediaStats.Accounts.ApplicationCredential.t()) :: Enum.t()
  @spec is_allowed_host?(Enum.t(), String.t()) :: Boolean.t()

  schema "application_credentials" do
    field(:app_key, :string)
    field(:allowed_hosts, :string)

    belongs_to(:application, MediaStats.Accounts.Application)

    timestamps()
  end

  def changeset(application_credentials, attrs \\ %{}) do
    application_credentials
    |> cast(attrs, [:app_key, :allowed_hosts])
    |> validate_required(:app_key)
    |> assoc_constraint(:application)
    |> unique_constraint(:app_key)
  end

  def registration_changeset(application_credentials, attrs \\ %{}) do
    changeset(application_credentials, attrs)
  end

  @doc """
  Converts the allowed hosts string to list
  """
  def allowed_hosts_to_enum(credential) do
    to_enum(credential.allowed_hosts)
  end

  @doc """
  Check if a host is in allowed hosts
  """
  def is_allowed_host?(allowed_hosts, host_to_find)
      when is_list(allowed_hosts) and is_binary(host_to_find) do
    cond do
      Enum.find(allowed_hosts, false, fn host -> host == host_to_find end) ->
        true

      true ->
        false
    end
  end

  defp to_enum(_data = nil), do: []
  defp to_enum(data) when byte_size(data) == 0, do: []

  defp to_enum(data) when is_binary(data) do
    data
    |> String.split(",")
    |> Enum.map(&String.trim(&1))
  end
end
