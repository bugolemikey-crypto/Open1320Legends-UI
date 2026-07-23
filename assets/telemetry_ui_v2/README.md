# Telemetry UI v2 element pack

Source concept: `../login/login_telemetry_exact_cars_v2.png`

The `elements/` folder contains full-resolution PNGs plus a `stage_800/`
subfolder scaled to the game's 800-pixel stage. `manifest.json` records each
source crop and output size.

## Assembly layers

- `00_logo_repository_original.png` — unmodified repository logo
- `01_header_complete.png` — assembled in-game header
- `02_header_logo_from_concept.png` — header logo as shown in the concept
- `03_support_control.png` — Support control
- `04_car_hero_complete.png` — three-car garage hero
- `05_login_console_complete.png` — assembled login console
- `06_console_left_section.png` — Discord section
- `07_console_center_section.png` — Create Account section
- `08_console_right_section.png` — credential/login section
- `09_button_discord.png` — Discord action
- `10_button_create_account.png` — Create Account action
- `11_button_login.png` — Login action
- `12_field_racer_name.png` — racer-name field treatment
- `13_field_password.png` — password field treatment
- `14_console_divider_left.png` — left console divider
- `15_console_divider_right.png` — right console divider
- `16_red_edge_trim.png` — long illuminated trim
- `17_panel_texture_sample.png` — reusable obsidian texture sample
- `18_header_shell_blank.png` — empty header shell
- `19_console_shell_blank.png` — empty console shell
- `20_car_left_alpha.png` — left car visible-silhouette layer
- `21_car_center_alpha.png` — center car visible-silhouette layer
- `22_car_right_alpha.png` — right car visible-silhouette layer

Each car layer has a matching `_mask.png` file. Because the cars overlap in
the approved composition, the alpha files contain the visible portion of each
car, not invented pixels for the hidden areas.

Rebuild the pack with:

```bat
python scripts\extract_telemetry_ui_elements.py
```
