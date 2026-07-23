# Dark UI theme — byte-neutral SWF retheming

Retheming the in-game windows normally means recompiling AS2 classes, and that
does not fit: the Flash client is embedded in `NittoLegendsBeta.exe` at offset
4,794,808 with a **fixed** 29,832,751-byte allocation, and the SWF must stay
uncompressed (`FWS`). An FFDec recompile of `classes.Drawing` alone measured
**+3,997 bytes** against a live SWF of 29,831,046 — i.e. 2,292 bytes over the
allocation. See the notes in `UI_EDITING.md` and the existing size checks in
`scripts/build_deployable_login.py`.

Everything here therefore avoids the compiler and edits the SWF in place at
**exactly** the same byte size.

## Palette

Matches the dark theme already drafted in the working `classes/` tree:

| role      | hex       | used for |
|-----------|-----------|----------|
| deep      | `#090B0C` | window floor, panel gradient bottoms |
| body      | `#14171A` | default panel body, unselected rows |
| header    | `#111415` | panel header bars |
| raised    | `#202629` | input fields, strips, raised surfaces |
| rule      | `#2E353D` | dividers and hairlines |
| text      | `#C8D0DA` | primary text on dark |
| text alt  | `#98A2AE` | secondary text on dark |
| accent    | `#FF3823` | selection, rollover glow |

## Two mechanisms

### 1. Bitmap recolour (`apply_dark_ui.py`)

The Support Center and Viewer windows are mostly **JPEG art**, not vector
shapes — 71 KB and 232 KB of `DefineBitsJPEG3` respectively, against ~1.3 KB of
shapes. The window chrome is baked into those bitmaps.

`scripts/apply_dark_ui.py` decodes each target image, runs it through the curve
in `dark_ui_theme.py`, re-encodes it, and **pads the JPEG after its EOI marker
back to the original payload length** (decoders ignore trailing bytes). The
alpha channel is left byte-identical and `alphaDataOffset` is unchanged, so the
tag length never moves. Lossless tags are re-deflated and zero-padded the same
way — `inflate` stops at the end of the stream.

One special case: character 180 is a plain `DefineBits` sharing the global
`JPEGTables`. It is re-emitted as a self-contained `DefineBitsJPEG2`; only the
tag *code* in the header changes, not the tag length.

```bat
python scripts\apply_dark_ui.py source\main.swf patches\main_client\main.dark-ui.swf
```

### 2. AS2 colour-constant patch

Colour literals compile to `ActionPush` **type-7 int32** operands (and small
numbers such as `0` to **type-6 doubles**, which Flash stores with its two
32-bit words *swapped*). Swapping one value for another of the same type is
byte-neutral and needs no compiler.

Two scripts, in pipeline order:

- `patch_as2_colors.py` — pattern-scoped edits. Locates a class's
  `DoInitAction` tag by a string unique to that class's constant pool, then
  rewrites literals within it, asserting the old value and match count. Applied
  to `classes.Drawing.newBaseWindow`'s gradient (`#A2ABB4 → #22262A`,
  `#1C2931 → #0F0F0F`), the backdrop for the Email views and the Chat window.
- `apply_dark_ui_consts.py` — offset-precise edits from `dark_ui_consts.py`,
  50 literals across Drawing, Console (NIM) and Email.

Offsets come from `pcodemap.py`, which walks FFDec's `script:pcodehex` dump and
accumulates each action's byte length to get its exact position (the action
block starts 2 bytes into the `DoInitAction` payload, after the UI16 sprite id).
That matters because `16777215` alone occurs 17× in Drawing, 13× in Console and
5× in Email — pattern matching cannot tell them apart, and P-code offsets can.
Regenerate with:

```bat
ffdec-cli -format script:pcodehex -export script pcode\ main.swf
```

## Surfaces and their text move together

Darkening a surface without flipping the text on it is the black-on-black trap.
Three separate mechanisms drive text colour here, and all three were handled:

1. **Literal `TextFormat.color`** — NIM's `txt_buddyname` / `name_txt` /
   `loc_txt`, and Email's compose fields, `fld_from` and `msgArea`.
2. **`ColorTransform.rgb`** — Email's inbox rows. `selectMail()` assigns
   `ctWhite` / `ctBlack` / `ctHi` over each row, and `.rgb` *overrides* the
   underlying `beginFill` and text format entirely, so those three values are
   the whole list. Note `ctWhite` is both the unselected row background **and**
   the selected row's text colour, so it has to be the dark tone; the selection
   inverts to the accent with that dark tone on top.
