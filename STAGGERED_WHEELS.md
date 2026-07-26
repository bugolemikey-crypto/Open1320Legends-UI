# Staggered wheels

Front and rear axles can now be sized independently, so a car can run the drag
stance the game never let it have: skinnies up front, tall meats out back.

No new part category, no schema migration, and no new UI. A staggered set is
just a tyre or wheel part whose `ps` value names both axles.

## Authoring

`ps` is catalog data on the part itself — the tyre shop copies it straight off
`_global.partXML` onto the car (`DefineSprite_3813/frame_1/DoAction.as:131`), so
this is a column edit in 1320Legends-Open's part table and nothing more.

| Category | `ps` today | `ps` staggered | Meaning |
|---|---|---|---|
| 13 (tyres) | `10` | `5\|35` | tyre scale %, front then rear |
| 14 (wheels) | `17` | `15\|17` | wheel diameter in inches, front then rear |

`/` works as well as `|` (`15/17`), since that is how sizes are usually written.
A bare number keeps both axles on the same value, which is why every existing
car renders exactly as it did.

Example — a drag set on category 13/14:

```
tyres:  ps="5|35"    front +5%, rear +35%
wheels: ps="15|17"   15" front, 17" rear
```

## Limits worth knowing before you author

- **Wheel diameter clamps to 14–20"** on both axles, as it always has.
- **Tyre scale caps at 100.** A stock 17" car already computes ~90, and 20" hits
  the cap. So stagger reads best when you size the **front down** rather than
  trying to push the rear past full size — which is the correct drag proportion
  anyway.
- **Both axles share one wheel design.** The garage view loads the same wheel
  art for front and rear (`classes/Drawing.as:1674`), so `15|17` gives you two
  sizes of the same wheel. Different designs per axle would mean recompiling
  `classes.Drawing`, whose recompile has hung this client at startup before —
  deliberately out of scope here. (The race view at `Drawing.as:1474-1475`
  already reads `wheelFID`/`wheelRID` separately, so it is half-wired for it.)

## How it works

The renderer was always built for this — `tireFracR`, `wheelFracR` and a
separate `setTireRGroup()` have been in `CarConstruction` since it shipped. Only
the data layer collapsed the two axles onto one number. The change reopens it:

- `CarSpecs` gains `wheelSizeR` / `tireScaleFactorR` / `wheelScaleR` /
  `tireScaleR`, parsed by `axleSpec(ps, index)`, which falls index 1 back to
  index 0 so a bare `ps` yields identical axles.
- `CarSpecs.applyCarXML` gates category 14 on `axleSpec(ps, 0)` instead of
  `Number(ps)` — `Number("15|17")` is `NaN`, which would have silently dropped
  the car back to the 16" default.
- `CarConstruction.setCar` sizes each axle from its own frac, and puts `tireR`,
  `wheelR` and `tireBack` on the rear one.
- `coreYAdj` (body height, and the offset decals are drawn at) now uses the mean
  of the two fracs. The body is a single clip and cannot tilt, so the mean keeps
  it centred between mismatched axles instead of hanging at front height with
  the rears buried in the arches.

## Verification

`python scripts/verify_stagger_math.py` transcribes both the old and the new
arithmetic and asserts they agree across every `ps` shape the stock catalog can
serve — 780 combinations, including malformed and empty values. It also asserts
a staggered `ps` actually stages the rear larger than the front.

That covers the maths. It does **not** cover the client: a Director script error
leaves the process alive with the right window title, so only a human reaching
the garage in game can confirm the build itself.
