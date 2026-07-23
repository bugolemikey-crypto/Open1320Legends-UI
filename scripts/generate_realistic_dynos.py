#!/usr/bin/env python3
"""Generate believable dyno-shaped torque curves for dealer car seed JSON.

The input seed already contains catalog horsepower, torque, RPM metadata, and
often a generated fallback torqueCurve. This script replaces fallback-style
curves with deterministic engine-family templates that look more like real
dyno pulls while preserving the seed's 101-point, 100-RPM curve format.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any


SAMPLES = 101
RPM_STEP = 100
TODAY = "2026-07-16"


@dataclass(frozen=True)
class Template:
    key: str
    label: str
    torque_peak_fraction: float
    idle_factor: float
    low_factor: float
    mid_factor: float
    redline_factor: float
    ripple: float
    spooly: bool = False
    plateau: bool = False


TEMPLATES: dict[str, Template] = {
    "high_rev_na": Template(
        "high_rev_na",
        "high-rev naturally aspirated four-cylinder/VTEC shape",
        0.72,
        0.34,
        0.47,
        0.76,
        0.88,
        0.012,
    ),
    "rotary": Template(
        "rotary",
        "naturally aspirated/turbo rotary shape with soft low-end and strong top-end",
        0.68,
        0.25,
        0.38,
        0.72,
        0.90,
        0.014,
    ),
    "turbo": Template(
        "turbo",
        "turbocharged street-car spool and midrange plateau shape",
        0.50,
        0.32,
        0.42,
        0.86,
        0.74,
        0.016,
        spooly=True,
        plateau=True,
    ),
    "supercharged": Template(
        "supercharged",
        "positive-displacement/screw supercharged broad torque shape",
        0.48,
        0.50,
        0.72,
        0.94,
        0.80,
        0.010,
        plateau=True,
    ),
    "modern_na_v8": Template(
        "modern_na_v8",
        "modern naturally aspirated V8 broad torque curve",
        0.62,
        0.43,
        0.64,
        0.88,
        0.78,
        0.011,
    ),
    "muscle_bigblock": Template(
        "muscle_bigblock",
        "classic muscle/big-block early torque shelf",
        0.42,
        0.54,
        0.82,
        0.96,
        0.62,
        0.012,
    ),
    "truck_torque": Template(
        "truck_torque",
        "truck/utility V8 low-rpm torque curve",
        0.38,
        0.58,
        0.88,
        0.94,
        0.58,
        0.010,
    ),
    "exotic": Template(
        "exotic",
        "exotic high-output V10/V12/V8 top-end power curve",
        0.70,
        0.36,
        0.54,
        0.80,
        0.88,
        0.010,
    ),
    "six_na": Template(
        "six_na",
        "naturally aspirated six-cylinder smooth rising torque curve",
        0.60,
        0.38,
        0.58,
        0.85,
        0.78,
        0.010,
    ),
    "compact_na": Template(
        "compact_na",
        "small-displacement naturally aspirated street curve",
        0.64,
        0.34,
        0.52,
        0.82,
        0.74,
        0.012,
    ),
    "drag_forced": Template(
        "drag_forced",
        "high-output drag/limited forced-induction plateau curve",
        0.55,
        0.28,
        0.40,
        0.90,
        0.82,
        0.014,
        spooly=True,
        plateau=True,
    ),
}


def smoothstep(t: float) -> float:
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def interp(points: list[tuple[float, float]], rpm: float) -> float:
    points = sorted(points)
    if rpm <= points[0][0]:
        return points[0][1]
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        if rpm <= x1:
            if x1 == x0:
                return y1
            t = smoothstep((rpm - x0) / (x1 - x0))
            return y0 + (y1 - y0) * t
    return points[-1][1]


def text_for(car: dict[str, Any]) -> str:
    fields = [
        "name",
        "brandCategoryName",
        "engineFamily",
        "engineCode",
        "stockEngine",
        "stockEngineCode",
        "inductionSystem",
        "carType",
        "torqueCurveSource",
    ]
    return " ".join(str(car.get(field, "")) for field in fields).lower()


def source_is_reference(source: str) -> bool:
    return source.startswith("digitized reference shape") or source.startswith(
        "LS7 source-backed anchors"
    )


def select_template(car: dict[str, Any]) -> Template:
    text = text_for(car)
    name = str(car.get("name", "")).lower()

    if any(token in text for token in ["drag spec", "drag-spec", "trophy", "black fox"]):
        return TEMPLATES["drag_forced"]
    if any(token in text for token in ["rotary", "13b", "20b", "renesis", "rx-7", "rx-8", "rx-3"]):
        return TEMPLATES["rotary"]
    if any(token in text for token in ["supercharged", " supercharger", " sc ", "ls9", "zr1"]):
        return TEMPLATES["supercharged"]
    if any(token in text for token in ["turbo", "twin turbo", "twin-turbo", "tc", "gtr", "gt-r", "evo", "srt-4", "gnx"]):
        return TEMPLATES["turbo"]
    if any(token in text for token in ["vtec", "b18", "b16", "k20", "f20c", "f22c", "s2000", "civic", "integra", "rsx", "prelude"]):
        return TEMPLATES["high_rev_na"]
    if any(token in text for token in ["426", "440", "460", "455", "400 v8", "big block", "hemi", "judge", "cuda", "road runner", "grand torino"]):
        return TEMPLATES["muscle_bigblock"]
    if any(token in name for token in ["f-150", "ram", "c-10", "s-10"]):
        return TEMPLATES["truck_torque"]
    if any(token in text for token in ["v12", "v10", "ferrari", "lamborghini", "viper", "ford gt", "furai"]):
        return TEMPLATES["exotic"]
    if "v8" in text or any(token in text for token in ["ls1", "ls2", "ls3", "ls7", "coyote", "mustang", "camaro", "corvette", "gto"]):
        return TEMPLATES["modern_na_v8"]
    if any(token in text for token in ["v6", "i6", "vr6", "vq", "jz", "rb26", "skyline", "supra", "350z", "370z", "g35", "g37"]):
        return TEMPLATES["six_na"]
    return TEMPLATES["compact_na"]


def number(value: Any, fallback: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return fallback


def torque_peak_rpm(car: dict[str, Any], template: Template, redline: float) -> float:
    source = str(car.get("torqueCurveSource", ""))
    for pattern in (r"torque RPM (\d+)", r"lb-ft @ (\d+) RPM", r"lb-ft @(\d+)"):
        match = re.search(pattern, source, flags=re.IGNORECASE)
        if match:
            return float(match.group(1))

    peak = redline * template.torque_peak_fraction
    if template.spooly:
        full_boost = number(car.get("fullBoostRpm"))
        if full_boost > 0:
            peak = max(peak, full_boost)
    return peak


def sane_rpms(car: dict[str, Any], template: Template) -> tuple[float, float, float]:
    peak_rpm = number(car.get("peakRpm"))
    redline = number(car.get("redlineRpm"))
    limiter = number(car.get("revLimiterRpm"))

    if redline <= 0:
        if peak_rpm > 0:
            redline = peak_rpm * 1.08
        elif template in (TEMPLATES["muscle_bigblock"], TEMPLATES["truck_torque"]):
            redline = 5200.0
        else:
            redline = 7000.0
    if peak_rpm <= 0:
        peak_rpm = redline * 0.88
    if limiter <= 0:
        limiter = redline + 250.0

    peak_rpm = max(1200.0, min(peak_rpm, 9800.0))
    redline = max(peak_rpm, min(redline, 10000.0))
    limiter = max(redline, min(limiter, 10000.0))
    return peak_rpm, redline, limiter


def build_anchor_points(car: dict[str, Any], template: Template) -> tuple[list[tuple[float, float]], str]:
    hp = max(1.0, number(car.get("horsepower")))
    catalog_tq = max(1.0, number(car.get("torque")))
    peak_rpm, redline, limiter = sane_rpms(car, template)
    tq_peak_rpm = max(900.0, min(torque_peak_rpm(car, template, redline), redline * 0.96))
    hp_tq = hp * 5252.0 / peak_rpm
    effective_tq = max(catalog_tq, hp_tq * 1.015)

    if template.spooly:
        spool_start = number(car.get("spoolStartRpm"), max(1300.0, tq_peak_rpm - 1700.0))
        full_boost = number(car.get("fullBoostRpm"), tq_peak_rpm)
        spool_start = max(800.0, min(spool_start, tq_peak_rpm - 200.0))
        full_boost = max(spool_start + 250.0, min(full_boost, tq_peak_rpm + 500.0, redline * 0.90))
        points = [
            (0.0, 0.0),
            (400.0, effective_tq * template.idle_factor),
            (spool_start, effective_tq * template.low_factor),
            (full_boost, effective_tq * template.mid_factor),
            (tq_peak_rpm, effective_tq),
        ]
    else:
        points = [
            (0.0, 0.0),
            (400.0, effective_tq * template.idle_factor),
            (max(900.0, tq_peak_rpm * 0.45), effective_tq * template.low_factor),
            (max(1200.0, tq_peak_rpm * 0.75), effective_tq * template.mid_factor),
            (tq_peak_rpm, effective_tq),
        ]

    if template.plateau:
        plateau_end = min(redline * 0.76, max(tq_peak_rpm + 600.0, peak_rpm * 0.88))
        points.append((plateau_end, min(effective_tq * 0.97, max(hp_tq, effective_tq * 0.82))))

    points.extend(
        [
            (peak_rpm, hp_tq),
            (redline, max(0.0, hp_tq * template.redline_factor)),
            (limiter, max(0.0, hp_tq * template.redline_factor * 0.45)),
            (min(10000.0, limiter + 600.0), 0.0),
            (10000.0, 0.0),
        ]
    )

    unique: dict[float, float] = {}
    for rpm, tq in points:
        unique[max(0.0, min(10000.0, rpm))] = max(0.0, tq)
    note = (
        f"{template.label}; target {hp:g} HP @ {peak_rpm:.0f} RPM and "
        f"{catalog_tq:g} lb-ft"
    )
    return sorted(unique.items()), note


def deterministic_ripple(car_id: int, rpm: float, amount: float) -> float:
    if rpm <= 600.0 or rpm >= 9800.0:
        return 1.0
    phase = (car_id % 23) * 0.37
    wave = math.sin(rpm / 470.0 + phase) + 0.45 * math.sin(rpm / 910.0 + phase * 0.7)
    return 1.0 + amount * wave / 1.45


def generate_curve(car: dict[str, Any], template: Template) -> tuple[list[float], str]:
    points, note = build_anchor_points(car, template)
    car_id = int(number(car.get("id")))
    hp = max(1.0, number(car.get("horsepower")))
    peak_rpm, _redline, _limiter = sane_rpms(car, template)
    curve: list[float] = []
    for idx in range(SAMPLES):
        rpm = idx * RPM_STEP
        tq = interp(points, rpm)
        tq *= deterministic_ripple(car_id, rpm, template.ripple)
        if rpm >= peak_rpm and rpm > 0:
            tq = min(tq, hp * 5252.0 / rpm * 1.005)
        curve.append(round(max(0.0, tq), 1))

    return curve, note


def dyno_from_curve(curve: list[float]) -> list[dict[str, float]]:
    dyno = []
    for rpm in range(400, 10001, 400):
        idx = min(len(curve) - 1, rpm // RPM_STEP)
        tq = float(curve[idx])
        dyno.append(
            {
                "rpm": rpm,
                "torque": round(tq, 2),
                "horsepower": round(tq * rpm / 5252.0, 2),
            }
        )
    return dyno


def update_car(car: dict[str, Any], force: bool) -> tuple[str, str]:
    source = str(car.get("torqueCurveSource", ""))
    if source_is_reference(source) and not force:
        if len(car.get("dynoCurve", [])) != 25 and len(car.get("torqueCurve", [])) == SAMPLES:
            car["dynoCurve"] = dyno_from_curve(car["torqueCurve"])
            return "dyno-only", "source_backed"
        return "preserved", "source_backed"

    template = select_template(car)
    peak_rpm, redline, limiter = sane_rpms(car, template)
    if number(car.get("peakRpm")) <= 0:
        car["peakRpm"] = int(round(peak_rpm))
    if number(car.get("redlineRpm")) <= 0:
        car["redlineRpm"] = int(round(redline))
    if number(car.get("revLimiterRpm")) <= 0:
        car["revLimiterRpm"] = int(round(limiter))

    curve, note = generate_curve(car, template)
    car["torqueCurve"] = curve
    car["dynoCurve"] = dyno_from_curve(curve)
    car["torqueCurveSource"] = (
        f"realistic template {TODAY}: {note}. "
        "Generated from engine-family dyno behavior, not an exact captured dyno trace."
    )
    car["torqueCurveTemplate"] = template.key
    return "changed", template.key


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="dealer-car-canonical.seed.json or pasted JSON")
    parser.add_argument("output", type=Path, help="where to write the updated JSON")
    parser.add_argument(
        "--force",
        action="store_true",
        help="regenerate even records with source-backed/digitized curve notes",
    )
    args = parser.parse_args()

    data = json.loads(args.input.read_text(encoding="utf-8"))
    cars = data.get("dealerCars", [])
    changed = 0
    dyno_only = 0
    preserved = 0
    template_counts: dict[str, int] = {}
    for car in cars:
        status, reason = update_car(car, args.force)
        if status == "changed":
            changed += 1
            template_counts[reason] = template_counts.get(reason, 0) + 1
        elif status == "dyno-only":
            dyno_only += 1
            preserved += 1
        else:
            preserved += 1

    summary = data.setdefault("summary", {})
    summary["dealerCarCount"] = len(cars)
    summary["realisticDynoGeneratedAt"] = TODAY
    summary["realisticDynoChangedCount"] = changed
    summary["realisticDynoSummaryOnlyCount"] = dyno_only
    summary["realisticDynoTemplateCounts"] = dict(sorted(template_counts.items()))
    summary["realisticDynoPreservedSourceBackedCount"] = preserved

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {args.output}")
    print(f"cars: {len(cars)}")
    print(f"changed: {changed}")
    print(f"dyno-only: {dyno_only}")
    print(f"preserved: {preserved}")
    for key, count in sorted(template_counts.items()):
        print(f"{key}: {count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
