defmodule MediaStatsRT.LinksValidatorTest do
  use ExUnit.Case, async: true

  doctest MediaStatsRT.LinksValidator

  alias MediaStatsRT.LinksValidator

  test "link validations" do
    assert {:ok, _url} = LinksValidator.validate("http://foo.com")
    assert {:ok, _url} = LinksValidator.validate("http://www.foo.com")
    assert {:ok, _url} = LinksValidator.validate("http://www.foo.com/")
    assert {:ok, _url} = LinksValidator.validate("http://www.foo.com/foo/bar")
    assert {:ok, _url} = LinksValidator.validate("http://www.foo.com/foo/bar/xxx.html")
    assert {:error, _reason} = LinksValidator.validate("www.foo.com")
    assert {:error, _reason} = LinksValidator.validate("www.foo")
    assert {:error, _reason} = LinksValidator.validate("foo")
  end
end