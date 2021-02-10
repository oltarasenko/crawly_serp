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
    template = fn(query, start) ->
      "https://www.google.com/search?q=#{query}&start=#{start}"
    end
    starts = for x <- 0..10, do: x * 10

    query =
      options
      |> Keyword.get(:query, "scraping elixir")
      |> URI.encode() 

    [start_urls: Enum.map(starts, fn x -> template.(query, x) end)]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    page_number =
      response.request_url
      |> URI.parse()
      |> Map.get(:query)
      |> URI.decode_query()
      |> Map.get("start", "0")
      |> String.to_integer()

    page = Codepagex.from_string!(response.body, :iso_8859_1, Codepagex.use_utf_replacement())
    document = Floki.parse_document!(page)

    search_results =
      Floki.find(document, ".ZINbbc.xpd.O9g5cc.uUPGi")
      |> Floki.filter_out("#st-card")

    items =
      search_results
      |> Enum.with_index()
      |> Enum.map(fn({block, i}) ->
        block
        |> parse_search_result()
        |> Map.put(:position, page_number + i)
      end)

    %{
      :requests => [],
      :items => items
    }
  end

  defp parse_search_result(block) do
    %{title: Floki.find(block, "h3") |> Floki.text(),
      description: Floki.find(block, ".BNeawe") |> Floki.text() |> String.slice(0, 30),
      link: Floki.find(block, ".kCrYT a") |> Floki.attribute("href")
    }
  end
end