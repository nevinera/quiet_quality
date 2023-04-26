# QuietQuality

Work in Progress

But essentially, QuietQuality is intended for two purposes:

1. Let you conveniently run tools like rubocop, rspec, and standard against the _relevant_
   files locally (the files that have changed locally relative to the default branch)
2. Let you run those tools in CI (probably github actions) and annotate any issues found
   with _new or modified_ code, without bothering you about existing issues that you didn't
   touch.


Basic usage examples:

```
# you have five commits in your feature branch and 3 more files changes but not committed.
# this will run rubocop against all of those files.
qq rubocop

# run rspec against the changed specs, and annotate any failing specs (well, the first 10
# of them) against the commit using github's inline output-based annotation approach. Which
# will of course only produce actual annotations if this happens to have been run in a
# github action.
qq rspec --annotate=stdout

# run standardrb against all of the files (not just the changed ones). Still only print out
# problems to lines that have changed, so not particularly useful :-)
qq standard --all --incremental

# run all of the tools against the entire repository, and print the first three messages
# out for each tool.
qq all --all --full --limit-per-tool=3
```
