"""Builds Friendzy's search pages from the app's own content (the Android sources):
  - friendzy/<list>.html and friendzy/es/<list>.html: 100 family-friendly prompts per game
  - friendzy/games/*.html and friendzy/es/juegos/*.html: rules for the 44 classic games
  - the Friendzy block of sitemap.xml (between the FRIENDZY-SEO markers)

    python3 scripts/build_friendzy_seo.py [--app ~/AndroidStudioProjects/Friendzy]

Re-run after the app's prompts or rules change. Pages are fully generated: don't hand-edit them.
"""
import html, json, os, re, sys, unicodedata, datetime

SITE = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
APP = os.path.expanduser(sys.argv[sys.argv.index("--app") + 1]) if "--app" in sys.argv else os.path.expanduser("~/AndroidStudioProjects/Friendzy")
DATA = os.path.join(APP, "app/src/main/java/com/nullclub/friendzy/data")
BASE = "https://nullclub.xyz"
GET = "/go-friendzy.html"  # sends each visitor to their own store
TODAY = datetime.date.today().isoformat()
PER_PAGE = 100

# Same family filter as the marketing videos (Blender/templates/prompts.py), plus a few web-specific words.
AVOID = ("fire", "fake", "stole", "steal", "shoplift", "cheat", "police", "arrest", "hospital", "drunk", "alcohol",
         "beer", "wine", "vape", "smok", "kiss", "date", "crush", "ex ", "ex's", "naked", "underwear", "toilet", "pee",
         "vomit", "threw up", "fight", "punch", "hate", "stalk", "relationship", "wardrobe", "resume", "coworker", "lied to my parents", "snuck out", "skipped school",
         "stood up", "dumped", "breakup", "break up", "sex", "boyfriend", "girlfriend", "flirt", "drug", "weed",
         "jail", "prison", "die", "dead", "kill", "body", "butt", "bathroom", "lick")


def family_ok(text):
    low = f" {text.lower()} "
    return not any(w in low for w in AVOID)


# ---------- reading the Kotlin sources ----------

STR = r'"((?:[^"\\]|\\.)*)"'


def unq(s):
    return json.loads('"' + s.replace("\\$", "$").replace("\\'", "'") + '"')


def deck(src, name, kind):
    """All items of `name` (its _p0.._pN parts, in order)."""
    out = []
    for part in re.finditer(rf"private fun {name}_p\d+\(\): List<\w+> = listOf\((.*?)\n  \)", src, re.S):
        body = part.group(1)
        if kind == "str":
            out += [unq(m) for m in re.findall(rf"^\s*{STR},?\s*$", body, re.M)]
        elif kind == "wyr":
            out += [(unq(a), unq(b)) for a, b in re.findall(rf"option1 = {STR}, option2 = {STR}", body)]
        elif kind == "tod":
            out += [unq(m) for m in re.findall(rf"text = {STR}", body)]
    return out


def rule_games(src):
    games = []
    for chunk in src.split("RuleBasedGame(title = ")[1:]:
        f = lambda key: unq(re.search(rf"{key} = {STR}", chunk).group(1))
        lst = lambda key: [unq(m) for m in re.findall(rf"^\s*{STR},?\s*$", re.search(rf"{key} = listOf\((.*?)\n\)", chunk, re.S).group(1), re.M)]
        n = lambda key: int(re.search(rf"{key} = (\d+)", chunk).group(1))
        games.append(dict(
            title=unq(re.match(STR, chunk).group(1)), tagline=f("tagline"), description=f("description"),
            steps=lst("howToPlay"), examples=lst("examples"), tips=lst("tips"), vibe=f("vibe"),
            category=re.search(r"category = RuleBasedCategory\.(\w+)", chunk).group(1),
            min=n("minPlayers"), max=n("maxPlayers"), minutes=n("estimatedMinutes"),
            car="isCarFriendly = true" in chunk))
    return games


def slug(text):
    t = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode().lower()
    t = re.sub(r"[^a-z0-9]+", "-", t).strip("-")
    return t or "game"


