# Wheel paint

Wheels can now take a colour. They never could before, despite every layer
above the renderer looking like they should.

## Why it never worked

`CarSpecs` has carried `wheelFClr` / `wheelRClr` since it shipped — `applyCarXML`
sets them from the cat-14 node's `cc` — and `wheelF`/`wheelR` are both listed in
`CarConstruction.partsArr`, so the colour looked wired end to end.

It wasn't. `Drawing`'s `onLoadInit` excludes `wheelF` and `wheelR` from the
`actual` rename every other part receives (`classes/Drawing.as:1487`). So:

- `CarConstruction.init()` skips them — it only calls `initPart` when
  `__MC[part].actual` exists, so wheels never get the `paint`/`shad`/`hi` stack.
- `setPartColor`'s first line is `target = target.actual`, which is `undefined`
  for a wheel. Every line after it is a silent no-op on `undefined`.

The colour was being parsed, stored and passed in, and then quietly dropped.

## What changed

`CarConstruction.setWheelColor` tints the wheel clip directly with a multiplying
`ColorTransform`, called from `setColors`.

A multiply rather than `Color.setRGB` because `setRGB` flattens the clip to one
solid fill and discards the spokes' shading. Scaling each channel against
silver/chrome art reads as anodising and keeps the highlights the render already
has.

`CarSpecs.isPaintable` deliberately does **not** list 14, and must not — see
"Why a full respray does not touch the rims" below.

## Server side

Wheels are bought through a dedicated **Wheels** row, which is entirely server
data. Two changes in `src/features/paint/paint-catalog.js`:

1. `parsePaintJobs` filters every job against `PAINTABLE_PART_CATEGORY_IDS`,
   which has no 14, so a `14~RRGGBB` job is **silently dropped** rather than
   rejected. A wheels-only cart therefore parses to `[]` and returns `code: -1`
   → the client's "Illegal Action" alert. Worse, a *mixed* cart succeeds, charges
   only the surviving rows, and the client still patches the wheel `cc` locally —
   a silent partial success that reverts on the next login. Fix by decoupling:
   keep `PAINTABLE_PART_CATEGORY_IDS` as "what a whole-car respray clears", and
   add a separate buyable set that includes 14 for `parsePaintJobs`.
2. Append `[14, "Wheels"]` to `PAINTABLE_PART_CATEGORIES` so the catalog emits a
   row for all five locations. Append, so no existing row shifts.

Keep the price at the existing 350 unless you introduce a shared
`basePriceForCategory(id)` used by both the catalog builder and
`paintPriceForJobs` — they are independent today, so any other number makes the
cart and the charge disagree.

`getpaintcats` is only read at **login**, so every player must re-login before
the row appears. Ship the server first: the client needs no change for the row,
so there is never a window where it offers something the server refuses.

## Why a full respray does not touch the rims

The server's whole-car (`-2`) handler **clears** each paintable part's `cc` to 0
rather than setting it to the body colour. For every normal part that is
invisible: `setGlobalColor` paints everything in `partsArr` first, and a cleared
`cc` fails `CarSpecs`' `cc.length > 1` gate, so the part just keeps the body
colour.

Wheels are the one part where clear and set are not equivalent, because
`setPartColor` is a no-op on them and the tint comes solely from `setWheelColor`,
which needs a truthy `wheelFClr`. Cleared means **chrome**, not body colour. So
listing 14 in `isPaintable` would make the client show resprayed rims that the
server never persisted, reverting at the next `getallcars`. Only "neither side
includes 14" is consistent.

## Two things to look at in game

**Black wheels are unreachable, on purpose — and buying black is the undo.** The
tint is gated on a *truthy* colour, not a defined one. If the server persists an
unpainted wheel node's `cc` as `"000000"`, an "is it defined" gate would multiply
every wheel on every car to black — a game-wide regression rather than a feature.
Zero is also exactly what an unpainted part sends (`installCartPart` writes
`cc = 0`).

The useful side effect: `000000` is a valid palette colour and passes server
validation, so **buying black restores the stock chrome wheel**. That is the
player-facing undo, but from the outside it looks like a bug — worth a line in
the shop copy if you ever add one.

**Thumbnails vs the garage.** `BitmapData.draw()` ignores the source clip's own
colour transform unless it is passed one — which is why `drawTireMap` hands it an
explicit identity. The two wheel draws in `drawTireFGroup`/`drawTireRGroup` now
pass the wheel's transform so the tint survives into the baked low-scale views.
If tinted wheels come out looking *doubled-dark* in thumbnails while correct in
the garage, this player applies the source transform itself and the third
argument should come back off — that is the one behaviour here I could not
verify without running the client.

## Not done: brake calipers

Calipers were part of the original proposal and are **not deliverable**. The
`brake` clip is positioned every frame by `CarConstruction` and `CarSpecs` has a
`brakeID`, but nothing ever loads art into it: `brakeFF.swf` is referenced
nowhere in the codebase and `classes/Drawing.as` contains no reference to
`brake` at all. It is a vestigial clip, not an untinted one.

Wiring it up means loading the brake art in the car view, which lives in
`classes.Drawing` — the class whose recompile has hung this client at startup,
and which costs ~2,100 bytes just to enter the build chain.
