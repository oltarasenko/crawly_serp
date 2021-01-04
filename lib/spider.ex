defmodule Spider do
  use Crawly.Spider

  # This is not going to be used, so we're ignoring it.
  @impl Crawly.Spider
  def base_url() do
    :ok
  end

  @impl Crawly.Spider
  def init(options) do
    # Reading start urls from options passed from the main module
    query =
      options
      |> Keyword.get(:query, "scraping elixir")
      |> URI.encode() 

    [start_urls: ["https://www.google.com/search?q=#{query}"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    page = Codepagex.from_string!(response.body, :iso_8859_1, Codepagex.use_utf_replacement())
    document = Floki.parse_document!(page)

    search_results = Floki.find(document, ".ZINbbc.xpd.O9g5cc.uUPGi") |> Floki.filter_out("#st-card")
    items = Enum.map(search_results, fn block -> parse_search_result(block) end)

    %{
      :requests => [],
      :items => items
    }
  end

  defp parse_search_result(block) do
    %{title: Floki.find(block, "h3") |> Floki.text(),
      description: Floki.find(block, ".BNeawe") |> Floki.text(),
      link: Floki.find(block, ".kCrYT a") |> Floki.attribute("href")
    }
  end
end