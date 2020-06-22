defmodule GhStats.CLI do
  def main(args) do
    parse_args(args)
  end

  defp parse_args(args) do
    {_, [owner_repo], _} = OptionParser.parse(args, strict: [])

    case String.split(owner_repo, "/") do
      [owner, repo] ->
        get_statistics(owner, repo)

      _ ->
        raise "Invalid parameter. Must be in 'owner/repo' format."
    end
  end

  def get_statistics(owner, repo) do
    url = "https://api.github.com/repos/#{owner}/#{repo}"

    case HTTPoison.get!(url) do
      %{status_code: 200, body: body} ->
        body
        |> Jason.decode!()
        |> print()

      %{status_code: 404} ->
        IO.puts(IO.ANSI.format([:red, "Owner or repository was not found"], true))
    end
  end

  defp print(repo) do
    %{
      "name" => name,
      "description" => description,
      "stargazers_count" => stargazers,
      "watchers_count" => watchers,
      "forks_count" => forks,
      "language" => language,
      "open_issues_count" => open_issues,
      "subscribers_count" => subscribers
    } = repo

    print("Name", name)
    print("Description", description)
    print("Language", language)
    print("Stargazers", stargazers)
    print("Watchers", watchers)
    print("Forks", forks)
    print("Subscribers", subscribers)
    print("Open issues", open_issues)
  end

  defp print(name, value) do
    IO.puts(IO.ANSI.format(["- #{name}: ", IO.ANSI.cyan(), "#{value}", IO.ANSI.default_color()]))
  end
end
