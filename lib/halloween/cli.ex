defmodule Halloween.CLI do
  @version Mix.Project.config()[:version]
  @stdin "-"

  @moduledoc false

  def main(argv) do
    argv
    |> parse_argv()
    |> process()
    |> display()
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
      {_, err = {:error, _}} -> err
      {_, :help} -> :help
      {_, :version} -> :version
      rep -> rep
    end
  end

  defp to_ir_for_options(%{help: true}), do: :help
  defp to_ir_for_options(%{version: true}), do: :version
  defp to_ir_for_options(%{halloween: halloween}), do: halloween
  defp to_ir_for_options(%{}), do: rand()
  defp to_ir_for_options(illegal_options), do: {:error, illegal_options}

  defp to_ir_for_args([]), do: @stdin
  defp to_ir_for_args(filenames), do: filenames

  defp rand(), do: Enum.random(1..100)

  def process({:error, illegal_options}) do
    illegal_options
    |> Enum.each(&"halloween: illegal option '#{&1}'")
    |> Enum.join("\n")
    |> Kernel.<>(usage())
    |> with_exit_status(1)
  end

  def process(:help), do: usage() |> with_exit_status(0)

  def process(:version), do: @version |> with_exit_status(0)

  def process({"-", halloween}) do
    IO.read(:all)
    |> Halloween.to_halloween(halloween)
    |> with_exit_status(0)
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
      |> with_exit_status(1)
    else
      results
      |> Enum.map(fn {:ok, text} -> text end)
      |> Enum.join()
      |> Halloween.to_halloween(halloween)
      |> with_exit_status(0)
    end
  end

  defp generate_error_message(filename, reason) do
    reason = reason |> :file.format_error() |> List.to_string()
    filename <> ": " <> reason
  end

  defp with_exit_status(str, exit_status), do: {str, exit_status}

  defp usage() do
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

  def display({text, exit_status}) do
    IO.write(text)
    System.halt(exit_status)
  end
end
