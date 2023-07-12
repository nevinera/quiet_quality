# Changelog

## Release 1.4.0

* Support specifying `excludes` per-tool, so that certain files won't be passed
  to those tools on the command-line (#107 resolves #106)

## Release 1.3.1

* Fix a bug around the logging of nil commands when runners are skipped (#104
  resolves #103)

## Release 1.3.0

* Support (and enable by default) colorizing the console stderr output from
  `bin/qq` - disable with the `--no-colorize` flag or the `colorize: false`
  configuration entry. (#94, resolved #36)
* Introduce a Logging facility, and add the `--verbose/-v` flag - supply it
  either once or twice to enable (colorized) logging in either `info` or `debug`
  level, providing much more detail about what's going on during execution.

## Release 1.2.2

* Add some code to the Rspec::Parser that _cleans_ the json of certain text that
  simplecov may write into the rspec json output. (#91, resolves #86)
* Include the name of the originating tool in the printed message, and the
  annotation, when a warning is presented. (#90 resolves #72)
* Support `normal` as a logging level, and the `--normal` and `-n` cli
  arguments. This is the default value, so this really only matters if your
  config file sets another value and you want to override it from the cli.
  (#91, resolves #86)

## Release 1.2.1

* Fix the handling of the various ways to specify whether tools should limit
  their targets to changed files or run against the entire repository. The
  configuration systems had disagreements on what to call the options in
  question, which resulted in some configuration entries being ignored. We
  enforce a set of validations on reads and writes now to avoid such a problem
  in the future (#89, resolves #88)
* Add coverage-checking, and then improve test coverage and remove unreferenced
  code as a result. (#87)

## Release 1.2.0

* Support `--light`, `--quiet`, and `--logging LEVEL` arguments for less output
  (#78, resolves #37)
* Support the [markdownlint](https://github.com/markdownlint/markdownlint) tool
  (#79, resolves #58)
* Extract BaseRunner (#82) and RelevantRunner (#83) parent classes from the tool
  runners, to allow new tools to be more easily implemented. (Resolves #81)
* Extract a Cli::Presenter from the Entrypoint, to simplify pending work on cli
  presentation (#84, resolves #42)
* Update the docs a bit, and add a changelog (hi!)

## Release 1.1.0

* Support a `file_filter` config entry per-tool (without a cli option), to limit
  what file paths a runner might supply to its tool based on a regex
  (#74, resolves #68)
* When what tools to execute is not specified (by cli or by config file), abort
  `bin/qq` and explain, rather than assuming "all of them" (#79, resolves #58)
* Update the config parser to handle keys named to match the cli options
  alongside the ones that were (mistakenly) named differently. This is a
  backwards-compatible change; if we eventually deprecate and simplify some of
  these option names, you'll have plenty of warning (#77, resolves #75)
* Support `--version/-V` flag (#73, resolves #69)

## Release 1.0.3

* Fix the printed _output_ for the case where there were some warnings from a
  tool, but all of them were filtered out (because they targetted lines that
  were not changed, for example). This situation should tell you that nothing
  is wrong with your PR, not that there is a problem (#71)

## Release 1.0.2

* Fix the _exit status_ for the case where there were some warnings from a
  tool, but all of them were filtered out (because they targetted lines that
  were not changed, for example). This situation should produce a successful
  result, and not fail a CI pipeline (#67)

## Release 1.0.1

* Fix the calculation of `changed_files` for the executor - in the migration
  to Entrypoint, the actual git call to get a ChangedFiles object to pass into
  other service classes was lost, which had the result that the entire system
  behaved (outside of tests) as if you were always running with `--all-files`
  (#65).

## Release 1.0.0

Initial functional public release.
