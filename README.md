# NULL CLUB — Company website

A 3D-style static site for **NULL CLUB**, showcasing SmartCart, Saidu, GymFlow, MemoroLearn (coming soon), and ready for privacy policy and support pages.

## Run locally

Open `index.html` in a browser, or use a simple static server:

```bash
# Python
python3 -m http.server 8000

# Node (npx)
npx serve .
```

Then visit `http://localhost:8000`.

## Structure

- **index.html** — Landing: hero with Three.js 3D background, products section, footer.
- **privacy.html** — Placeholder for your privacy policy (replace content when ready).
- **support.html** — Placeholder for support (FAQ, contact, or links to your help desk).
- **css/styles.css** — Layout, typography, glassmorphism, card hover effects.
- **js/scene.js** — Three.js hero scene (floating shapes, lights).
- **js/main.js** — Smooth scroll, optional parallax, clickable app cards.
- **assets/** — Favicon and (optional) app icons.

## Adding app store links

In `index.html`, update the product cards:

- **SmartCart** and **Saidu:** set each “Get the app” link `href` to your App Store and/or Play Store URLs.
- **GymFlow:** when launched, replace the “Notify me” link with store links or a waitlist URL.

## Hosting

Upload the folder to any static host (GitHub Pages, Netlify, Vercel, or your own server). Use relative links (`privacy.html`, `support.html`) so it works at any path. For clean URLs like `/privacy`, configure redirects or use a static generator later.

## Tech

- Vanilla HTML, CSS, JavaScript.
- [Three.js](https://threejs.org/) (CDN) for the hero 3D background.
- Fonts: Syne (display), DM Sans (body).
