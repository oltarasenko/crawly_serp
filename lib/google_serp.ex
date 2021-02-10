defmodule GoogleSerp do
  @moduledoc """
  Documentation for `GoogleSerp`.
  """

  @doc """
  Start a crawler with a given keyword as a starting point

  ## Examples

      iex> GoogleSerp.crawl("scraping elixir")
      :ok

  """
  def crawl(query) do
    Crawly.Engine.start_spider(Spider, query: query)
  end
end
