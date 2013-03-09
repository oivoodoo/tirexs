defmodule Tirexs.Manage do
  import Tirexs.Helpers

  def count(options, settings) do
    body = JSON.encode(options[:filter] || options[:query] || [])
    Tirexs.ElasticSearch.post(make_url("_count", options), body, settings)
  end

  def delete_by_query(options, settings) do
    _body = JSON.encode(options[:filter] || options[:query] || [])
    #To do add DELETE with body
    Tirexs.ElasticSearch.delete(make_url("_query", options), settings)
  end

  defp make_url(method, options) do
    index = options[:index] <> "/"
    if options[:type] do
      index = index <> options[:type] <> "/"
    end
    options = delete_options([:filter, :query, :index, :type], options)
    index <> method <> to_param(options, "")
  end

  defp delete_options([], options) do
    options
  end

  defp delete_options([h|t], options) do
    options = Dict.delete(options, h)
    delete_options(t, options)
  end
end