# ---------- page template ----------

E = html.escape

T = {
    "en": dict(products="Products", privacy="Privacy", support="Support", get="Get Friendzy free",
               cta_h="Want 1,000 more?", lists="Question lists", games="Classic party games", home="Friendzy",
               players="players", minutes="min", car="Works in the car", how="How to play", examples="Example round",
               tips="Tips", back_games="All 44 classic games", lang_name="Español", other="es"),
    "es": dict(products="Productos", privacy="Privacidad", support="Soporte", get="Descarga Friendzy gratis",
               cta_h="¿Quieres 1000 más?", lists="Listas de preguntas", games="Juegos clásicos de fiesta", home="Friendzy",
               players="jugadores", minutes="min", car="Se puede jugar en el coche", how="Cómo se juega", examples="Ejemplo",
               tips="Consejos", back_games="Los 44 juegos clásicos", lang_name="English", other="en"),
}


def page(lang, path, title, desc, h1, body, crumbs, alt_path=None):
    """path: site-relative (friendzy/x.html). crumbs: [(name, path)] after Friendzy."""
    t = T[lang]
    depth = path.count("/")
    up = "../" * depth
    alts = ""
    if alt_path:
        pair = {lang: path, t["other"]: alt_path}
        alts = "".join(f'\n  <link rel="alternate" hreflang="{k}" href="{BASE}/{v}">' for k, v in pair.items())
        alts += f'\n  <link rel="alternate" hreflang="x-default" href="{BASE}/{pair["en"]}">'
    trail = [("NULL CLUB", ""), (t["home"], "friendzy.html")] + crumbs
    ld = {"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
        {"@type": "ListItem", "position": i + 1, "name": n, "item": f"{BASE}/{p}"} for i, (n, p) in enumerate(trail)]}
    switch = f'<a href="{up}{alt_path}" hreflang="{t["other"]}" lang="{t["other"]}">{t["lang_name"]}</a>' if alt_path else ""
    nav_crumbs = " / ".join(f'<a href="{up}{p}">{E(n)}</a>' for n, p in trail[1:-1]) + f" / {E(trail[-1][0])}"
    return f"""<!DOCTYPE html>
<!-- Generated by scripts/build_friendzy_seo.py from the Friendzy app's content. Don't hand-edit. -->
<html lang="{lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{E(title)}</title>
  <meta name="description" content="{E(desc)}">
  <link rel="canonical" href="{BASE}/{path}">{alts}
  <meta property="og:type" content="article">
  <meta property="og:title" content="{E(title)}">
  <meta property="og:description" content="{E(desc)}">
  <meta property="og:url" content="{BASE}/{path}">
  <meta property="og:image" content="{BASE}/assets/og/friendzy.png">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="icon" type="image/svg+xml" href="{up}assets/favicon.svg">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400..800&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="{up}css/styles.css">
  <style>
    .crumbs {{ font-size: 0.85rem; opacity: 0.75; margin-bottom: 1rem; }}
    .qlist {{ padding-left: 1.6rem; }}
    .qlist li {{ margin: 0.45rem 0; line-height: 1.45; }}
    .qlist li::marker {{ font-weight: 700; color: var(--red); }}
    .cta-box {{ border: 2px solid currentColor; border-radius: 18px; padding: 1.2rem 1.4rem; margin: 2rem 0; }}
    .cta-box h2 {{ margin-top: 0; }}
    .facts {{ display: flex; flex-wrap: wrap; gap: 0.5rem; margin: 0.8rem 0 1.2rem; }}
    .facts span {{ border: 1px solid currentColor; border-radius: 999px; padding: 0.15rem 0.7rem; font-size: 0.85rem; }}
    .links-grid {{ columns: 2 14rem; padding-left: 1.2rem; }}
    .links-grid li {{ margin: 0.3rem 0; break-inside: avoid; }}
  </style>
  <script type="application/ld+json">{json.dumps(ld, ensure_ascii=False)}</script>
</head>
<body>
  <header class="header">
    <a href="{up}index.html" class="logo">NULL CLUB</a>
    <nav class="nav">
      <a href="{up}index.html#products">{t["products"]}</a>
      <a href="{up}friendzy.html">Friendzy</a>
      {switch}
    </nav>
  </header>
  <main class="page app-page" style="--app:var(--red)">
    <div class="page-content">
      <p class="crumbs">{nav_crumbs}</p>
      <h1>{E(h1)}</h1>
{body}
    </div>
  </main>
  <footer class="footer">
    <a href="{up}index.html" class="footer-logo">NULL CLUB</a>
    <nav class="footer-nav">
      <a href="{up}privacy-friendzy.html">{t["privacy"]}</a>
      <a href="{up}support.html">{t["support"]}</a>
    </nav>
  </footer>
</body>
</html>
"""