3. **A server-side stylesheet** — chat and NIM message bodies use
   `_global.n2CSS`, loaded at runtime from `gameStyles.css` in the *backend*
   repo (`src/http/gameStyles.css`). No byte budget applies there. `.nim`,
   `.e5` and `.e12` were pure `#000000` and are now light; `.e1`, `.e6`, `.e8`,
   `.e10` and `.nim_self` were tuned for a light surface and were lifted.

## Worth re-checking in game

`Email.viewEmail()` sets `fromLine` and `subjLine` to white while the pane's
`insetBox` body resolved to the white fallback — i.e. white on white, which
cannot be what shipped. Static reading did not resolve it. Either reading is
fine under the new theme (dark body + light text), but it is the one place the
live result may differ from expectation.

## Cache download screen

The download progress UI is `classes.Frame.assetLoader` — sprite **1981**,
placed inside sprite **2002** (the login sprite). Lingo drives it from
`Lscr-106_FileHandler.ls` via `loadUpdateCB` / `loadFinishCB`, so it is *not*
Director-drawn art and it is *not* `cache/misc/intro.swf` (that one is the
dialog overlay). It is ordinary SWF art inside the embedded client.

| char | kind | size | role |
|------|------|------|------|
| 1967 | JPEG3 | 426x22 | progress **track** |
| 1969 | Lossless | 1x20 | progress **fill** |
| 1972 | Lossless2 | 9x20 | leading-edge shade |
| 1975 | Lossless2 | 426x22 | bar frame |
| 1978/1979/1980 | DefineEditText | | status text |

Only two needed changing. The track was a near-white `#FBFBFB` strip — the one
bright element on an otherwise black screen — and is now a dark well. The fill
was already red (`#FF4043`) and was nudged onto the theme accent `#FF3823`. The
shade, frame and text were already correct.

```bat
set DARKUI_THEME=dark_ui_loader
python scripts\apply_dark_ui.py in.swf out.swf
```

`DARKUI_THEME` selects the image table the same way `DARKUI_CONSTS` selects the
literal table: `dark_ui_theme` for the Support/Viewer window art,
`dark_ui_loader` for the progress bar. Both passes are byte-neutral, so they
compose in any order.

## Alert / dialog chrome

The box behind every buy, install and trade-in confirmation, every error and the
disconnect notice. It was the most-seen light surface left once Support, Viewer,
Email, NIM and the loader were done.

It does not look like art from the sprite tree, which is why it was missed:
sprites reach children through `PlaceObject`, but `alertBox` (char 1785) reaches
its chrome through **shape fill styles**. It resolves to 13 nested `DefineShape`
leaves whose fills are type `0x41` (clipped bitmap), each carrying a bitmap
character id. Walking only `PlaceObject` children finds no images at all.

| char | kind | size | role |
|------|------|------|------|
| 126 | Lossless2 | 19x24 | small chrome bit |
| 925 | Lossless | 20x16 | small chrome bit |
| **941** | **DefineBits** | **428x256** | **the chrome: dark header + light grey body** |
| 949..966 | JPEG3 | 32-62px | alert icons (error, gear, shop, warning) |

Only 941 is retheme material. The icon set is deliberately untouched -- they are
the one piece of colour that tells the player which kind of dialog this is.

941 is a plain `DefineBits` sharing the global `JPEGTables`, the same case as
char 180 in the Support pass, so `apply_dark_ui.py` re-emits it as a
self-contained `DefineBitsJPEG2` -- only the tag *code* changes (6 -> 21), the
length is preserved.

```bat
set DARKUI_THEME=dark_ui_dialog
python scriptspply_dark_ui.py in.swf patches\main_client\main.dark-ui-dialog.swf
```

Result: **1 of 6,085 tags**, length preserved, 29,831,499 bytes, FWS.

The shipped `main.dark-ui-dialog.swf` also carries the `dark_ui_loader` pass
(chars 1967/1969), which the previously deployed build did **not** have -- the
loading screen still showed the near-white progress track. Both passes are
byte-neutral so they compose:

```bat
set DARKUI_THEME=dark_ui_dialog
python scriptspply_dark_ui.py in.swf stage1.swf
set DARKUI_THEME=dark_ui_loader
python scriptspply_dark_ui.py stage1.swf patches\main_client\main.dark-ui-dialog.swf
```

