# QuietQuality

There are a lot of different tools that you need to run as you work - possibly
before you commit, or before you make a pull request, or after you make changes
to a class.. style checkers, tests, complexity metrics, static analyzers, etc.
QuietQuality can make that simpler and faster!

Or you may have a huge existing project, that's not _fully_ in compliance with
your style guides, but you want to avoid introducing _new_ issues, without
having to first resolve all of the existing ones. QuietQuality can help with
that too.

## Tool Support

So far, we have support for the following tools:

* [rubocop](https://github.com/rubocop/rubocop)
* [standardrb](https://github.com/standardrb/standard)
* [rspec](https://rspec.info/)
* [haml-lint](https://github.com/sds/haml-lint)
* [markdownlint](https://github.com/markdownlint/markdownlint)
* [brakeman](https://brakemanscanner.org/) (though there's no way to run this
  against only changed files)

Supporting more tools is relatively straightforward - they're implemented by
wrapping cli invocations and parsing output files (which overall seem to be much
more stable interfaces than the code interfaces to the various tools), and each
tool's support is built orthogonally to the others, in a
`QuietQuality::Tools::[Something]` namespace, with a `Runner` and a `Parser`.

## Local Usage Examples

Working locally, you'll generally want to commit a `.quiet_quality.yml`
configuration file into the root of your repository - it'll specify which tools
to run by default, and how to run them (whether you want to only run each tool
against the _changed files_, whether to _filter_ the resulting _messages_ down
to only those targeting lines that have been changed), and allows you to specify
the _comparison branch_, so you don't have to make a request to your origin
server every time you run the tool to see whether you're comparing against
`master` or `main` in this project.

If you have a configuration set up like that, you might have details specified
for `rubocop`, `rspec`, `standardrb`, and `brakeman`, but have only `rubocop`,
`standardrb`, and `rspec` set to run by default. That configuration file would
look like this (you can copy it from [here](docs/example-config.yml)):

```yaml
---
default_tools: ["standardrb", "rubocop", "rspec"]
executor: concurrent
comparison_branch: main
changed_files: true
filter_messages: true
brakeman:
  changed_files: false
  filter_messages: true
```

Then if you invoke `qq`, you'll see output like this:

```bash
❯ qq
--- Passed: standardrb
--- Passed: rubocop
--- Passed: rspec
```

But if you want to run brakeman, you could call `qq brakeman`:

```bash
❯ qq brakeman
--- Failed: brakeman


2 messages:
  app/controllers/articles_controller.rb:3  [SQL Injection]  Possible SQL injection
  app/controllers/articles_controller.rb:11  [Remote Code Execution]  `YAML.load` called with parameter value

```

## CI Usage Examples

Currently, QuietQuality is most useful from GitHub Actions - in that context, it's
possible to generate nice annotations for the analyzed commit (using Workflow
Actions). But it can be used from other CI systems as well, you just won't get
nice annotations out of it (yet).

For CI systems, you can either configure your execution entirely through
command-line arguments, or you can create additional configuration files and
specify them on the command-line.

Here is an invocation that executes rubocop and standardrb, expecting the full
repository to pass the latter, but not the former:

```bash
qq rubocop standardrb \
  --all-files --changed-files rubocop \
  --unfiltered --filter-messages rubocop \
  --comparison-branch main \
  --no-config \
  --executor serial \
  --annotate-github-stdout
```

Note the use of `--no-config`, to cause it to _not_ automatically load the
`.quiet_quality.yml` config included in the repository.

Alternatively, we could have put all of that configuration into a config file
like this:

```yaml
# config/quiet_quality/linters_workflow.yml
---
default_tools: ["standardrb", "rubocop"]
executor: serial
comparison_branch: main
changed_files: false
filter_messages: false

rubocop:
  changed_files: true
  filter_messages: true
```

And then run `qq -C config/quiet_quality/linters_workflow.yml`

## Available Options

The configuration file supports the following _global_ options (top-level keys):

* `executor`: 'serial' or 'concurrent' (the latter is the default)
* `annotator`: none set by default, and `github_stdout` is the only supported
  value so far.
* `comparison_branch`: by default, this will be _fetched_ from git, but that
  does require a remote request. You should set this, it saves about half a
  second. This is normally 'main' or 'master', but it could be 'trunk', or
  'develop' - it is the branch that PR diffs are _against_.
* `changed_files`: defaults to false - should tools be run against only the
  files that have changed, or against the entire repository? This is the global
  setting, but it is also settable per tool.
* `filter_messages`: defaults to false - should the resulting messages that do
  not refer to lines that were changed or added relative to the comparison
  branch be skipped? Also possible to set for each tool.
* `logging`: defaults to full messages printed. The `light` option
  prints a aggregated result (e.g. "3 tools executed: 1 passed, 2 failed
  (rubocop, standardrb)"). The `quiet` option will only return a status code,
  printing nothing.

And then each tool can have an entry, within which `changed_files` and
`filter_messages` can be specified - the tool-specific settings override the
global ones.

The tools have one additional setting that is not available at a global level:
`file_filter`. This is a string that will be turned into a _ruby regex_, and
used to limit what file paths are passed to the tool. For example, if you are
working in a rails engine `engines/foo/`, and you touch one of the rspec tests
there, you would not want `qq` in the root of the repository to run
`rspec engines/foo/spec/foo/thing_spec.rb` - that probably won't work, as your
engine will have its own test setup code and Gemfile. This setting is mostly
intended to be used like this:

```yaml
rspec:
  changed_files: true
  filter_messages: false
  file_filter: "^spec/"
```

### CLI Options

The same options are all available on the CLI, plus some additional ones - run
`qq --help` for a detailed list of the options, but the notable additions are:

* `--help/-H`: See a list of the options
* `--no-config/-N`: Do _not_ load a config file, even if present.
* `--config/-C`: load the supplied config file (instead of the detected one, if
  found)
* `--version/-V`: what version of the gem are you using?
* `--light/-l`: Enable light logging.
* `--quiet/-q: Enable quiet logging.
* `--logging/-L LEVEL: Specify logging mode that results will be returned in.
  Valid options: light, quiet
