defmodule MediaStatsRT.LinksHelperTest do
  use ExUnit.Case, async: true

  test "validate unique links" do
    assert MediaStatsRT.LinksHelper.generate_unique("https://foo.com?p=1&p=2") == "https://foo.com"
    assert MediaStatsRT.LinksHelper.generate_unique("https://foo.com#bar") == "https://foo.com"
  end
end