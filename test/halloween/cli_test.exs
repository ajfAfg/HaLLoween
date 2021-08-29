defmodule CliTest do
  use ExUnit.Case, async: true
  doctest Halloween.CLI

  import ExUnit.CaptureIO
  import Halloween.CLI, only: [parse_argv: 1, process: 1, read_file_or_stdin: 1]

  setup_all do
    [
      text: """
      On the surface, Cosmo doesn't exhibit many emotions aside from her usual smiling , seemingly happy-go-lucky attitude. She doesn't speak except for repeating the word "Halloween" and, like the rest of Quanxi's fiends, follows Quanxi around and seems to be in love with her and under her command.
      (Quote from https://chainsaw-man.fandom.com/wiki/Cosmo)
      """
    ]
  end

  describe "Parse command line arguments." do
    test ":Return :help with -h and --help options." do
      assert parse_argv(["-h", "foo"]) == :help
      assert parse_argv(["--help", "foo"]) == :help
    end

    test ":Return :version with -v and --version options." do
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

  describe "Run actions according to the options." do
    test "Display heplful informations." do
      process(:help)
      |> IO.puts()
    end

    test "Display the version of this software." do
      process(:version)
      |> IO.puts()
    end

    test "Read text from standard input and display the replaced text.", fixture do
      fun = fn -> process({"-", 0}) |> IO.puts() end
      assert capture_io(fixture.text, fun) == fixture.text <> "\n"
    end

    setup do
      filenames = ["test/test.txt", "test/test2.txt"]

      [
        filenames: filenames,
        concat_files: filenames |> Enum.map(&File.read!/1) |> Enum.join()
      ]
    end

    test "Read text from the files and display the replaced text.", fixture do
      assert process({fixture.filenames, 0}) == fixture.concat_files
    end

    test "Return error messages if some files cannot be read.", fixture do
      assert process({["not_found.txt" | fixture.filenames], 0}) == ["enoent"]
    end
  end

  describe "Read the file or standard input." do
    test "Read the file.", fixture do
      assert read_file_or_stdin("test/test.txt") == fixture.text
    end

    test "Read standard input.", fixture do
      fun = fn -> read_file_or_stdin("-") |> IO.write() end
      assert capture_io(fixture.text, fun) == fixture.text
    end
  end
end
