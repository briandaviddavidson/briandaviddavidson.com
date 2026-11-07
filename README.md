# briandaviddavidson.com

Source for my personal portfolio site, [briandaviddavidson.com](https://briandaviddavidson.com). The portfolio is a few static pages (home, `/stories/`, `/talks/`): plain HTML, with styles written in Sass. A small build script also pulls in my other projects so everything is served from one domain.

## Layout

| Path | What it is |
|---|---|
| `index.html` | The homepage |
| `stories/index.html` | All data stories; the homepage shows the three newest. Add a card to both when you ship a new story |
| `talks/index.html` | Conference talks and Maptime slide decks |
| `sass/portfolio.scss` | Styles (source) |
| `css/portfolio.css` | Compiled styles; commit it alongside the Sass |
| `fonts/montserrat-700-latin.woff2` | Self-hosted heading font (cached for a year: rename the file if you replace it) |
| `images/` | Headshot and project screenshots (WebP with JPEG fallback), `social-card.jpg` for link previews, site icons |
| `404.html`, `robots.txt`, `sitemap.xml`, `site.webmanifest`, `favicon.ico`, `apple-touch-icon.png` | Site plumbing; update `sitemap.xml` when you add a page |
| `bdd-headshot.jpeg` | Full-resolution headshot (not deployed) |
| `Davidson_Thesis.pdf` | M.S. thesis, linked from the Education section |
| `_index-original.html` | Reference copy of the 2022 resume page with the original job-description bullets (not deployed) |
| `scripts/build.sh` | Assembles the deployable site in `dist/` (gitignored) |
| `firebase.json`, `.firebaserc` | Firebase Hosting config; serves `dist/` |

## Local development

Serve the folder and open http://localhost:8000:

```sh
python3 -m http.server
```

After editing `sass/portfolio.scss`, recompile the CSS:

```sh
npx sass --no-source-map sass/portfolio.scss css/portfolio.css
```

## Site paths

| Path | Source |
|---|---|
| `/`, `/stories/`, `/talks/` | This repo |
| `/google-dash/` | Retired; 301-redirects to `/` (see `firebase.json`) |
| `/time/` | [time-person-of-the-year](https://github.com/briandaviddavidson/time-person-of-the-year), built with `yarn build` (`/time-person-of-the-year/` redirects here) |
| `/nobel/` | [nobel-prize-winners](https://github.com/briandaviddavidson/nobel-prize-winners), Next.js static export built with `npm run build` |
| `/names/` | [baby-names](https://github.com/briandaviddavidson/baby-names), Next.js static export built with `npm run build` |
| `/oscars/` | [best-picture](https://github.com/briandaviddavidson/best-picture), Vite build with `--base /oscars/` |
| `/spelling-bee/` | [spelling-bee](https://github.com/briandaviddavidson/spelling-bee), Vite build with `--base /spelling-bee/`. Optional Google map: set `SPELLING_BEE_MAPS_KEY` (restricted to `briandaviddavidson.com/spelling-bee/*`) and `SPELLING_BEE_MAP_ID`; without them it draws an SVG map |
| `/redistricting/` | [redistricting](https://github.com/briandaviddavidson/redistricting) (private), Vite build. **Unlisted:** no card and no sitemap entry; shared by link only |
| `/cherry-blossoms/` | [cherry-blossoms](https://github.com/briandaviddavidson/cherry-blossoms) (private), Vite build. **Unlisted until its spring 2027 launch:** no card and no sitemap entry |
| `/projections/` | [projections](https://github.com/briandaviddavidson/projections), Maptime talk |
| `/git-and-github/` | [git-and-github](https://github.com/briandaviddavidson/git-and-github), Maptime talk |
| `/d3-maptime/` | [d3-maptime](https://github.com/briandaviddavidson/d3-maptime), Maptime talk |

## Deploying

The site is hosted on Firebase Hosting in the `briandaviddavidson-site` Google Cloud project. Build, then deploy, from the repo root:

```sh
./scripts/build.sh
npx firebase-tools deploy --only hosting
```

`build.sh` copies an explicit list of portfolio files into `dist/`, so nothing else in this repo is published. It then clones the project repos above and adds them under their paths, building the TIME app with Yarn and the Nobel, baby names, Best Picture and Spelling Bee sites with npm.

The redistricting and cherry-blossoms repos are private, so `build.sh` clones them over SSH with your GitHub credentials. Its Google map is optional: set `REDISTRICTING_MAPS_KEY` (restricted to `briandaviddavidson.com/redistricting/*`) and `REDISTRICTING_MAP_ID` before running `build.sh`; without them the page uses its built-in SVG map.

Rerun it whenever any of those repos change. Before a risky change, deploy to a temporary preview URL first:

```sh
npx firebase-tools hosting:channel:deploy preview --expires 1h
```

## Domains

DNS is managed at Squarespace Domains.

| Domain | Serves |
|---|---|
| `briandaviddavidson.com` | This site (Firebase project `briandaviddavidson-site`) |
| `www.briandaviddavidson.com` | Redirects to `briandaviddavidson.com` |
| `time.briandaviddavidson.com` | Redirects to `/time/` (Firebase project `time-person-of-the-year`) |

GitHub Pages is turned off for this repo and the project repos; everything is served from `briandaviddavidson.com`.
