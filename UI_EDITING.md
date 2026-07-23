# UI editor workflow

The project now includes `scripts/ui_editor.py`. It edits the actual FFDec SWF structure instead of placing a large image into the old login panel.

## Coordinate system

The game `main.swf` stage is **800x600 pixels**. The tool accepts stage pixels and converts them to SWF twips automatically. Do not use the source PNG's 1570x958 coordinates directly.

The supplied design has a different aspect ratio from 800x600. The deployable builder preserves the complete design, centers it at 800x488, and extends the background above and below without stretching the controls. The prepared 800x600 stage is then placed into the true 850x650 bitmap window used by character 1925.

For general-purpose previews, `ui_editor.py` also supports:

- `cover` fills 800x600 and crops the sides.
- `contain` preserves the entire image and adds bars.
- `stretch` fills the stage but distorts the aspect ratio.

## Inspect the SWF

```bat
python scripts\ui_editor.py inspect --swf source\main.swf --sprite-id 2002
```

This lists named login instances such as `fldUsername`, `fldPass`, `btnStart`, `btnCreateAccount`, and `btnFBConnect`.

## Build the supplied design for deployment

1. Close the game.
2. Put the full design image at `assets/login/login_screen_bg.png`.
3. Adjust named-control positions in `ui_layout.json` if necessary.
4. Run:

```bat
python scripts\build_deployable_login.py
```

This command:

1. Composes the complete design into the actual 800x600 stage without stretching it.
2. Places that stage into the 850x650 bitmap window used by character 1925.
3. Crops and compresses the three button images to their exact SWF dimensions.
4. Uses FFDec XML only to produce a layout donor.
5. Splices only characters 1935, 1936, 1962, 1963, 2002, and 2094 into the untouched source SWF.
6. Replaces bitmap characters 1925, 1945, 1948, and 1953 directly through FFDec.
7. Preserves the Discord string patch.
8. Pads the result to exactly 29,832,751 bytes.

The fixed-size splicer is required because deploying FFDec's complete XML rebuild would exceed the EXE's embedded SWF allocation.

## Editing layout

`ui_layout.json` contains three kinds of edits:

```json
{
  "text_fields": {
    "1962": {"x": 575, "y": 330, "width": 205, "height": 24, "fontHeight": 14, "color": [245, 245, 245]}
  },
  "sprites": [{
    "sprite_id": 2002,
    "hide_characters": [1930],
    "instances": {
      "fldUsername": {"x": 575, "y": 330},
      "btnStart": {"x": 570, "y": 410, "scaleX": 2.23, "scaleY": 1.65}
    }
  }]
}
```

- `instances` targets named `PlaceObject2Tag` objects and changes their stage position and scale.
- `hide_characters` makes unnamed decorative placements transparent without deleting code or named interactive objects.
- `text_fields` edits the actual `DefineEditTextTag` bounds, font height, and color.
- `replacements` uses FFDec image replacement syntax: `characterId=path`.

## Replacing other images

Any image character can be replaced from the command line:

```bat
python scripts\ui_editor.py apply --swf source\main.swf --output patches\main_client\main.swf --layout ui_layout.json --background assets\login\login_screen_bg.png --replace 1407=assets\home\garage.png --pad
```

Find character IDs by exporting images with FFDec or by inspecting the SWF:

```bat
python scripts\export_targets.py --target main_client
```

The numeric filename is normally the FFDec character ID. For button art, replace the bitmap character, not the `DefineButton2` wrapper: login uses bitmap IDs 1945, 1948, and 1953 while the interactive wrappers are 1947, 1950, and 1955.

## Main game screens

The same editor works for the rest of `main.swf`: add replacements for image character IDs, add named instances to the relevant sprite, and use `text_fields` for edit text definitions. Use `inspect --sprite-id N` to discover a sprite's named instances. Keep a separate layout JSON per screen so login changes do not affect the home/HUD layout.

## Deploy

After validating the patch:

```bat
python scripts\deploy_patches.py --target main_client
```

The deploy script checks the exact embedded SWF byte size and creates an EXE backup. Always keep the game closed during deployment.

## Registration form SWF

`cache/misc/newuserform.swf` is the separate Create Account/registration interface. It is not the legacy login panel shown over the background; that panel is sprite 2002 inside `main.swf`. The deployable login builder therefore leaves `newuserform.swf` unchanged so registration remains functional.

Use `login_form_layout.json` and `ui_editor.py` only when intentionally redesigning the registration flow as a separate screen.
