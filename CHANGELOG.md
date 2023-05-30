# Changelog

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
