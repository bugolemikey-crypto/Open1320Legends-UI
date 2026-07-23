// 2-step launch control -- cache/misc/lc.swf
//
// Loaded by classes.RaceControls.showLaunchControl() into the (previously
// empty) `launchControl` clip, which racePlay/frame_20 only makes visible when
// Race.hasLaunchControl() finds an installed part in slot 166. So this code
// only ever runs for a car that owns the part.
//
// How the limiter works: the engine sim lives in Lingo, not Flash -- RPM is
// computed there and pushed back through _root.runEngineCB(). Flash owns the
// other direction, _root.runEngine(throttlePercent). So a 2-step is simply
// throttle cut: while staged and pre-green, hold throttle at 0 whenever RPM is
// at or above the target, and let it back in as revs fall away. That is what a
// real 2-step does, and it needs no Lingo change at all.
//
// Both bridge functions are wrapped rather than replaced, so anything else
// hooking them keeps working.

var lc = this;
var host = _root;

if (_global.lcT == undefined) {
    _global.lcT = 0;      // target rpm, 0 = derive from redline
    _global.lcRPM = 0;    // last rpm seen from the sim
    _global.lcCut = false;
    _global.lcHooked = false;
}

function lcRedline() {
    var r = Number(lc._parent.rpmRedLine);
    if (r > 1000) {
        return r;
    }
    return 8500;
}

// Default to 62% of redline, rounded to 250 -- a sane launch point for most
// of the catalog. Clamped to 30%-85% so it can never be set somewhere the
// engine cannot actually hold.
function lcTarget() {
    if (_global.lcT > 0) {
        return _global.lcT;
    }
    return Math.round(lcRedline() * 0.62 / 250) * 250;
}

function lcClamp(v) {
    var lo = Math.round(lcRedline() * 0.30);
    var hi = Math.round(lcRedline() * 0.85);
    if (v < lo) { return lo; }
    if (v > hi) { return hi; }
    return v;
}

// ---------------------------------------------------------------- pops/bangs

var lcSnd = new Sound(lc);
var lcSndReady = false;
lcSnd.onLoad = function (ok) {
    lcSndReady = ok;
};
// Same convention the rev sounds use (cache/sounds/<name>.mp3, loadSound),
// so the asset ships through the cache manifest like everything else.
lcSnd.loadSound("cache/sounds/2step.mp3", false);

function lcBang() {
    if (lcSndReady) {
        lcSnd.stop();
        lcSnd.start(0, 0);
    }
    lcFlash();
}

// Muzzle-flash on the widget: a quick orange bloom that decays over a few
// frames. Cheap, and readable at 45x27.
function lcFlash() {
    var f = lc.flash;
    if (!f) {
        f = lc.createEmptyMovieClip("flash", 90);
    }
    f.clear();
    f.beginFill(0xFF7A18, 100);
    f.moveTo(0, 0);
    f.lineTo(46, 0);
    f.lineTo(46, 28);
    f.lineTo(0, 28);
    f.endFill();
    f._alpha = 70;
    f.onEnterFrame = function () {
        this._alpha -= 18;
        if (this._alpha <= 0) {
            this._alpha = 0;
            delete this.onEnterFrame;
        }
    };
}

// -------------------------------------------------------------------- widget

var lcFace = lc.createEmptyMovieClip("face", 10);
lcFace.beginFill(0x14171A, 100);
lcFace.moveTo(0, 0);
lcFace.lineTo(46, 0);
lcFace.lineTo(46, 28);
lcFace.lineTo(0, 28);
lcFace.endFill();

lc.createTextField("lbl", 20, 1, -1, 44, 12);
var lcFmtA = new TextFormat();
lcFmtA.font = "Arial";
lcFmtA.size = 8;
lcFmtA.color = 0x98A2AE;
lcFmtA.align = "center";
lc.lbl.selectable = false;
lc.lbl.setNewTextFormat(lcFmtA);
lc.lbl.text = "2-STEP";

lc.createTextField("val", 21, 1, 10, 44, 16);
var lcFmtB = new TextFormat();
lcFmtB.font = "Arial";
lcFmtB.size = 11;
lcFmtB.bold = true;
lcFmtB.color = 0xFF3823;
lcFmtB.align = "center";
lc.val.selectable = false;
lc.val.setNewTextFormat(lcFmtB);

function lcDraw() {
    lc.val.text = String(lcTarget());
}
lcDraw();

// Top half raises the launch rpm, bottom half lowers it, 250 at a time.
var lcHit = lc.createEmptyMovieClip("hit", 80);
lcHit.beginFill(0x000000, 0);
lcHit.moveTo(0, 0);
lcHit.lineTo(46, 0);
lcHit.lineTo(46, 28);
lcHit.lineTo(0, 28);
lcHit.endFill();
lcHit.onPress = function () {
    var step = this._ymouse < 14 ? 250 : -250;
    _global.lcT = lcClamp(lcTarget() + step);
    lcDraw();
};

// ------------------------------------------------------------- the limiter

if (!_global.lcHooked) {
    _global.lcHooked = true;

    var lcOrigRun = host.runEngine;
    var lcOrigCB = host.runEngineCB;

    host.runEngineCB = function (rpm, mph, d, boostPSI, timeIndex) {
        _global.lcRPM = Number(rpm);
        lcOrigCB.call(host, rpm, mph, d, boostPSI, timeIndex);
    };

    host.runEngine = function (throttlePercent) {
        var p = _global.classes.RacePlay._MC;
        var t = throttlePercent;
        // Only while staged and before the green -- never once rolling.
        if (p.isStaged && !p.raceStarted) {
            var tgt = lcTarget();
            if (_global.lcRPM >= tgt) {
                if (!_global.lcCut) {
                    _global.lcCut = true;
                    lcBang();
                }
                t = 0;
            } else if (_global.lcCut && _global.lcRPM < tgt - 250) {
                // Back under the limiter: let it light again. The gap is what
                // makes it stutter instead of chattering every single frame.
                _global.lcCut = false;
            }
        } else if (_global.lcCut) {
            _global.lcCut = false;
        }
        lcOrigRun.call(host, t);
    };
}

stop();
