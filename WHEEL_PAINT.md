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

`CarSpecs.isPaintable` gains **14**, so a full respray covers the rims like any
other paintable part. **13 (tyres) is deliberately excluded** — nothing tints
tyre rubber, so it would only write a `cc` the renderer ignores.

## Server side

The client change alone gives you whole-car respray coverage. A dedicated
**Wheels** row in the paint shop's left menu is server data: add a
`paintCategories` row with `i="14"` for each location you want it sold in, with
its own price/point price. `isPaintable` is not consulted for that menu — it is
built straight from `_global.paintCategoriesXML` — so no further client work is
needed to make the row appear.

## Two things to look at in game

**Black wheels are unreachable, on purpose.** The tint is gated on a *truthy*
colour, not a defined one. If the server persists an unpainted wheel node's `cc`
as `"000000"`, an "is it defined" gate would multiply every wheel on every car to
black — a game-wide regression rather than a feature. Zero is also exactly what
an unpainted part sends (`installCartPart` writes `cc = 0`). The cost is that
pure black cannot be selected; the art is usually already dark, so this is close
to free.

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
