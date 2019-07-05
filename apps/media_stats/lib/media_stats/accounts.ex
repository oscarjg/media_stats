defmodule MediaStats.Accounts do
  @moduledoc """
  Accounts context to handle accounts actions as abstraction
  """
  import Ecto.Query

  alias MediaStats.Accounts.{User, Application, ApplicationCredential}
  alias MediaStats.Repo

  @spec create_registered_user(Map.t()) ::
          {:ok, MediaStats.Accounts.User.t()} | {:error, Ecto.Changeset.t()}
  @spec get_user(Integer.t()) :: MediaStats.Accounts.User.t() | nil
  @spec get_user_by_email_credential(String.t()) :: MediaStats.Accounts.User.t() | nil
  @spec authenticate_user_by_email_and_password(String.t(), String.t()) ::
          {:ok, MediaStats.Accounts.User.t()} | {:error, Atom.t()}
  @spec get_user_application!(MediaStats.Accounts.User.t(), Integer.t()) ::
          {:ok, MediaStats.Accounts.Application.t()} | Ecto.NoResultsError.t()
  @spec create_application(MediaStats.Accounts.User.t(), Map.t()) ::
          {:ok, MediaStats.Accounts.Application.t()} | {:error, Ecto.Changeset.t()}
  @spec list_user_applications(MediaStats.Accounts.User.t()) :: Enum.t()
  @spec authenticate_application(String.t()) ::
          {:ok, MediaStats.Accounts.Application.t()} | {:error, Atom.t()}
  @spec authenticate_application(String.t(), String.t()) ::
          {:ok, MediaStats.Accounts.Application.t()} | {:error, Atom.t()}
  @spec update_application(MediaStats.Accounts.Application.t(), Map.t()) :: {:ok, MediaStats.Accounts.Application.t()} | {:error, Ecto.Changeset.t()}
  ########### User #####################################################################################################

  @doc """
  Create a new user with credentials
  """
  def create_registered_user(attr \\ %{}) do
    %User{}
    |> User.registration_changeset(attr)
    |> Repo.insert()
  end

  @doc """
  Get a user by id
  """
  def get_user(id) when is_integer(id) do
    Repo.get(User, id)
  end

  @doc """
  Find a user by email
  """
  def get_user_by_email_credential(email) when is_binary(email) do
    from(u in User, join: uc in assoc(u, :credential), where: uc.email == ^email)
    |> Repo.one()
  end

  @doc """
  Find a user by email and password
  """
  def authenticate_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user =
      get_user_by_email_credential(email)
      |> preload_credential()

    cond do
      user && user.is_active && check_password(password, user.credential.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        {:error, :not_found}
    end
  end

  ########### Application ##############################################################################################

  @doc """
  Create a new application with credentials
  """
  def create_application(%User{} = user, attr \\ %{}) do
    %Application{}
    |> Application.registration_changeset(attr)
    |> put_user_assoc(user)
    |> Repo.insert()
  end

  @doc """
  List all user applications
  """
  def list_user_applications(%User{} = user) do
    Application
    |> user_application_query(user)
    |> Repo.all()
    |> preload_credential()
  end

  @doc """
  Get application by user
  """
  def get_user_application!(%User{} = user, app_id) do
    from(a in Application, where: a.id == ^app_id)
    |> user_application_query(user)
    |> Repo.one!()
    |> preload_credential()
  end

  defp user_application_query(query, %User{id: user_id}) do
    from(a in query, where: a.user_id == ^user_id)
  end

  @doc """
  Update application
  """
  def update_application(%Application{} = application, attrs) do
    application
    |> Application.updated_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Find an application with app_key and allowed hosts
  """
  def authenticate_application(app_key, allowed_hosts)
      when is_binary(app_key) and is_binary(allowed_hosts) do

    case authenticate_application(app_key) do
      {:ok, app} ->
        cond do
          app && check_application_hosts(app.credential, allowed_hosts) ->
            {:ok, app}

          app ->
            {:error, :unauthorized}

          true ->
            {:error, :not_found}
        end
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Find an application with app_key and allowed hosts
  """
  def authenticate_application(app_key) when is_binary(app_key) do
    app =
      from(u in Application,
        join: ac in assoc(u, :credential),
        where: ac.app_key == ^app_key
      )
      |> Repo.one()
      |> preload_credential()
      |> preload_user()

    cond do
      app ->
        {:ok, app}
      true ->
        {:error, :not_found}
    end
  end

  ######################################################################################################################

  defp check_application_hosts(%ApplicationCredential{} = credential, hosts_to_match) do
    hosts = ApplicationCredential.allowed_hosts_to_enum(credential)

    cond do
      Enum.empty?(hosts) ->
        true

      true ->
        ApplicationCredential.is_allowed_host?(hosts, hosts_to_match)
    end
  end

  defp check_password(pass, check_pass) do
    Comeonin.Pbkdf2.checkpw(pass, check_pass)
  end

  defp preload_credential(schema) do
    Repo.preload(schema, :credential)
  end

  defp preload_user(schema) do
    Repo.preload(schema, :user)
  end

  defp put_user_assoc(changeset, %User{} = user) do
    changeset
    |> Ecto.Changeset.put_assoc(:user, user)
  end
end