def cta(lang, text):
    t = T[lang]
    depth_fix = ""  # GET is root-absolute
    return f"""      <section class="cta-box">
        <h2>{E(t["cta_h"])}</h2>
        <p>{E(text)}</p>
        <div class="cta-row"><a href="{GET}" class="cta">{E(t["get"])}</a></div>
      </section>"""


# ---------- question lists ----------

LISTS = [
    # key, deck, kind, en slug, es slug
    ("nhie", "neverHaveIEver", "str", "never-have-i-ever-questions", "preguntas-yo-nunca"),
    ("wyr", "wouldYouRather", "wyr", "would-you-rather-questions", "preguntas-que-prefieres"),
    ("mlt", "mostLikelyTo", "str", "most-likely-to-questions", "preguntas-quien-es-mas-probable"),
    ("tod", None, "tod", "truth-or-dare-questions", "preguntas-verdad-o-reto"),
]

COPY = {
    ("nhie", "en"): dict(
        title="100 Never Have I Ever Questions (Clean & Family-Friendly)",
        h1="100 Never Have I Ever questions",
        desc="100 clean Never Have I Ever questions for friends, teens and families. Funny, harmless and ready to read out at your next game night.",
        intro="Never Have I Ever is the easiest party game there is: someone reads a statement, and everyone who has done it puts a finger down (or takes a point). These 100 questions are clean and funny, so they work for teens, family nights and mixed groups.",
        how=["Everyone holds up five (or ten) fingers.", "Take turns reading a statement that starts with “Never have I ever…”.",
             "Anyone who has done it puts a finger down, and tells the story if the group asks.", "The last player with fingers up wins."],
        more="Friendzy has about 1,000 Never Have I Ever prompts, shuffled fresh every game, plus Riot the fox hosting the night."),
    ("nhie", "es"): dict(
        title="100 preguntas de Yo nunca (aptas para todos)",
        h1="100 preguntas de Yo nunca",
        desc="100 frases de Yo nunca para amigos, adolescentes y familias. Divertidas, sin nada subido de tono y listas para tu próxima noche de juegos.",
        intro="Yo nunca es el juego de fiesta más sencillo: alguien lee una frase y quien lo haya hecho baja un dedo. Estas 100 frases son limpias y graciosas, perfectas para adolescentes, noches en familia y grupos mixtos.",
        how=["Todos levantan cinco (o diez) dedos.", "Por turnos, se lee una frase que empieza por «Yo nunca…».",
             "Quien lo haya hecho baja un dedo, y cuenta la historia si el grupo lo pide.", "Gana el último que conserve algún dedo levantado."],
        more="Friendzy tiene unas 1000 frases de Yo nunca, mezcladas en cada partida, con Riot el zorro como anfitrión."),
    ("wyr", "en"): dict(
        title="100 Would You Rather Questions (Funny & Clean)",
        h1="100 Would You Rather questions",
        desc="100 funny, clean Would You Rather questions for friends, teens and families. Impossible choices that start the loudest debates.",
        intro="Would You Rather needs no setup at all: read two options, everyone picks one, and then the debating starts. These 100 questions are silly, clean and surprisingly hard to answer.",
        how=["Read out both options.", "Everyone picks one at the same time: point left or right, or shout it out.",
             "The smallest side has to defend their choice.", "Pass to the next reader."],
        more="Friendzy has about 1,000 Would You Rather questions, with a new one every tap."),
    ("wyr", "es"): dict(
        title="100 preguntas de ¿Qué prefieres? (divertidas y para todos)",
        h1="100 preguntas de ¿Qué prefieres?",
        desc="100 preguntas de ¿Qué prefieres? divertidas y sin nada subido de tono, para amigos, adolescentes y familias.",
        intro="¿Qué prefieres? no necesita preparación: se leen dos opciones, cada uno elige una y empieza el debate. Estas 100 preguntas son absurdas, limpias y sorprendentemente difíciles.",
        how=["Lee las dos opciones en voz alta.", "Todos eligen a la vez: señalando a un lado o al otro, o gritándolo.",
             "El bando más pequeño tiene que defender su elección.", "Le toca leer al siguiente."],
        more="Friendzy tiene unas 1000 preguntas de ¿Qué prefieres?, una nueva con cada toque."),
    ("mlt", "en"): dict(
        title="100 Most Likely To Questions (Funny & Family-Friendly)",
        h1="100 “Who's most likely to” questions",
        desc="100 funny Most Likely To questions for friends, families and teens. Everyone points, nobody escapes.",
        intro="In Most Likely To, someone reads a question and on the count of three everyone points at the person who fits it best. These 100 questions are funny without being mean, so nobody leaves upset.",
        how=["Read the question out loud.", "Count to three, and everyone points at the person most likely to do it.",
             "Whoever gets the most fingers has to explain themselves.", "They read the next one."],
        more="Friendzy has about 1,000 Most Likely To prompts, and in a room everyone votes on their own phone."),
    ("mlt", "es"): dict(
        title="100 preguntas de ¿Quién es más probable? (divertidas y para todos)",
        h1="100 preguntas de ¿Quién es más probable?",
        desc="100 preguntas de ¿Quién es más probable? para amigos, familias y adolescentes. Todos señalan, nadie se libra.",
        intro="En ¿Quién es más probable?, alguien lee una pregunta y a la de tres todos señalan a quien mejor encaja. Estas 100 preguntas son graciosas sin ser crueles, así que nadie se enfada.",
        how=["Lee la pregunta en voz alta.", "A la de tres, todos señalan a quien es más probable que lo haga.",
             "Quien reciba más dedos tiene que dar explicaciones.", "Esa persona lee la siguiente."],
        more="Friendzy tiene unas 1000 preguntas de ¿Quién es más probable?, y en una sala cada uno vota desde su móvil."),
    ("tod", "en"): dict(
        title="100 Truth or Dare Questions (50 Truths + 50 Dares, Clean)",
        h1="100 Truth or Dare questions",
        desc="50 clean truths and 50 fun dares for friends, teens and families. Family-friendly Truth or Dare questions for any party.",
        intro="Truth or Dare is the classic for a reason. Here are 50 truths and 50 dares that are funny and harmless, so they work for sleepovers, family nights and parties with mixed ages.",
        how=["Take turns: each player picks Truth or Dare.", "Truth: answer the question honestly.",
             "Dare: do the challenge (or take the group's agreed penalty).", "Pass to the next player."],
        more="Friendzy has 500 truths and 500 dares, a dramatic card reveal, and Riot reacting to every pick."),
    ("tod", "es"): dict(
        title="100 preguntas de Verdad o reto (50 verdades + 50 retos)",
        h1="100 preguntas de Verdad o reto",
        desc="50 verdades y 50 retos divertidos y aptos para todos, para amigos, adolescentes y familias.",
        intro="Verdad o reto es un clásico por algo. Aquí tienes 50 verdades y 50 retos graciosos e inofensivos, perfectos para pijamadas, noches en familia y fiestas con todas las edades.",
        how=["Por turnos, cada jugador elige Verdad o Reto.", "Verdad: responde con sinceridad.",
             "Reto: haz el desafío (o cumple la penitencia que acuerde el grupo).", "Le toca al siguiente."],
        more="Friendzy tiene 500 verdades y 500 retos, una revelación de carta dramática y a Riot reaccionando a cada elección."),
}

