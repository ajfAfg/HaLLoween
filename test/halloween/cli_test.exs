defmodule CliTest do
  use ExUnit.Case, async: true
  doctest Halloween.CLI

  import ExUnit.CaptureIO
  import Halloween.CLI, only: [parse_argv: 1, process: 1]

  setup_all do
    [
      text: """
      On the surface, Cosmo doesn't exhibit many emotions aside from her usual smiling , seemingly happy-go-lucky attitude. She doesn't speak except for repeating the word "Halloween" and, like the rest of Quanxi's fiends, follows Quanxi around and seems to be in love with her and under her command.
      (Quote from https://chainsaw-man.fandom.com/wiki/Cosmo)
      """
    ]
  end

  describe "Parse command line arguments." do
    test "Return :help with -h and --help options." do
      assert parse_argv(["-h", "foo"]) == :help
      assert parse_argv(["--help", "foo"]) == :help
    end

    test "Return :version with -v and --version options." do
      assert parse_argv(["-v", "foo"]) == :version
      assert parse_argv(["--version", "foo"]) == :version
    end

    test "Return a tuple containing the file name and the halloween with -H and --halloween options." do
      assert parse_argv(["-H", "20", "foo.txt"]) == {["foo.txt"], 20}
      assert parse_argv(["--halloween", "20", "foo.txt"]) == {["foo.txt"], 20}
    end

    test "Multi files can be specified." do
      assert parse_argv(["-H", "20", "foo.txt", "bar.txt"]) == {["foo.txt", "bar.txt"], 20}
    end

    test "-h and --help options take precedence over other options." do
      assert parse_argv(["-h", "-v", "-H", "20", "foo.txt"]) == :help
      assert parse_argv(["--help", "-v", "-H", "20", "foo.txt"]) == :help
    end

    test "-v and --version options take precedence over other options except -h and --help options." do
      assert parse_argv(["-v", "-H", "20", "foo.txt"]) == :version
      assert parse_argv(["--version", "-H", "20", "foo.txt"]) == :version
    end

    test "When the halloween is not specified, a random number is specified for the halloween." do
      {["foo.txt"], halloween} = parse_argv(["foo.txt"])
      assert is_integer(halloween)
    end

    test "When the file name is not specified, standard input is specified for the file name." do
      assert parse_argv(["-H", "20"]) == {"-", 20}
    end
  end

  describe "Return texts according to the options." do
    test "Return heplful informations." do
      process(:help)
      |> IO.puts()
    end

    test "Return the version of this software." do
      process(:version)
      |> IO.puts()
    end

    test "Read text from standard input and return the replaced text.", fixture do
      fun = fn -> process({"-", 0}) |> IO.puts() end
      assert capture_io(fixture.text, fun) == fixture.text <> "\n"
    end

    setup do
      filenames = ["test/test1.txt", "test/test2.txt"]

      [
        filenames: filenames,
        concat_files: filenames |> Enum.map(&File.read!/1) |> Enum.join()
      ]
    end

    test "Read text from the files and return the replaced text.", fixture do
      assert process({fixture.filenames, 0}) == fixture.concat_files
    end

    test "Return error messages if some files cannot be read.", fixture do
      filenames = ["not_found.txt" | fixture.filenames]
      assert process({filenames, 0}) == "not_found.txt: no such file or directory"
    end
  end
end
