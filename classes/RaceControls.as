class classes.RaceControls extends MovieClip
{
   var _mc;
   var boostGauge;
   var damageLight;
   var gaugeCluster;
   var gearCluster;
   var hasShiftLight;
   var launchControl;
   var nosGauge;
   var onEnterFrame;
   var pedalCluster;
   var tractionIcon;
   static var _mcHolder;
   var rpmRedLine = 7000;
   var boostNeedleMin = 135;
   var boostNeedleMax = 405;
   var boostMaxPSI = 40;
   var nosNeedleMin = 135;
   var nosNeedleMax = 405;
   var nosOn = 0;
   var shiftLightRPM = 12000;
   var controlsID = 1;
   var clutchEngaged = 0;
   function RaceControls()
   {
      super();
      classes.RaceControls._mcHolder = this.createEmptyMovieClip("gaugeHolderLoader",this.getNextHighestDepth());
      trace("RaceControls Constructor");
      this.pedalCluster._visible = false;
   }
   function clipLoaded(a_leftSide, a_shiftLightRPM, a_controlsID, a_hasShiftLight, temperature)
   {
      this.hasShiftLight = a_hasShiftLight;
      this.controlsID = a_controlsID;
      if(a_leftSide)
      {
         trace("show left in RaceControls");
         classes.RaceControls._mcHolder.showLeft(true);
         this._mc = classes.RaceControls._mcHolder.left;
      }
      else
      {
         classes.RaceControls._mcHolder.showLeft(false);
         this._mc = classes.RaceControls._mcHolder.right;
      }
      this._mc.takeControlsID(this.controlsID,true,a_hasShiftLight,temperature);
      this._mc.isRace(true);
      if(this.hasShiftLight == true)
      {
         this._mc.gaugeCluster.shiftLight._visible = true;
         this.showShiftLight(false);
      }
      else
      {
         this._mc.gaugeCluster.shiftLight._visible = false;
      }
      this.shiftLightRPM = a_shiftLightRPM;
      this.gaugeCluster = this._mc.gaugeCluster;
      this.gearCluster = this._mc.gearCluster;
      this.boostGauge = this._mc.boostGauge;
      this.nosGauge = this._mc.nosGauge;
      this.launchControl = this._mc.launchControl;
      this.tractionIcon = this._mc.tractionIcon;
      this.damageLight = this._mc.damageLight;
      trace("pedalCluster: " + this.pedalCluster);
      trace(this._mc.pedalCluster);
      this.pedalCluster.btnGas.onPress = function()
      {
         trace("btnGas pushed!");
         trace(this._parent.gasFillMC);
         this._parent.gasFillMC._y = this._parent._ymouse;
         this._parent.gasFillMC.startDrag(false,this._x,this._y,this._x,this._y + this._height);
      };
      this.pedalCluster.btnGas.onRelease = this.pedalCluster.btnGas.onReleaseOutside = function()
      {
         this._parent.gasFillMC.stopDrag();
         this._parent.gasFillMC._y = this._y + this._height;
      };
      this.pedalCluster.btnBrake.onPress = function()
      {
         this._parent.brakeFillMC._visible = true;
         _root.runEngineSetBrake(1);
      };
      this.pedalCluster.btnBrake.onRelease = this.pedalCluster.btnBrake.onReleaseOutside = function()
      {
         this._parent.brakeFillMC._visible = false;
         _root.runEngineSetBrake(0);
      };
      this.pedalCluster.btnClutch.onPress = function()
      {
         this._parent.clutchFillMC._y = this._parent._ymouse;
         this._parent.clutchFillMC.startDrag(false,this._x,this._y,this._x,this._y + this._height);
      };
      this.pedalCluster.btnClutch.onRelease = this.pedalCluster.btnClutch.onReleaseOutside = function()
      {
         this._parent.clutchFillMC.stopDrag();
         var _loc3_ = 1 - (this._parent.clutchFillMC._y - this._y) / this._height;
         var _loc4_ = 0.15 * _loc3_ + 0.05;
         _root.runEngineSetClutch(_loc4_);
      };
      this.init();
   }
   function set RpmRedLine(r)
   {
      this.rpmRedLine = r;
      this._visible = true;
      this.pedalCluster._visible = true;
      this._mc.updateRPMRedLine(this.rpmRedLine,this.controlsID,this.hasShiftLight);
   }
   function runEvery()
   {
      var _loc4_ = 1 - (this.pedalCluster.gasFillMC._y - this.pedalCluster.btnGas._y) / this.pedalCluster.btnGas._height;
      var _loc3_ = !(Key.isDown(39) || Key.isDown(68) && Selection.getFocus().indexOf("tfInbox") <= -1) ? 0 : 1;
      if(this.nosOn != _loc3_)
      {
         if(_loc3_)
         {
            trace("nosPressed");
            trace("nos needle rotation: " + this._mc.nosGauge.nosNeedle._rotation);
            trace("nosNeedleMin: " + this.nosNeedleMin);
            if(this._mc.nosGauge.nosNeedle._rotation > this.nosNeedleMin)
            {
               trace("play effect");
               classes.RacePlay._MC.playEffect("nos");
            }
         }
         _root.runEngineSetNOS(_loc3_);
         this.nosOn = _loc3_;
      }
      _root.runEngine(_loc4_);
      if(!this)
      {
         trace("clear race on enter frame");
      }
   }
   function init()
   {
      trace("init");
      trace(this.pedalCluster.brakeFillMC._visible);
      this.pedalCluster.brakeFillMC._visible = false;
      trace(this.pedalCluster.brakeFillMC._visible);
      this.pedalCluster.gasFillMC._y = this.pedalCluster.btnGas._y + this.pedalCluster.btnGas._height;
      this._mc.updateRPMRedLine(this.rpmRedLine,this.controlsID);
      this.onEnterFrame = this.runEvery;
   }
   function updateMPH(mph)
   {
      trace("updateMPH");
      trace(this._mc.gaugeCluster.mphMovie);
      trace(this._mc.gaugeCluster.mphMovie.mph);
      this._mc.gaugeCluster.mphMovie.mph.text = mph;
   }
   function initBoost(boostType)
   {
      if(boostType == "N")
      {
         this._mc.boostGauge._visible = false;
      }
      else
      {
         this._mc.boostGauge._visible = true;
      }
   }
   function initNos(nosSize, nosRemain)
   {
      if(nosSize > 0)
      {
         this._mc.nosGauge._visible = true;
         this.updateNos(nosRemain / nosSize * 100);
      }
      else
      {
         this._mc.nosGauge._visible = false;
      }
   }
   function showLaunchControl(showIt)
   {
      trace("hi");
      trace("showLaunchControl: " + showIt);
      this._mc.launchControl._visible = showIt;
      this._mc.tractionIcon._visible = !showIt;
   }
   function updateNos(pct)
   {
      this._mc.nosGauge.nosNeedle._rotation = this.nosNeedleMin + (this.nosNeedleMax - this.nosNeedleMin) * pct / 100;
      if(pct <= 0)
      {
         this._mc.nosGauge.nosLight._visible = true;
      }
      else
      {
         this._mc.nosGauge.nosLight._visible = false;
      }
   }
   function updateRPM(rpm)
   {
      this._mc.gaugeCluster.rpmNeedle._rotation = this._mc.rpmNeedleMin + (this._mc.rpmNeedleMax - this._mc.rpmNeedleMin) * (rpm / 10000);
      if(rpm >= this.shiftLightRPM)
      {
         this.showShiftLight(true);
      }
      else
      {
         this.showShiftLight(false);
      }
   }
   function updateBoost(boostPSI)
   {
      var _loc3_ = this.boostGauge.boostNeedle._rotation;
      if(_loc3_ < this.boostNeedleMin)
      {
         _loc3_ += 360;
      }
      var _loc2_ = this.boostNeedleMin + (this.boostNeedleMax - this.boostNeedleMin) * (boostPSI / this.boostMaxPSI) - _loc3_;
      if(_loc2_ > 50)
      {
         _loc2_ = 50;
      }
      else if(_loc2_ < -50)
      {
         _loc2_ = -50;
      }
      this._mc.boostGauge.boostNeedle._rotation += _loc2_;
   }
   function showShiftLight(showIt)
   {
      this._mc.gaugeCluster.shiftLight.topGlow._visible = showIt;
      this._mc.gaugeCluster.shiftLight.bottomGlow._visible = showIt;
   }
}
