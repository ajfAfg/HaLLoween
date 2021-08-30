defmodule Halloween.CLI do
  @version Mix.Project.config()[:version]
  @stdin "-"

  @moduledoc false

  def main(argv) do
    argv
    |> parse_argv()
    |> process()
    |> IO.write()
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

  defp to_intermediate_representation({parsed, args, _errors}) do
    case {to_ir_for_args(args), to_ir_for_options(parsed)} do
      {_, :error} -> :error
      {_, :help} -> :help
      {_, :version} -> :version
      rep -> rep
    end
  end

  defp to_ir_for_options(%{help: true}), do: :help
  defp to_ir_for_options(%{version: true}), do: :version
  defp to_ir_for_options(%{halloween: halloween}), do: halloween
  defp to_ir_for_options(%{}), do: rand()
  defp to_ir_for_options(_), do: :error

  defp to_ir_for_args([]), do: @stdin
  defp to_ir_for_args(filenames), do: filenames

  defp rand(), do: Enum.random(1..100)

  def process(:help) do
    """
    Usage: halloween [options] [file ...]

    ## Options
      -H              Same as `--halloween`
      -h              Same as `--help`
      -v              Same as `--version`

      --halloween     HaLLoween! (Probability of rewriting to HALLOWEEN [%])
      --help          Display available options
      --version       Display the version of this software
    """
  end

  def process(:version) do
    @version
  end

  def process({"-", halloween}) do
    IO.read(:all)
    |> Halloween.to_halloween(halloween)
  end

  def process({filenames, halloween}) do
    results =
      filenames
      |> Enum.map(&File.read/1)

    if Enum.any?(results, fn {type, _} -> type == :error end) do
      Enum.zip(filenames, results)
      |> Enum.filter(fn {_, {type, _}} -> type == :error end)
      |> Enum.map(fn {filename, {_, reason}} -> generate_error_message(filename, reason) end)
      |> Enum.join("\n")
    else
      results
      |> Enum.map(fn {:ok, text} -> text end)
      |> Enum.join()
      |> Halloween.to_halloween(halloween)
    end
  end

  defp generate_error_message(filename, reason) do
    reason = reason |> :file.format_error() |> List.to_string()
    filename <> ": " <> reason
  end
end
