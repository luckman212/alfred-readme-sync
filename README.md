# alfred-readme-sync

A helper script to push, pull or compare a `README.md` from the local git repo to what is configured in an Alfred workflow.

See https://www.alfredforum.com/topic/22945-readme-syncer for discussion.

Copy to your `$PATH` somewhere and make sure it has `+x` executable bit set.

## Usage

Run with `-h`, `--help` to show syntax.

```
$ alfred-readme-sync.sh
Display, push, or pull README between Alfred workflow and filesystem
Usage: alfred-readme-sync.sh <command> <uid/path|.>
    -c,--compare   compare README.md <-> Alfred's config version
    --copy         copy Alfred's readme to pasteboard
    --push         copy README.md in → Alfred's readme
    --pull         copy Alfred's readme out → README.md
```

## N.B.

When run with the `-c`/`--compare` flag it will check for and install the [`icdiff`](https://www.jefftk.com/icdiff) tool for better terminal diff output. If you inspect the source, you will find some alternate tools if you prefer, including `sdiff` which is included in the base OS.