Combined: 3 tags over the previously deployed build, 21 against pristine stock.

### Contrast note

This one is safe from the black-on-black trap, and checking was not optional.
Every `DefineEditText` in `alertBox` (1785), `dialogAlert` (3005), `alertBuyPart`
(1053) and `alertBuyCar` (1745) already carries `#FFFFFF`, and none of
`AlertBox` / `BaseBox` / `DialogBox` contains a single `setTextFormat`, so
nothing overrides it at runtime. White on the old light-grey body was poor
contrast; on charcoal it is a readability improvement rather than just a
cosmetic one.

Bitmap 941 is filled by shapes 942, 3009, 3145 and 3222, so all dialog variants
pick up the same chrome and stay consistent.

### What is left after this

The colour-literal channel is close to exhausted. Ranking every class by light
literals and classifying each as text or fill:

| class | light literals | text | fill |
|-------|----------------|------|------|
| SectionTeamHQ | 14 | 14 | 0 |
| TrophyRoom | 6 | 6 | 0 |
| HomeProfile | 6 | 6 | 0 |
| HomeAccount / HomeTeamStatus / Remark / Badges | 1 each | 1 | 0 |
| DialogBox / BaseBox | 3 | 0 | 1 |

Every remaining light literal outside the themed classes is `tf.color` -- light
text already sitting on a dark surface. Darkening those *creates* the
black-on-black trap rather than avoiding it. The one fill pair is
`BaseBox.boxLine`, a 1px highlight above the dialog buttons.

So further theming is an art job, not a literal job. The next candidate is the
Leaderboards screen, still light cyan.

## Avatars vs NIM: why the two fixes collided

The “NIM fix” build (`patches/main_client/main.nim-fixed.swf`) is **CWS —
compressed**. Compression is exactly what breaks `FileReference.upload()`, so
that build fixes NIM and breaks avatar upload. The “avatar fix” build is FWS
but predates the NIM work. The two were never in conflict on their merits — it
was the container format.

The reconciliation is `main.nim-compact-fws-candidate.swf`: the compact NIM
rewrite emitted **uncompressed**, at 29,831,538 bytes, which fits the
29,832,751 allocation with 1,213 bytes to spare. Against the stock baseline it
differs in `classes.Console` only — every other class is byte-identical.

`main.dark-ui-nim.swf` is that build plus this theme:

```bat
python scripts\apply_dark_ui.py        main.nim-compact-fws-candidate.swf stage1.swf
python scripts\patch_as2_colors.py     stage1.swf stage2.swf
set DARKUI_CONSTS=dark_ui_consts_nim
python scripts\apply_dark_ui_consts.py stage2.swf patches\main_client\main.dark-ui-nim.swf
```

`DARKUI_CONSTS` picks the edit table: `dark_ui_consts` targets the stock
baseline, `dark_ui_consts_nim` targets the compact-NIM base (offsets shifted
+3,649, re-derived from a fresh P-code dump). The compact rewrite already
carries the dark NIM palette, so its Console table covers only the leftovers:
the two buddy-request info popups, still a white tab over a light gradient with
dark text. The `beginFill(0xFFFFFF, 0)` hit areas beside them are deliberately
left alone.

Result: 15 of 6,085 tags changed, all lengths preserved, 29,831,538 bytes, FWS.

**Never ship CWS.** It is tempting — it frees ~2.3 MB — and the client boots
fine, which is what makes the avatar regression so easy to miss: the rest of
the game's networking goes through Lingo rather than Flash, so only upload
breaks.

## Verifying a patch

Always diff at tag level; a good patch touches only the tags you named. The
current theme changes **15 of 6,085 tags** — 12 images plus the Drawing,
Console and Email bytecode tags — and leaves the file size identical:

```
changed tag codes: {(35,35): 10, (59,59): 3, (6,21): 1, (36,36): 1}
all lengths preserved: True
29,831,046 -> 29,831,046 bytes, FWS
```

The three stages run in order and each asserts its own size invariant:

```bat
python scripts\apply_dark_ui.py        source\main.swf  stage1.swf
python scripts\patch_as2_colors.py     stage1.swf       stage2.swf
python scripts\apply_dark_ui_consts.py stage2.swf       patches\main_client\main.dark-ui.swf
```

Also confirm the decompiled classes differ from the originals **only** in
literal values, never in structure:

