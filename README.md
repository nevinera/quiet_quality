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

* `default_tools`: Which tools should be run when you `qq` without specifying?
  Valid values are: `rubocop`, `rspec`, `standardrb`, `haml_lint`, `brakeman`,
  and `markdown_lint`.
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
* `colorize`: by default, `bin/qq` will include color codes in its output, to
  make failing tools easier to spot, and messages easier to read. But you can
  supply `colorize: false` to tell it not to do that if you don't want them.
* `message_format`: you can specify a format string with which to render the
  messages, which interpolates values with various formatting flags. Details
  given in the "Message Formatting" section below.

And then each tool can have an entry, within which `changed_files` and
`filter_messages` can be specified - the tool-specific settings override the
global ones.

The tools have two additional settings that are not available at a global level:
`file_filter` and `excludes`. `file_filter` is a string that will be turned into
a _ruby regex_, and used to limit what file paths are passed to the tool. For
example, if you are working in a rails engine `engines/foo/`, and you touch one
of the rspec tests there, you would not want `qq` in the root of the repository
to run `rspec engines/foo/spec/foo/thing_spec.rb` - that probably won't work, as
your engine will have its own test setup code and Gemfile. This setting is
mostly intended to be used like this:

```yaml
rspec:
  changed_files: true
  filter_messages: false
  file_filter: "^spec/"
```

`excludes` are more specific in meaning - this is an _array_ of regexes, and any
file that matches any of these regexes will _not_ be passed to the tool as an
explicit command line argument. This is generally because tools like rubocop
have internal systems for excluding files, but if you pass a filename on the
cli, those systems are ignored. That means that if you have changes to a
generated file like `db/schema.rb`, and that file doesn't meet your rubocop (or
standardrb) rules, you'll get _told_ unless you exclude it at the quiet-quality
level as well.

### Message Formatting

You can supply a message-format string on the cli or in your config file, which
will override the default formatting for message output on the CLI. These format
strings are intended to be a single line containing "substitution tokens", which
each look like `%[lr]?[bem]?color?(Size)(Source)`.

* The first (optional) flag can be an "l", and "r", or be left off (which is the
  same as "l"). This flag indicates the 'justification' - left or right.
* The second (optional) flag can be a "b", an "e", or an "m", defaulting to "e";
  these stand for "beginning", "ending", and "middle", and represent what part
  of the string should be truncated if it needs to be shortened.
* The third (optional) part is a color name, and can be any of "yellow", "red",
  "green", "blue", "cyan", or "none" (leaving it off is the same as specifing
  "none"). This is the color to use for the token in the output - note that any
  color supplied here is used regardless of the '--colorize' flag.
* The fourth part of the token is required, and is the _size_ of the token. If a
  positive integer is supplied, then the token will take up that much space, and
  will be padded on the appropriate side if necessary; if a negative integer is
  supplied, then the token will not be padded out, but will still get truncated
  if it is too long. The value '0' is special, and indicates that the token
  should be neither padded nor truncated.
* The last part of the token is a string indicating the _source_ data to
  represent, and must be one of these values: "tool", "loc", "level", "path",
  "lines", "rule", "body". Each of these represents one piece of data out of the
  message object that can be rendered into the message line.

Some example message formats:

```text
%lcyan8tool | %lmyellow30rule | %0loc
%le6tool [%mblue20rule] %b45loc   %cyan-100body
```

### CLI Options

To specify which _tools_ to run (and if any are specified, the `default_tools`
from the configuration file will be ignored), you supply them as positional
arguments: `qq rubocop rspec --all-files -L` will run the `rubocop` and `rspec`
tools, for example.

Run `qq --help` for a detailed list of the CLI options, they largely agree with
those in the configuration file, but there are some differences. There's no way
to specify a `file_filter` for a tool on the command-line, and there are some
additional options available focused on managing the interactions with
configuration files.

```text
Usage: qq [TOOLS] [GLOBAL_OPTIONS] [TOOL_OPTIONS]
    -h, --help                       Prints this help
    -V, --version                    Print the current version of the gem
    -C, --config PATH                Load a config file from this path
    -N, --no-config                  Do not load a config file, even if present
    -E, --executor EXECUTOR          Which executor to use
    -A, --annotate ANNOTATOR         Annotate with this annotator
    -G, --annotate-github-stdout     Annotate with GitHub Workflow commands
    -a, --all-files [tool]           Use the tool(s) on all files
    -c, --changed-files [tool]       Use the tool(s) only on changed files
    -B, --comparison-branch BRANCH   Specify the branch to compare against
    -f, --filter-messages [tool]     Filter messages from tool(s) based on changed lines
    -u, --unfiltered [tool]          Don't filter messages from tool(s)
        --[no-]colorize              Colorize the logging output
    -n, --normal                     Print outcomes and messages
    -l, --light                      Print aggregated results only
    -q, --quiet                      Don't print results, only return a status code
    -L, --logging LEVEL              Specify logging mode (from light/quiet/normal)
    -v, --verbose                    Log more verbosely - multiple times is more verbose
```
