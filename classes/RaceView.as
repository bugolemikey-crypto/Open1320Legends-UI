class classes.RaceView extends classes.Race
{
   var amAutoStage;
   var cd1;
   var cd2;
   var createEmptyMovieClip;
   var d1;
   var d2;
   var getNextHighestDepth;
   var initObj;
   var isRaceView;
   var isSpectator;
   var isStaging1;
   var isStaging2;
   var nextSI;
   var onEnterFrame;
   var raceOverlay;
   var raceResultsOverlay;
   var raceResultsTimes;
   var racer1Obj;
   var racer2Obj;
   var showFinishFlag;
   var specStagingStarted;
   var td;
   var user1Info;
   var user2Info;
   var wid;
   function RaceView()
   {
      super();
      trace("RaceView Constructor");
      this.isRaceView = true;
      this.wid = this.initObj.wid;
      this.racer1Obj = this.initObj.racer1Obj;
      if(this.racer1Obj.d == undefined)
      {
         this.racer1Obj.d = -13;
      }
      this.racer1Obj.nd = this.racer1Obj.d;
      this.racer1Obj.ld = this.racer1Obj.d;
      this.racer1Obj.td = this.racer1Obj.d;
      this.racer1Obj.v = 0;
      this.racer1Obj.a = 0;
      this.racer1Obj.t = 0;
      this.racer2Obj = this.initObj.racer2Obj;
      if(this.racer2Obj.d == undefined)
      {
         this.racer2Obj.d = -13;
      }
      this.racer2Obj.nd = this.racer2Obj.d;
      this.racer2Obj.ld = this.racer2Obj.d;
      this.racer2Obj.td = this.racer2Obj.d;
      this.racer2Obj.v = 0;
      this.racer2Obj.a = 0;
      this.racer2Obj.t = 0;
      this.isSpectator = true;
      this.specStagingStarted = true;
   }
   function autoStage(lane)
   {
      if(this.amAutoStage == undefined)
      {
         trace("autoStage go");
         this.amAutoStage = this.createEmptyMovieClip("amAutoStage",this.getNextHighestDepth());
         this.amAutoStage.cd1 = 0;
         this.amAutoStage.cd2 = 0;
         this.amAutoStage.td = -1.8;
         this.amAutoStage.onEnterFrame = function()
         {
            if(this.isStaging1)
            {
               this.cd1 = Math.min(0.6,(this.td - this.d1) / 5);
               this.d1 += this.cd1;
            }
            if(this.isStaging2)
            {
               this.cd2 = Math.min(0.6,(this.td - this.d2) / 5);
               this.d2 += this.cd2;
            }
            with(this._parent)
            {
               tree.showLight("pre1",this.d1 > -3 && this.d1 < 0);
               tree.showLight("staged1",this.d1 > -2 && this.d1 < 1);
               tree.showLight("pre2",this.d2 > -3 && this.d2 < 0);
               tree.showLight("staged2",this.d2 > -2 && this.d2 < 1);
               renderCar(1,scaleLength + this.d1);
               renderCar(2,scaleLength + this.d2);
               turnWheels(1,this.d1);
               turnWheels(2,this.d2);
            }
            if(Math.abs(this.td - this.d1) < 0.1 && Math.abs(this.td - this.d2) < 0.1)
            {
               delete this.onEnterFrame;
            }
         };
      }
      if(this.amAutoStage["d" + lane] == undefined)
      {
         this.amAutoStage["d" + lane] = this["racer" + lane + "Obj"].d;
      }
      this.amAutoStage["isStaging" + lane] = true;
   }
   function removeAutoStage()
   {
      delete this.amAutoStage.onEnterFrame;
      this.amAutoStage.removeMovieClip();
   }
   function showFinish(delay)
   {
      trace("showFinish(RaceView) [" + new Date().getTime() + "]");
      if(this.showFinishFlag)
      {
         return undefined;
      }
      this.showFinishFlag = true;
      if(!delay && delay !== 0)
      {
         delay = 6000;
      }
      var _loc6_ = 0;
      this.raceOverlay.finishOverlay._visible = true;
      this.user1Info.badges._visible = false;
      this.user2Info.badges._visible = false;
      this.user1Info._visible = true;
      this.user2Info._visible = true;
      var _loc3_ = new TextFormat();
      _loc3_.color = 16711680;
      var _loc4_;
      if(Number(this.wid) > 0)
      {
         if(this.wid == this.racer1Obj.id)
         {
            this.raceOverlay.finishLights2.prevFrame();
            this.raceOverlay.finishLights1.nextFrame();
         }
         else if(this.wid == this.racer2Obj.id)
         {
            this.raceOverlay.finishLights1.prevFrame();
            this.raceOverlay.finishLights2.nextFrame();
         }
         this.raceResultsTimes.txt1 = "+" + classes.NumFuncs.zeroFill(this.racer1Obj.tt,3);
         this.raceResultsTimes.txt2 = "+" + classes.NumFuncs.zeroFill(this.racer2Obj.tt,3);
         this.raceResultsOverlay.txtResults1 = "";
         this.raceResultsOverlay.txtResults2 = "";
         _loc4_ = new TextFormat();
         _loc4_.color = 16711680;
         if(this.wid == this.racer1Obj.id)
         {
            this.raceResultsTimes.fld2.setTextFormat(_loc4_);
         }
         else if(this.wid == this.racer2Obj.id)
         {
            this.raceResultsTimes.fld1.setTextFormat(_loc4_);
         }
      }
      else if(this.wid == -2)
      {
         this.raceResultsOverlay.txtResults1 = "PENALTY";
         this.raceResultsOverlay.txtResults2 = "PENALTY";
         this.raceResultsOverlay.fldResults1.setTextFormat(_loc3_);
         this.raceResultsOverlay.fldResults2.setTextFormat(_loc3_);
      }
      this.raceFinish();
      this.nextSI = _global.setTimeout(this.raceEnd,delay,this);
   }
   function raceFinish()
   {
      trace("raceFinish(RaceView) [" + new Date().getTime() + "]");
      this.raceResultsTimes._visible = true;
      this.raceResultsOverlay._visible = true;
   }
   function raceEnd(_obj)
   {
      trace("raceEnd [" + new Date().getTime() + "]");
      if(_obj.nextSI)
      {
         clearInterval(_obj.nextSI);
         _root.raceSound.stopSound();
      }
   }
}
