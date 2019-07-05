defmodule MediaStats.Accounts.ApplicationCredentialTest do
  use ExUnit.Case, async: true

  test "converts domain hosts to enum" do
    assert MediaStats.Accounts.ApplicationCredential.allowed_hosts_to_enum(%{
             allowed_hosts: "foo,bar"
           }) == ["foo", "bar"]

    assert MediaStats.Accounts.ApplicationCredential.allowed_hosts_to_enum(%{
             allowed_hosts: "foo, bar"
           }) == ["foo", "bar"]

    assert MediaStats.Accounts.ApplicationCredential.allowed_hosts_to_enum(%{allowed_hosts: ""}) ==
             []

    assert MediaStats.Accounts.ApplicationCredential.allowed_hosts_to_enum(%{allowed_hosts: nil}) ==
             []
  end
end
