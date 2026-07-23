class classes.RaceTreeLights extends MovieClip
{
   var amber11;
   var amber12;
   var amber21;
   var amber22;
   var amber31;
   var amber32;
   var ccSI;
   var ccTime;
   var green1;
   var green2;
   var pre1;
   var pre2;
   var red1;
   var red2;
   var staged1;
   var staged2;
   var txtTime;
   static var _MC;
   function RaceTreeLights()
   {
      super();
      classes.RaceTreeLights._MC = this;
      this.init();
   }
   function init()
   {
      this.pre1._visible = false;
      this.pre2._visible = false;
      this.staged1._visible = false;
      this.staged2._visible = false;
      this.amber11._visible = false;
      this.amber21._visible = false;
      this.amber31._visible = false;
      this.green1._visible = false;
      this.red1._visible = false;
      this.amber12._visible = false;
      this.amber22._visible = false;
      this.amber32._visible = false;
      this.green2._visible = false;
      this.red2._visible = false;
      var _loc3_ = 0;
      if(_global.chatObj.raceObj.timeToStage)
      {
         _loc3_ = Math.max(0,_global.chatObj.raceObj.timeToStage - Math.floor((new Date() - _global.chatObj.raceObj.stageTS) / 1000) - 2);
      }
      this.ccTime = _loc3_;
      this.txtTime = String(_loc3_);
      if(_loc3_)
      {
         trace("setTimeout count");
         this.ccSI = _global.setTimeout(this,"count",1000);
      }
      else if(!this._parent.isRaceView)
      {
         trace("onTimeOut exec");
         this.onTimeOut();
      }
   }
   function onTimeOut()
   {
      trace("onTimeOut..");
      if(!classes.RacePlay._MC.isStaged && (classes.RacePlay._MC.myLane == 1 || classes.RacePlay._MC.myLane == 2))
      {
         trace("..showTimedOut");
         _global.chatObj.raceRoomMC.showTimedOut();
      }
   }
   function count()
   {
      this.ccTime = this.ccTime - 1;
      this.txtTime = String(this.ccTime);
      if(this.ccTime > 0)
      {
         this.ccSI = _global.setTimeout(this,"count",1000);
      }
      else
      {
         this.onTimeOut();
      }
   }
   function clearTimer()
   {
      _global.clearTimeout(this.ccSI);
      this.txtTime = "";
   }
   function showLight(fullLightName, setting)
   {
      this[fullLightName]._visible = setting;
   }
   function setLight(lane, lightName, setting)
   {
      if(!lane)
      {
         lane = 1;
         while(lane <= 2)
         {
            this.doLight(lane,lightName,setting);
            lane = lane + 1;
         }
      }
      else
      {
         this.doLight(lane,lightName,setting);
      }
   }
   function doLight(lane, lightName, setting)
   {
      var _loc2_;
      if(lightName == "ambers")
      {
         if(!setting || setting && !this["red" + lane].isOn)
         {
            _loc2_ = 1;
            while(_loc2_ <= 3)
            {
               this["amber" + _loc2_ + lane].isOn = setting;
               if(classes.RacePlay._MC.myLane)
               {
                  this["amber" + _loc2_ + lane]._visible = setting;
               }
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      else if(!setting || setting && !this["red" + lane].isOn)
      {
         this[lightName + lane].isOn = setting;
         if(classes.RacePlay._MC.myLane)
         {
            this[lightName + lane]._visible = setting;
         }
      }
      if(lightName == "red" && setting)
      {
         _loc2_ = 1;
         while(_loc2_ <= 3)
         {
            this["amber" + _loc2_ + lane].isOn = false;
            if(classes.RacePlay._MC.myLane)
            {
               this["amber" + _loc2_ + lane]._visible = false;
            }
            _loc2_ = _loc2_ + 1;
         }
         this["green" + _loc2_ + lane].isOn = false;
         if(classes.RacePlay._MC.myLane)
         {
            this["green" + _loc2_ + lane]._visible = false;
         }
      }
   }
   function syncAllForLane(lane)
   {
      var _loc2_ = 1;
      while(_loc2_ <= 3)
      {
         this["amber" + _loc2_ + lane]._visible = this["amber" + _loc2_ + lane].isOn;
         _loc2_ = _loc2_ + 1;
      }
      this["green" + lane]._visible = this["green" + lane].isOn;
      this["red" + lane]._visible = this["red" + lane].isOn;
   }
   function syncLight(fullLightName)
   {
      this[fullLightName]._visible = this[fullLightName].isOn;
   }
}