LIST_NAMES = {"nhie": ("Never Have I Ever", "Yo nunca"), "wyr": ("Would You Rather", "¿Qué prefieres?"),
              "mlt": ("Most Likely To", "¿Quién es más probable?"), "tod": ("Truth or Dare", "Verdad o reto")}


def pick(en, es, n, key=lambda x: x if isinstance(x, str) else " ".join(x)):
    """n family-friendly items spread evenly across the deck (same indices in both languages)."""
    idx = [i for i, x in enumerate(en) if family_ok(key(x)) and i < len(es) and family_ok(key(es[i]))]
    step = len(idx) / n
    return [(en[idx[int(k * step)]], es[idx[int(k * step)]]) for k in range(n)]


def build_lists(en_src, es_src, sitemap):
    for key, name, kind, en_slug, es_slug in LISTS:
        if key == "tod":
            t_en, t_es = deck(en_src, "truths", "tod"), deck(es_src, "truths", "tod")
            d_en, d_es = deck(en_src, "dares", "tod"), deck(es_src, "dares", "tod")
            items = {"truth": pick(t_en, t_es, PER_PAGE // 2), "dare": pick(d_en, d_es, PER_PAGE // 2)}
        else:
            items = pick(deck(en_src, name, kind), deck(es_src, name, kind), PER_PAGE)
        for lang, sl, other in (("en", en_slug, es_slug), ("es", es_slug, en_slug)):
            c = COPY[(key, lang)]
            li = (lambda pair: pair[0 if lang == "en" else 1])
            fmt = (lambda x: f"{E(x[0])} <strong>{'or' if lang == 'en' else 'o'}</strong> {E(x[1][:1].lower() + x[1][1:])}") if kind == "wyr" else E
            if key == "tod":
                lists = "".join(
                    f'      <h2>{h}</h2>\n      <ol class="qlist">\n' + "".join(f"        <li>{fmt(li(p))}</li>\n" for p in items[part]) + "      </ol>\n"
                    for part, h in (("truth", "50 truths" if lang == "en" else "50 verdades"), ("dare", "50 dares" if lang == "en" else "50 retos")))
            else:
                lists = '      <ol class="qlist">\n' + "".join(f"        <li>{fmt(li(p))}</li>\n" for p in items) + "      </ol>\n"
            how = "".join(f"        <li>{E(s)}</li>\n" for s in c["how"])
            others = [(LIST_NAMES[k][0 if lang == "en" else 1], (es_ if lang == "es" else en_)) for k, _, _, en_, es_ in LISTS if k != key]
            prefix = "friendzy/" if lang == "en" else "friendzy/es/"
            up = "../" if lang == "en" else "../../"
            games_hub = "friendzy/games/index.html" if lang == "en" else "friendzy/es/juegos/index.html"
            rel = "".join(f'        <li><a href="{up}{prefix}{s}.html">{E(n)}</a></li>\n' for n, s in others)
            rel += f'        <li><a href="{up}{games_hub}">{E(T[lang]["back_games"])}</a></li>\n'
            body = f"""      <p class="app-intro">{E(c["intro"])}</p>
      <h2>{E(T[lang]["how"])}</h2>
      <ol>
{how}      </ol>
{lists}{cta(lang, c["more"])}
      <h2>{E(T[lang]["lists"])}</h2>
      <ul class="links-grid">
{rel}      </ul>"""
            path = f"{prefix}{sl}.html"
            alt = ("friendzy/es/" if lang == "en" else "friendzy/") + f"{other}.html"
            write(path, page(lang, path, c["title"], c["desc"], c["h1"], body, [(c["h1"], path)], alt))
            sitemap.append((path, "0.8"))


# ---------- classic games ----------

CAT = {"wordGames": ("Word games", "Juegos de palabras"), "memory": ("Memory & chain games", "Memoria y cadena"),
       "acting": ("Acting & performance games", "Actuación"), "social": ("Social & discussion games", "Sociales y de conversación")}


def build_games(en_src, es_src, sitemap):
    en, es = rule_games(en_src), rule_games(es_src)
    assert len(en) == len(es) == 44, (len(en), len(es))
    slugs = {"en": [], "es": []}
    for lang, games in (("en", en), ("es", es)):
        seen = set()
        for g in games:
            s = slug(g["title"])
            while s in seen:
                s += "-2"
            seen.add(s)
            slugs[lang].append(s)
    for lang, games, folder in (("en", en, "friendzy/games"), ("es", es, "friendzy/es/juegos")):
        t = T[lang]
        other_folder = "friendzy/es/juegos" if lang == "en" else "friendzy/games"
        hub = f"{folder}/index.html"
        for i, g in enumerate(games):
            facts = [f'{g["min"]}–{g["max"]} {t["players"]}', f'~{g["minutes"]} {t["minutes"]}', g["vibe"], CAT[g["category"]][0 if lang == "en" else 1]]
            if g["car"]:
                facts.append("🚗 " + t["car"])
            same = [j for j, h in enumerate(games) if h["category"] == g["category"] and j != i][:6]
            rel = "".join(f'        <li><a href="{slugs[lang][j]}.html">{E(games[j]["title"])}</a></li>\n' for j in same)
            more = ("Friendzy has the rules for all 44 of these games, plus 14 party games played on the phone: Truth or Dare, Mafia, trivia, and room games where everyone plays on their own phone."
                    if lang == "en" else
                    "Friendzy tiene las reglas de estos 44 juegos y 14 juegos de fiesta en el móvil: Verdad o reto, Mafia, trivia y juegos en sala donde cada uno juega desde su teléfono.")
            body = f"""      <p class="app-intro"><strong>{E(g["tagline"])}</strong> {E(g["description"])}</p>
      <div class="facts">{"".join(f"<span>{E(x)}</span>" for x in facts)}</div>
      <h2>{E(t["how"])}</h2>
      <ol>
{"".join(f"        <li>{E(s)}</li>\n" for s in g["steps"])}      </ol>
      <h2>{E(t["examples"])}</h2>
      <ul>
{"".join(f"        <li>{E(s)}</li>\n" for s in g["examples"])}      </ul>
      <h2>{E(t["tips"])}</h2>
      <ul>
{"".join(f"        <li>{E(s)}</li>\n" for s in g["tips"])}      </ul>
{cta(lang, more)}
      <h2>{E(CAT[g["category"]][0 if lang == "en" else 1])}</h2>
      <ul class="links-grid">
{rel}        <li><a href="index.html">{E(t["back_games"])}</a></li>
      </ul>"""
            path = f"{folder}/{slugs[lang][i]}.html"
            alt = f"{other_folder}/{slugs['es' if lang == 'en' else 'en'][i]}.html"
            if lang == "en":
                title = f"How to Play {g['title']}: Rules for a Party Game ({g['min']}–{g['max']} Players)"
                desc = f"How to play {g['title']}: {g['tagline']} Simple rules, an example round and tips. No app or cards needed."
                h1 = f"How to play {g['title']}"
            else:
                title = f"Cómo jugar a {g['title']}: reglas del juego ({g['min']}–{g['max']} jugadores)"
                desc = f"Cómo jugar a {g['title']}: {g['tagline']} Reglas sencillas, un ejemplo y consejos. Sin app ni cartas."
                h1 = f"Cómo jugar a {g['title']}"
            write(path, page(lang, path, title, desc[:300], h1, body, [(t["games"], hub), (g["title"], path)], alt))
            sitemap.append((path, "0.6"))
        # hub
        groups = ""
        for cat, names in CAT.items():
            items = [(slugs[lang][j], g) for j, g in enumerate(games) if g["category"] == cat]
            groups += f"      <h2>{E(names[0 if lang == 'en' else 1])}</h2>\n      <ul>\n"
            groups += "".join(f'        <li><a href="{s}.html"><strong>{E(g["title"])}</strong></a> — {E(g["tagline"])}{" 🚗" if g["car"] else ""}</li>\n' for s, g in items)
            groups += "      </ul>\n"
        if lang == "en":
            title, h1 = "44 Party Games Without an App: Rules for Word, Acting & Social Games", "44 classic party games (no app needed)"
            desc = "Rules for 44 party games you play without cards or an app: word games, memory games, acting games and conversation games. 🚗 marks games that work in the car."
            intro = "Every game here needs nothing but the people in the room. Pick one, read the rules out loud, and start. Games marked 🚗 work in the car: no moving around and no passing a phone."
        else:
            title, h1 = "44 juegos de fiesta sin app: reglas de juegos de palabras, actuación y conversación", "44 juegos clásicos de fiesta (sin app)"
            desc = "Reglas de 44 juegos de fiesta sin cartas ni app: juegos de palabras, de memoria, de actuación y de conversación. 🚗 indica los que se pueden jugar en el coche."
            intro = "Para estos juegos solo hacen falta las personas que estáis en la sala. Elige uno, lee las reglas en voz alta y a jugar. Los marcados con 🚗 se pueden jugar en el coche."
        lists_prefix = "../" if lang == "en" else "../"
        list_links = "".join(f'        <li><a href="{lists_prefix}{en_ if lang == "en" else es_}.html">{E(LIST_NAMES[k][0 if lang == "en" else 1])}</a></li>\n' for k, _, _, en_, es_ in LISTS)
        body = f"""      <p class="app-intro">{E(intro)}</p>
{groups}{cta(lang, "Friendzy keeps all 44 rule cards in your pocket, plus 14 party games on the phone." if lang == "en" else "Friendzy lleva las 44 reglas en tu bolsillo, y además 14 juegos de fiesta en el móvil.")}
      <h2>{E(t["lists"])}</h2>
      <ul class="links-grid">
{list_links}      </ul>"""
        write(hub, page(lang, hub, title, desc, h1, body, [(t["games"], hub)], f"{other_folder}/index.html"))
        sitemap.append((hub, "0.8"))


# ---------- output ----------

def write(path, text):
    full = os.path.join(SITE, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(text)


def update_sitemap(entries):
    p = os.path.join(SITE, "sitemap.xml")
    s = open(p).read()
    block = "  <!-- FRIENDZY-SEO (generated by scripts/build_friendzy_seo.py) -->\n" + "".join(
        f"  <url>\n    <loc>{BASE}/{path.removesuffix('index.html')}</loc>\n    <lastmod>{TODAY}</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>{pr}</priority>\n  </url>\n"
        for path, pr in entries) + "  <!-- /FRIENDZY-SEO -->\n"
    if "<!-- FRIENDZY-SEO" in s:
        s = re.sub(r"  <!-- FRIENDZY-SEO.*?<!-- /FRIENDZY-SEO -->\n", lambda m: block, s, flags=re.S)
    else:
        s = s.replace("</urlset>", block + "</urlset>")
    open(p, "w").write(s)


def main():
    en_src = open(os.path.join(DATA, "Prompts.kt")).read()
    es_src = open(os.path.join(DATA, "PromptsEs.kt")).read()
    sitemap = []
    build_lists(en_src, es_src, sitemap)
    build_games(open(os.path.join(DATA, "RuleBasedGameLibrary.kt")).read(),
                open(os.path.join(DATA, "RuleBasedGameLibraryEs.kt")).read(), sitemap)
    update_sitemap(sitemap)
    print(f"{len(sitemap)} pages")


if __name__ == "__main__":
    main()