```bat
ffdec-cli -format script:as -export script verify\ main.dark-ui.swf
REM then diff verify\scripts\__Packages\classes\{Drawing,Console,Email}.as
```

Render the result to check it before deploying:

```bat
ffdec-cli -selectid 254  -format sprite:png -export sprite out\ main.swf   REM Support Center
ffdec-cli -selectid 2374 -format sprite:png -export sprite out\ main.swf   REM Viewer
```

## Rebuilding byte-neutrally (and proving it)

On 2026-07-23 avatar upload broke again. VPS logs showed `uploadrequest`
arriving and registering, then no byte POST ever following — other players on
the shipped EXE uploaded successfully the same day, so the fault was local to
the build. A tag diff against pristine stock found 45 changed tag slots
including **11 recompiled `DoInitAction` tags**, a deleted `DefineShape` and a
1,252-byte shortfall padded out.

The theme passes were never the problem — they are byte-neutral by
construction. The problem was the **baseline** they were layered onto, which
already carried recompiles. Nothing in the pipeline checked that.

### The gate

`scripts/verify_byte_neutral.py <baseline.swf> <candidate.swf>` now decides it
mechanically. It rejects unless:

1. total size identical;
2. signature still `FWS` (never CWS);
3. tag count identical — nothing added or removed;
4. every tag length identical;
5. tag codes identical, except the documented `DefineBits -> DefineBitsJPEG2`
   re-emit, which preserves length;
6. code tags (`DoAction` / `DoInitAction` / `DoABC`) differ **only** in
   `ActionPush` int32/double operand bytes.

Rule 6 is the load-bearing one: a colour swap rewrites a literal operand in
place, a recompile moves opcodes. Comparing both bodies with every push operand
masked out makes the two decidable apart without a decompiler. `DoABC` is never
certified — it is AVM2, not an AS2 action stream.

Validated against known answers before use: it accepts `main.dark-ui-nim.swf`
over its `main.nim-compact-fws-candidate` baseline, and rejects the broken
`main.dark-ui-dialog.swf`.

### Porting the offset table to a new baseline

`dark_ui_consts.py` holds absolute offsets, so it only fits the exact build it
was derived from — on any other baseline `apply_dark_ui_consts.py` correctly
refuses to run. `scripts/port_consts_offsets.py <reference.swf> <target.swf>
<out.py>` re-derives it: each edit is really "the Nth `ActionPush` of value V
in class C", so it resolves that ordinal in the reference and finds the same
ordinal in the target. An entry is ported **only** when the value occurs the
same number of times in both classes; otherwise it is dropped with a warning
rather than guessed at.

### The rebuild

Baseline `main.pre-nim-redesign.swf` — the last full-allocation build, from the
window in which avatar upload was last observed working (Jul 20 23:23).

```bat
set DARKUI_THEME=dark_ui_theme
python scripts\apply_dark_ui.py  patches\main_client\main.pre-nim-redesign.swf s1.swf
set DARKUI_THEME=dark_ui_dialog
python scripts\apply_dark_ui.py  s1.swf s2.swf
set DARKUI_THEME=dark_ui_loader
python scripts\apply_dark_ui.py  s2.swf s3.swf
python scripts\patch_as2_colors.py s3.swf s4.swf
python scripts\port_consts_offsets.py reference_preconsts.swf s4.swf scripts\dark_ui_consts_prenim.py
set DARKUI_CONSTS=dark_ui_consts_prenim
python scripts\apply_dark_ui_consts.py s4.swf patches\main_client\main.dark-ui-prenim.swf
python scripts\verify_byte_neutral.py patches\main_client\main.pre-nim-redesign.swf patches\main_client\main.dark-ui-prenim.swf
```

`reference_preconsts.swf` is `main.dark-ui.swf` with all 50 const edits written
back to their `old` values — all 50 reversed cleanly, which is what confirms
that file is the lineage the shipped offset table came from.

Result — **20 of 6,086 tags**, 29,832,751 bytes (the full allocation, zero
padding), FWS, and no recompiled code:

```
15 visual tag(s) changed
 3 code tag(s) changed in push literals only
 2 DefineBits -> DefineBitsJPEG2 re-emit(s)
```

Spliced into the pristine projector shell, which is byte-identical outside the
SWF region across every build checked, giving exactly 34,627,563 bytes. The SWF
extracted back out of the finished EXE re-runs the gate to the same sha256.

**Run the gate on every build before it ships.** The regression it catches boots
fine and only shows up when a player tries to change their avatar.
