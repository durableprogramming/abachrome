#!/bin/bash
set -euo pipefail

# Sync with upstream abachrome repo, replacing BigDecimal with float

cd "$(git rev-parse --show-toplevel)"

UPSTREAM="upstream"
if ! git remote | grep -q "^${UPSTREAM}\$"; then
  git remote add "${UPSTREAM}" https://github.com/durableprogramming/abachrome.git
fi

git fetch "${UPSTREAM}"
LOCAL_BRANCH=$(git symbolic-ref --short HEAD || echo main)
REMOTE_BRANCH=master
git pull upstream "${REMOTE_BRANCH}"
#git checkout "${BRANCH}" || /bin/true
#git reset --hard "${UPSTREAM}/main"

# Remove abc_decimal.rb (assuming path; adjust if needed)
rm -f lib/abc_decimal.rb

# Remove require statements for abc_decimal
for file in $(git ls-files -- '*.rb' 'gemspec'); do
  sed -i '/require.*abc_decimal/d' "$file"
done

# Replace AbcDecimal(...) with (...).to_f
for file in $(git ls-files -- '*.rb' 'gemspec'); do
  sed -i 's/AbcDecimal(\([^)]*\))/\1.to_f/g' "$file"
done

# Replace .to_abc with .to_f
for file in $(git ls-files -- '*.rb' 'gemspec'); do
  sed -i 's/\.to_abc/\.to_f/g' "$file"
done

# Update gemspec: remove bigdecimal dependency (adjust pattern as needed)
if [ -f abachrome.gemspec ]; then
  sed -i '/s.add_dependency.*bigdecimal/d' abachrome.gemspec
  sed -i '/s.add_runtime_dependency.*bigdecimal/d' abachrome.gemspec
fi

# Additional replacements if needed (etc.)

# Stage and commit
git add .
git status
git commit -m "Sync with upstream abachrome $(git log -1 --format=%H upstream/${REMOTE_BRANCH})" || echo "No changes to commit"

# Make executable
