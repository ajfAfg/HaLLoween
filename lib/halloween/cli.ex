defmodule Halloween.CLI do
  @std_in "-"

  @moduledoc false

  def run(argv) do
    argv
    |> parse_argv()
    |> process()
    |> IO.puts()
  end

  def parse_argv(argv) do
    argv
    |> parse_option()
    |> to_intermediate_representation()
  end

  defp parse_option(argv) do
    opts =
      with aliases = [h: :help, v: :version, H: :halloween],
           strict = [help: :boolean, version: :boolean, halloween: :integer] do
        [aliases: aliases, strict: strict]
      end

    {parsed, args, errors} = OptionParser.parse(argv, opts)
    {Map.new(parsed), args, errors}
  end

  defp to_intermediate_representation({%{help: true}, _, _}), do: :help
  defp to_intermediate_representation({%{version: true}, _, _}), do: :version
  defp to_intermediate_representation({%{halloween: num}, [], _}), do: {@std_in, num}
  defp to_intermediate_representation({%{halloween: num}, filenames, _}), do: {filenames, num}
  defp to_intermediate_representation({_, filenames, _}), do: {filenames, Enum.random(1..100)}

  def process(:help) do
    """
    Usage: TODO [options] [file ...]

    ## Options
      -H              Same as `--halloween`
      -h              Same as `--help`
      -v              Same as `--version`

      --halloween     HaLLoween! (Probability of rewriting to HALLOWEEN [%])
      --help          Display available options
      --output-dir    Specify output directory
      --version       Display the version of this software
    """
  end

  def process(:version) do
    Mix.Project.config()[:version]
  end

  def process({"-", halloween}) do
    # read_file_or_stdin("-")
    IO.read(:all)
    |> Halloween.to_halloween(halloween)

    # |> IO.puts()
  end

  def process({filenames, halloween}) do
    results =
      filenames
      |> Enum.map(&File.read/1)

    # |> Enum.map(&read_file_or_stdin/1)

    if Enum.any?(results, fn {type, _} -> type == :error end) do
      results
      |> Enum.filter(fn {type, _} -> type == :error end)
      # |> Enum.each(fn {:error, info} -> IO.puts(info) end)
      |> Enum.map(fn {:error, reason} -> Atom.to_string(reason) end)
    else
      results
      |> Enum.map(fn {:ok, text} -> text end)
      |> Enum.join()
      |> Halloween.to_halloween(halloween)

      # |> IO.puts()
    end
  end

  def read_file_or_stdin("-"), do: IO.read(:all)

  def read_file_or_stdin(file) do
    case File.read(file) do
      {:ok, str} ->
        str

      err = {:error, _} ->
        err
    end
  end
end
