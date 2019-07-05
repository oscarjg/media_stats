alias MediaStats.Accounts.{User, Application}
alias MediaStats.Repo

user_changeset = User.registration_changeset(
  %User{},
  %{
    name: "Josh",
    is_active: true,
    credential: %{
      email: "john@foo.com",
      password: "123456"
    }
  })

{:ok, user} = Repo.insert(user_changeset)

application_changeset = Application.registration_changeset(
  %Application{},
  %{
    name: "Foo Application",
    user_id: user.id,
    credential: %{
      app_key: "foo-api-key",
      allowed_hosts: "http://domain.es,127.0.0.1"
    }
  }
)

Repo.insert(application_changeset)