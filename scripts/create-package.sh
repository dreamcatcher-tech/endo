#!/bin/bash

# Updates or creates a package with the given name (idempotent).
# The name is the directory it will be housed in.
# The name will have @endo/ in package.json by default, if the package is
# new.
#
# Usage: scripts/repackage.sh NAME
# Example: scripts/repackage.sh console

set -ueo pipefail

DIR=$(dirname -- "${BASH_SOURCE[0]}")
cd "$DIR/.."

NAME=$1
PKGJSON=packages/$NAME/package.json

cp -r packages/skel packages/"$NAME"
mkdir -p "packages/$NAME/"{src,dist,test}

NEWPKGJSONHASH=$(
  < "$PKGJSON" jq --arg name "$NAME" '{
    name: null,
    version: null,
    private: null,
    description: null,
    keywords: [],
    author: "Endo contributors",
    license: "Apache-2.0",
    homepage: null,
    repository: null,
    bugs: null,
    type: null,
    main: null,
    module: null,
    exports: {},
    scripts: {},
    dependencies: {},
    devDependencies: {},
    files: [],
    publishConfig: null,
    eslintConfig: null,
    ava: null,
  } + . + {
    name: (.name // "@endo/\($name)"),
    version: (.version // "0.1.0"),
    homepage: (.homepage // "https://github.com/endojs/endo/tree/master/packages/\($name)#readme"),
    repository: (.repository + { directory: "packages/\($name)" }),
    scripts: ((.scripts // {}) | to_entries | sort_by(.key) | from_entries),
    dependencies: ((.dependencies // {}) | to_entries | sort_by(.key) | from_entries),
    devDependencies: ((.devDependencies // {}) | to_entries | sort_by(.key) | from_entries),
  }' | git hash-object -w --stdin
)

git cat-file blob "$NEWPKGJSONHASH" > "$PKGJSON"
