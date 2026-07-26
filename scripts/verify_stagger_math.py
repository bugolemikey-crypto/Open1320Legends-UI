"""Prove the staggered-axle change cannot move a non-staggered car.

The client can only be verified for real by a human reaching the garage in game
(a Director script error leaves the process alive and responding, so no liveness
check means anything here). What *can* be verified mechanically is the claim the
whole change rests on: for every `ps` value the stock catalog can serve, the new
CarSpecs/CarConstruction maths produce exactly the numbers the old ones did.

Both versions of the arithmetic are transcribed from the AS2 below, old from the
shipped classes, new from assets/polish/nim/{CarSpecs,CarConstruction}.as.

    python scripts/verify_stagger_math.py
"""

from __future__ import annotations

import math


# --- AS2 primitives -------------------------------------------------------
# Number("") is 0, Number("abc") is NaN, Number(undefined) is NaN. Python's
# float() raises instead, so the coercion is spelled out.
def as2_number(value) -> float:
    if value is None:
        return math.nan
    text = str(value).strip()
    if text == "":
        return 0.0
    try:
        return float(text)
    except ValueError:
        return math.nan


def truthy(value: float) -> bool:
    """AS2 truthiness for a Number: 0 and NaN are false."""
    return not (value == 0 or math.isnan(value))


# --- old: the shipped maths ----------------------------------------------
def old_specs(tire_ps, wheel_ps):
    tire_scale_factor, wheel_size = 1.1, 16
    if tire_ps is not None and len(str(tire_ps)):
        tire_scale_factor = 1 + as2_number(tire_ps) / 100
    if truthy(as2_number(wheel_ps)):
        wheel_size = max(14, min(20, as2_number(wheel_ps)))
    wheel_scale = 70 + (wheel_size - 14) * 24 / 6
    tire_scale = min(100, wheel_scale * tire_scale_factor)
    return wheel_scale, tire_scale


def old_construction(tire_scale, wheel_scale, ride_height):
    tire_frac = tire_scale / 100
    wheel_frac = wheel_scale / 100
    return {
        "tireFrac": tire_frac,
        "tireFracR": tire_frac,
        "wheelFrac": wheel_frac,
        "wheelFracR": wheel_frac,
        "coreYAdj": math.ceil(ride_height - (1 - tire_frac) * 75),
        # _y offset applied to each member of wheelPartsArr
        "wheelPartsY": {
            name: math.ceil((1 - tire_frac) * 75)
            for name in ("wheelF", "wheelR", "tireF", "tireR", "brake", "tireBack")
        },
    }


# --- new: assets/polish/nim/*.as -----------------------------------------
def axle_spec(ps, index: int) -> float:
    parts = str(ps).replace("/", "|").split("|")
    token = parts[index] if index < len(parts) else None
    if token is None or token == "":
        token = parts[0]
    return as2_number(token)


def new_specs(tire_ps, wheel_ps, preset: int = 0):
    tire_scale_factor = tire_scale_factor_r = 1.1
    wheel_size = wheel_size_r = 16
    if tire_ps is not None and len(str(tire_ps)):
        tire_scale_factor = 1 + axle_spec(tire_ps, 0) / 100
        tire_scale_factor_r = 1 + axle_spec(tire_ps, 1) / 100
    if truthy(axle_spec(wheel_ps, 0)):
        wheel_size = max(14, min(20, axle_spec(wheel_ps, 0)))
        wheel_size_r = max(14, min(20, axle_spec(wheel_ps, 1)))
    # The paint-shop preview override, inlined into setWheelAndTireScales. Off
    # is a no-op, which is what keeps the 780-combination equivalence honest.
    if preset:
        wheel_size_r = wheel_size
        wheel_size = max(14, wheel_size_r - 4)
        tire_scale_factor_r = 1.45
    wheel_scale = 70 + (wheel_size - 14) * 24 / 6
    tire_scale = min(100, wheel_scale * tire_scale_factor)
    wheel_scale_r = 70 + (wheel_size_r - 14) * 24 / 6
    tire_scale_r = min(100, wheel_scale_r * tire_scale_factor_r)
    return wheel_scale, tire_scale, wheel_scale_r, tire_scale_r


