#!/usr/bin/env bash
# Assemble the whole site into dist/ for Firebase Hosting:
#   /                          this repo (portfolio page)
#   /stories/, /talks/         this repo (index pages for data stories and talks)
#   /time/                     built from briandaviddavidson/time-person-of-the-year
#                              (/time-person-of-the-year/ redirects here; see firebase.json)
#   /nobel/                    Next.js static export of briandaviddavidson/nobel-prize-winners
#   /names/                    Next.js static export of briandaviddavidson/baby-names
#   /oscars/                   Vite build of briandaviddavidson/best-picture
#   /spelling-bee/             Vite build of briandaviddavidson/spelling-bee
#   /redistricting/            Vite build of briandaviddavidson/redistricting (private repo,
#                              cloned over SSH; unlisted: no card, no sitemap entry)
#   /cherry-blossoms/          Vite build of briandaviddavidson/cherry-blossoms (private for now,
#                              cloned over SSH; unlisted until its spring 2027 launch)
#   /congress/                 Vite build of briandaviddavidson/congress (private repo, cloned
#                              over SSH; unlisted: no card, no sitemap entry)
#   /projections/, /git-and-github/, /d3-maptime/
#                              Maptime talk decks, from each repo's default branch
set -euo pipefail
cd "$(dirname "$0")/.."

OWNER=briandaviddavidson
OUT=dist
TALKS=(projections git-and-github d3-maptime)

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
rm -rf "$OUT"
mkdir -p "$OUT"

# Portfolio: an explicit list, so nothing else in the repo is published.
cp -R index.html 404.html favicon.ico apple-touch-icon.png site.webmanifest robots.txt sitemap.xml \
  Davidson_Thesis.pdf css fonts images stories talks "$OUT"/

# Cache-bust the stylesheet: it's cached for a day, so give each version its
# own URL. Otherwise a returning visitor can get new HTML with old CSS.
css_hash=$(shasum "$OUT/css/portfolio.css" | cut -c1-10)
sed -i.bak "s|css/portfolio.css\"|css/portfolio.css?v=$css_hash\"|" "$OUT/index.html" "$OUT/404.html" "$OUT/stories/index.html" "$OUT/talks/index.html"
rm -f "$OUT"/*.bak "$OUT"/stories/*.bak "$OUT"/talks/*.bak

for talk in "${TALKS[@]}"; do
  echo "Adding /$talk/"
  git clone -q --depth 1 "https://github.com/$OWNER/$talk.git" "$WORK/$talk"
  mkdir -p "$OUT/$talk"
  git -C "$WORK/$talk" archive HEAD | tar -x -C "$OUT/$talk"
done

echo "Building /time/"
git clone -q --depth 1 "https://github.com/$OWNER/time-person-of-the-year.git" "$WORK/time"
# PUBLIC_URL sets the app's base path here, whatever `homepage` says in its package.json.
(cd "$WORK/time" && yarn install --frozen-lockfile --silent && PUBLIC_URL=/time yarn -s build)
cp -R "$WORK/time/build" "$OUT/time"

echo "Building /nobel/"
git clone -q --depth 1 "https://github.com/$OWNER/nobel-prize-winners.git" "$WORK/nobel"
# The repo commits its processed data, so the build needs no network or keys; it
# exports a static site already based at /nobel/.
(cd "$WORK/nobel" && npm ci --silent --no-audit --no-fund && npm run build --silent)
cp -R "$WORK/nobel/out" "$OUT/nobel"

echo "Building /names/"
git clone -q --depth 1 "https://github.com/$OWNER/baby-names.git" "$WORK/names"
# Same as Nobel: processed data is committed, so no network or keys are needed,
# and the export is already based at /names/.
(cd "$WORK/names" && npm ci --silent --no-audit --no-fund && npm run build --silent)
cp -R "$WORK/names/out" "$OUT/names"

echo "Building /oscars/"
git clone -q --depth 1 "https://github.com/$OWNER/best-picture.git" "$WORK/oscars"
# Processed data, findings and provider logos are committed, so the build needs no
# network or keys. (Refresh streaming availability in that repo with npm run fetch-data.)
(
  cd "$WORK/oscars"
  npm ci --silent --no-audit --no-fund
  npx vite build --base /oscars/ --outDir "$OLDPWD/$OUT/oscars" --emptyOutDir --logLevel warn
)

echo "Building /spelling-bee/"
git clone -q --depth 1 "https://github.com/$OWNER/spelling-bee.git" "$WORK/spelling-bee"
# Processed data and findings are committed, so the build needs no network, Python or
# keys. The hometown map is optional: set SPELLING_BEE_MAPS_KEY (restricted to
# briandaviddavidson.com/spelling-bee/*) and SPELLING_BEE_MAP_ID to use Google Maps;
# otherwise the page draws its SVG map.
(
  cd "$WORK/spelling-bee"
  npm ci --silent --no-audit --no-fund
  VITE_GOOGLE_MAPS_API_KEY="${SPELLING_BEE_MAPS_KEY:-}" \
  VITE_GOOGLE_MAPS_MAP_ID="${SPELLING_BEE_MAP_ID:-}" \
    npx vite build --base /spelling-bee/ --outDir "$OLDPWD/$OUT/spelling-bee" --emptyOutDir --logLevel warn
)

echo "Building /redistricting/"
# Private repo, so clone over SSH with your own GitHub credentials. Processed data
# is committed, so no network or data keys are needed. The Google map in chart 4 is
# optional: set REDISTRICTING_MAPS_KEY (restricted to briandaviddavidson.com/redistricting/*)
# and REDISTRICTING_MAP_ID to enable it; otherwise the page draws its SVG map.
git clone -q --depth 1 "git@github.com:$OWNER/redistricting.git" "$WORK/redistricting"
(
  cd "$WORK/redistricting"
  npm ci --silent --no-audit --no-fund
  VITE_GOOGLE_MAPS_API_KEY="${REDISTRICTING_MAPS_KEY:-}" \
  VITE_GOOGLE_MAPS_MAP_ID="${REDISTRICTING_MAP_ID:-}" \
    npx vite build --base /redistricting/ --outDir "$OLDPWD/$OUT/redistricting" --emptyOutDir --logLevel warn
)

echo "Building /cherry-blossoms/"
# Private repo for now, so clone over SSH like redistricting. Processed data and
# findings are committed, so no network or keys are needed. Unlisted until launch
# (spring 2027): no card and no sitemap entry; shared by link only.
git clone -q --depth 1 "git@github.com:$OWNER/cherry-blossoms.git" "$WORK/cherry-blossoms"
(
  cd "$WORK/cherry-blossoms"
  npm ci --silent --no-audit --no-fund
  npx vite build --base /cherry-blossoms/ --outDir "$OLDPWD/$OUT/cherry-blossoms" --emptyOutDir --logLevel warn
)

echo "Building /congress/"
# Private repo, cloned over SSH like redistricting. Processed data and findings are
# committed, so no network or keys are needed. Unlisted: no card and no sitemap entry;
# shared by link only.
git clone -q --depth 1 "git@github.com:$OWNER/congress.git" "$WORK/congress"
(
  cd "$WORK/congress"
  npm ci --silent --no-audit --no-fund
  npx vite build --base /congress/ --outDir "$OLDPWD/$OUT/congress" --emptyOutDir --logLevel warn
)

echo "Built $OUT/ ($(du -sh "$OUT" | cut -f1))"