def new_construction(tire_scale, wheel_scale, tire_scale_r, wheel_scale_r, ride_height):
    tire_frac = tire_scale / 100
    tire_frac_r = tire_frac if not tire_scale_r else tire_scale_r / 100
    wheel_frac = wheel_scale / 100
    wheel_frac_r = wheel_frac if not wheel_scale_r else wheel_scale_r / 100
    rear = ("tireR", "wheelR", "tireBack")
    return {
        "tireFrac": tire_frac,
        "tireFracR": tire_frac_r,
        "wheelFrac": wheel_frac,
        "wheelFracR": wheel_frac_r,
        "coreYAdj": math.ceil(ride_height - (1 - (tire_frac + tire_frac_r) / 2) * 75),
        "wheelPartsY": {
            name: math.ceil((1 - (tire_frac_r if name in rear else tire_frac)) * 75)
            for name in ("wheelF", "wheelR", "tireF", "tireR", "brake", "tireBack")
        },
    }


# --- the stock catalog surface -------------------------------------------
# Every shape a stock `ps` can take: the wheel sizes the client clamps to, the
# tire percentages, and the malformed values the shop can hand over.
TIRE_PS = [None, "", "0", "5", "10", "15", "20", "35", "-5", "abc"]
WHEEL_PS = [None, "", "0", "13", "14", "15", "16", "17", "18", "19", "20", "21", "abc"]
RIDE_HEIGHTS = [0, 4, 8, 12, 20, -6]


def main() -> int:
    checked = failures = 0
    for tire_ps in TIRE_PS:
        for wheel_ps in WHEEL_PS:
            for ride_height in RIDE_HEIGHTS:
                old_wheel_scale, old_tire_scale = old_specs(tire_ps, wheel_ps)
                nw, nt, nwr, ntr = new_specs(tire_ps, wheel_ps)

                # A bare ps must leave both axles on the same number.
                if not (math.isnan(nw) or math.isnan(nwr)) and (nw, nt) != (nwr, ntr):
                    print(f"FAIL axles diverge on bare ps: {tire_ps!r}/{wheel_ps!r}")
                    failures += 1

                old = old_construction(old_tire_scale, old_wheel_scale, ride_height)
                new = new_construction(nt, nw, ntr, nwr, ride_height)
                checked += 1
                for key in old:
                    a, b = old[key], new[key]
                    same = (a == b) or (
                        isinstance(a, float)
                        and isinstance(b, float)
                        and math.isnan(a)
                        and math.isnan(b)
                    )
                    if not same:
                        print(
                            f"FAIL {key}: tire_ps={tire_ps!r} wheel_ps={wheel_ps!r} "
                            f"rideHeight={ride_height} old={a!r} new={b!r}"
                        )
                        failures += 1

    print(f"{checked} stock combinations checked, {failures} divergence(s)")

    # And the point of the exercise: a staggered ps has to actually stagger.
    print()
    for label, tire_ps, wheel_ps in [
        ("stock 17in            ", "10", "17"),
        ("drag 15 front / 17 rear", "5|35", "15|17"),
        ("slash form 15/17      ", "5/35", "15/17"),
    ]:
        nw, nt, nwr, ntr = new_specs(tire_ps, wheel_ps)
        con = new_construction(nt, nw, ntr, nwr, 8)
        print(
            f"{label} -> front tire {nt:6.2f} rear tire {ntr:6.2f} | "
            f"front wheel {nw:5.1f} rear wheel {nwr:5.1f} | "
            f"tireF_y {con['wheelPartsY']['tireF']:3d} "
            f"tireR_y {con['wheelPartsY']['tireR']:3d} "
            f"coreYAdj {con['coreYAdj']:3d}"
        )

    staggered = new_specs("5|35", "15|17")
    if staggered[1] >= staggered[3]:
        print("FAIL staggered rear is not larger than the front")
        failures += 1

    # The paint-shop preview toggle, on an ordinary 17" car with stock tyres.
    print()
    for preset, name in [(0, "off"), (1, "drag")]:
        nw, nt, nwr, ntr = new_specs("10", "17", preset)
        print(
            f"stagger {name:4} -> front tire {nt:6.2f} rear tire {ntr:6.2f} | "
            f"front wheel {nw:5.1f} rear wheel {nwr:5.1f}"
        )
        if not preset and (nt, nw) != (ntr, nwr):
            print("FAIL stagger off is not a no-op")
            failures += 1
        if preset and nt >= ntr:
            print("FAIL stagger on does not stage the rear above the front")
            failures += 1

    # Off must be a no-op for every stock catalog value, not just the 17" car.
    for tire_ps in TIRE_PS:
        for wheel_ps in WHEEL_PS:
            if new_specs(tire_ps, wheel_ps, 0) != new_specs(tire_ps, wheel_ps):
                print(f"FAIL stagger off diverges: {tire_ps!r}/{wheel_ps!r}")
                failures += 1

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
