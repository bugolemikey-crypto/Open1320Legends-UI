class classes.Race extends MovieClip
{
   var amComp;
   var amLive;
   var amSpectator;
   var baseY;
   var bktLag1;
   var bktLag2;
   var c;
   var cInt;
   var camD;
   var cc;
   var cdiff1;
   var cdiff2;
   var d;
   var d1;
   var d2;
   var dCam;
   var dt;
   var et1;
   var et2;
   var finished;
   var gauge;
   var gaugeStaging;
   var gotoFrame;
   var intLength;
   var isCompRace;
   var isLightsDone1;
   var isLightsDone2;
   var isRacing;
   var isStaged;
   var its;
   var lastTS;
   var lastcts;
   var lightsGone;
   var m;
   var myLane;
   var myObj;
   var myR;
   var newD;
   var newV;
   var newd;
   var nextSI;
   var onEnterFrame;
   var oppD;
   var oppLane;
   var oppObj;
   var oppR;
   var oppRenderD;
   var pos;
   var posArr;
   var ppIdx;
   var r;
   var raceOverlay;
   var raceResultsOverlay;
   var raceResultsTimes;
   var raceStarted;
   var racer1Obj;
   var racer2Obj;
   var racerBubbles;
   var rt1;
   var rt2;
   var screenEventShake;
   var showFinishFlag;
   var specRacingStarted;
   var specStagingStarted;
   var st;
   var stagingSI;
   var stagingTime;
   var tOpp;
   var tStartOpp;
   var tcdiff;
   var tcplus;
   var tfrac;
   var tree;
   var tt;
   var user1Info;
   var user2Info;
   var v;
   var v1;
   var v2;
   var vCam;
   var vel;
   var voteArr;
   var voteBtns;
   var wid;
   var winnerLightSI;
   static var _MC;
   var dSpec = 0;
   var dFollowOld = 0;
   var scaleArr = new Array({d:9999,s:1},{d:300,s:1},{d:150,s:6.32},{d:99.8,s:13},{d:51,s:24},{d:31.6,s:34.8},{d:15.7,s:56.2},{d:9,s:100},{d:6.4,s:120},{d:-6,s:280},{d:-13,s:450},{d:-9999,s:450});
   var scaleArrLength = classes.Race.prototype.scaleArr.length;
   var scaleFactor = 0.61;
   var scaleLength = 13;
   var trackLength = 1358;
   function Race()
   {
      super();
      classes.Race._MC = this;
   }
   function setAmComp()
   {
      trace("CALL: setAmComp");
      this.isCompRace = true;
      var _loc4_ = this["racer" + this.oppLane + "Obj"];
      _loc4_.d = 0;
      _loc4_.ld = 0;
      _loc4_.td = 0;
      this.amComp = this.createEmptyMovieClip("amComp",this.getNextHighestDepth());
      this.amComp.m = this.myLane;
      this.amComp.r = this.oppLane;
      this.amComp.scaleLength = this.scaleLength;
      this.amComp.trackLength = this.trackLength;
      this.amComp.gotoFrame = 0;
      this.amComp.oppObj = this["racer" + this.oppLane + "Obj"];
      this.amComp.myObj = this["racer" + this.myLane + "Obj"];
      this.amComp.tOpp = 0;
      this.amComp.ppIdx = 0;
      this.amComp.newD = 0;
      this.amComp.newV = 0;
      this.amComp.bkDiff = _global.chatObj.raceObj.bkDiff;
      this.amComp.tStartOpp = 2000 + 1000 * Math.max(0,_global.chatObj.raceObj.bkDiff);
      this.amComp.finished = false;
      this.amComp.renderBothCars = function()
      {
         this.tOpp = this.myObj.t - this.tStartOpp;
         this.ppIdx = Math.max(0,Math.floor(this.tOpp / 33.3333));
         if(this.ppIdx >= 0)
         {
            this.newD = Number(_global.chatObj.raceObj.oppObj.ppArr[this.ppIdx]);
            if(this.newD)
            {
               this.newV = (this.newD - this.oppObj.d) * 33.3333;
               this.oppObj.d = this.newD;
            }
            else
            {
               this.oppObj.d += this.newV;
            }
            this._parent.updateDistance(this.r,this.oppObj.d,true,this.newV,0);
            this._parent.renderCar(this.r,this.oppObj.d - Math.max(Math.min(this.trackLength,this.myObj.d),0) + this.scaleLength);
            this._parent.gauge["car" + this.r]._y = (- this.oppObj.d / 1320) * classes.Race._MC.gauge.trackBar._height;
            classes.Race._MC.setCarBounce(this.r,this.oppObj.v);
            if(this.oppObj.d > 1320 && !this.finished)
            {
               trace("FINISHED");
               this._parent.crossWire(_global.chatObj.raceObj.oppObj.id,_global.chatObj.raceObj.oppObj.et,_global.chatObj.raceObj.oppObj.ts);
               this.finished = true;
            }
         }
         else
         {
            this._parent.renderCar(this.r,- Math.max(this.myObj.d,0) + this.scaleLength);
            this._parent.gauge["car" + this.r]._y = 0;
         }
         var _loc4_;
         if(this.myObj.d < this.trackLength)
         {
            _loc4_ = Math.min(this.myObj.d,0);
         }
         else
         {
            _loc4_ = this.myObj.d - this.trackLength;
         }
         this._parent.renderCar(this.m,_loc4_ + this.scaleLength);
         this._parent.gauge["car" + this.m]._y = (- this.myObj.d / 1320) * classes.Race._MC.gauge.trackBar._height;
         classes.Race._MC.setCarBounce(this.m,this.myObj.v);
         classes.Race._MC.showTrackAtPos(this.myObj.d);
         classes.Race._MC.turnWheels(this.m,this.myObj.d);
         if(this.oppObj.d > -11)
         {
            classes.Race._MC.turnWheels(this.r,this.oppObj.d);
         }
         else
         {
            classes.Race._MC.hideWheels(this.r);
         }
         var _loc3_ = Math.min(this.myObj.d,1358);
         _loc3_ = Math.max(0,_loc3_);
         this.vCam = (_loc3_ - this.dCam) * 30;
         this.dCam = _loc3_;
         classes.Race._MC.setScreenJitter(this.vCam);
      };
   }
   function setAmLive()
   {
      trace("CALL: setAmLive");
      this.amLive = this.createEmptyMovieClip("amLive",this.getNextHighestDepth());
      this.amLive.dCam = 0;
      this.amLive.vCam = 0;
      this.amLive.myR = this.myLane;
      this.amLive.oppR = this.oppLane;
      this.amLive.gotoFrame = 0;
      this.amLive.scaleLength = this.scaleLength;
      this.amLive.myObj = this["racer" + this.myLane + "Obj"];
      this.amLive.oppObj = this["racer" + this.oppLane + "Obj"];
      this.amLive.oppObj.raceOpp = new classes.RaceOpponent();
      this.amLive.oppObj.tt = 0;
      this.amLive.oppObj.nt = 0;
      this.amLive.oppD = this.amLive.oppObj.d;
      this.amLive.oppRenderD = 0;
      this.amLive.renderBothCars = function()
      {
         classes.RacePlay._MC.setCarBounce(this.myR,this.myObj.v);
         classes.RacePlay._MC.setCarBounce(this.oppR,this.oppObj.v);
         var _loc2_ = Math.min(this.myObj.d,1358);
         _loc2_ = Math.max(0,_loc2_);
         this.vCam = (_loc2_ - this.dCam) * 30;
         this.dCam = _loc2_;
         classes.RacePlay._MC.showTrackAtPos(this.dCam);
         var _loc4_ = this.scaleLength + (this.myObj.d - this.dCam);
         if(_loc4_ < -4)
         {
            classes.RacePlay._MC["car" + this.myR]._visible = false;
         }
         else
         {
            classes.RacePlay._MC.renderCar(this.myR,_loc4_);
         }
         if(_loc4_ > -4)
         {
            classes.RacePlay._MC.turnWheels(this.myR,this.myObj.d);
         }
         else
         {
            classes.RacePlay._MC.hideWheels(this.myR);
         }
         this.setScreenJitter(this.vCam);
         var _loc3_ = this.oppObj.raceOpp.getPos(this.myObj.t,this.oppObj.lastTS);
         if(classes.RacePlay._MC.raceStarted)
         {
            this.oppD = Math.max(this.oppD,_loc3_);
         }
         else
         {
            this.oppD = _loc3_;
         }
         this.oppRenderD = this.scaleLength + (_loc3_ - this.dCam);
         if(this.oppRenderD < -4)
         {
            classes.RacePlay._MC["car" + this.oppR]._visible = false;
         }
         else
         {
            classes.RacePlay._MC.renderCar(this.oppR,this.oppRenderD);
         }
         if(this.oppRenderD > -4)
         {
            classes.RacePlay._MC.turnWheels(this.oppR,this.oppD);
         }
         else
         {
            classes.RacePlay._MC.hideWheels(this.oppR);
         }
         classes.RacePlay._MC.gauge["car" + this.myR]._y = (- this.myObj.d / 1320) * classes.RacePlay._MC.gauge.trackBar._height;
         classes.RacePlay._MC.gauge["car" + this.oppR]._y = (- _loc3_ / 1320) * classes.RacePlay._MC.gauge.trackBar._height;
      };
   }
   function startStagingController()
   {
      if(!this.specStagingStarted)
      {
         _global.setTimeout(this,"setStagingController",4000);
         this.specStagingStarted = true;
      }
   }
   function setStagingController()
   {
      trace("SPECTATE setStagingController");
      classes.Race._MC.showTrackAtPos(0);
      if(!this.amSpectator)
      {
         this.amSpectator = this.createEmptyMovieClip("amSpectator",this.getNextHighestDepth());
      }
      this.amSpectator.c = 0;
      this.amSpectator.i = 0;
      this.amSpectator.st = new Date();
      this.amSpectator.intLength = 200;
      this.amSpectator.d1 = -13;
      this.amSpectator.d2 = -13;
      this.amSpectator.cdiff1 = 0;
      this.amSpectator.cdiff2 = 0;
      this.amSpectator.onEnterFrame = function()
      {
         this.dt = new Date() - this.st;
         this.c = Math.floor(this.dt / this.intLength);
         this.tfrac = this.dt % this.intLength / this.intLength;
         this.tcplus = Number(_global.chatObj.raceObj.r1Obj.sArr[this.c + 1]);
         this.tcdiff = this.tcplus - Number(_global.chatObj.raceObj.r1Obj.sArr[this.c]);
         if(this.tcdiff)
         {
            this.cdiff1 = this.tcdiff;
         }
         else if(this.tcplus || this.tcplus === 0)
         {
            this.cdiff1 = 0;
         }
         this.v1 = 5 * this.cdiff1 * 0.68181818;
         this.d1 = Number(_global.chatObj.raceObj.r1Obj.sArr[this.c]) + this.cdiff1 * this.tfrac;
         this.tcplus = Number(_global.chatObj.raceObj.r2Obj.sArr[this.c + 1]);
         this.tcdiff = this.tcplus - Number(_global.chatObj.raceObj.r2Obj.sArr[this.c]);
         if(this.tcdiff)
         {
            this.cdiff2 = this.tcdiff;
         }
         else if(this.tcplus || this.tcplus === 0)
         {
            this.cdiff2 = 0;
         }
         this.v2 = 5 * this.cdiff2 * 0.68181818;
         this.d2 = Number(_global.chatObj.raceObj.r2Obj.sArr[this.c]) + this.cdiff2 * this.tfrac;
         this._parent.updateSpectate(this.d1,this.d2,this.v1,this.v2);
      };
   }
   function startSpectatorController(startTimeOffset)
   {
      trace("startSpectatorController [" + new Date().getTime() + "]");
      trace("startSpectatorController: " + startTimeOffset);
      if(!this.specRacingStarted)
      {
         if(!startTimeOffset)
         {
            startTimeOffset = 0;
         }
         _global.setTimeout(this,"setSpectatorController",4000,startTimeOffset);
         this.specRacingStarted = true;
      }
   }
   function setSpectatorController(startTimeOffset)
   {
      trace("SPECTATE setSpectatorController [" + new Date().getTime() + "]");
      trace("SPECTATE setSpectatorController: " + startTimeOffset);
      if(!this.amSpectator)
      {
         this.amSpectator = this.createEmptyMovieClip("amSpectator",this.getNextHighestDepth());
      }
      if(!startTimeOffset)
      {
         startTimeOffset = 0;
      }
      this.amSpectator.st = new Date();
      this.amSpectator.c = 0;
      this.amSpectator.i = 0;
      var _loc4_ = Math.min(Number(this.racer1Obj.bt),Number(this.racer2Obj.bt));
      this.amSpectator.isLightsDone1 = false;
      this.amSpectator.isLightsDone2 = false;
      this.amSpectator.lightsGone = false;
      this.amSpectator.rt1 = false;
      this.amSpectator.rt2 = false;
      this.amSpectator.et1 = false;
      this.amSpectator.et2 = false;
      this.amSpectator.intLength = 200;
      this.amSpectator.bktLag1 = 1000 * (Number(this.racer2Obj.bt) - _loc4_);
      this.amSpectator.bktLag2 = 1000 * (Number(this.racer1Obj.bt) - _loc4_);
      if(!this.amSpectator.bktLag1)
      {
         this.amSpectator.bktLag1 = 0;
      }
      if(!this.amSpectator.bktLag2)
      {
         this.amSpectator.bktLag2 = 0;
      }
      this.amSpectator.cdiff1 = 0;
      this.amSpectator.cdiff2 = 0;
      this.amSpectator.onEnterFrame = function()
      {
         this.dt = new Date() - this.st;
         this.c = Math.floor(this.dt / this.intLength);
         this.tfrac = this.dt % this.intLength / this.intLength;
         this.tcdiff = Number(_global.chatObj.raceObj.r1Obj.dArr[this.c + 1]) - Number(_global.chatObj.raceObj.r1Obj.dArr[this.c]);
         if(this.tcdiff || this.tcdiff === 0)
         {
            this.cdiff1 = this.tcdiff;
            this.d1 = Number(_global.chatObj.raceObj.r1Obj.dArr[this.c]) + this.cdiff1 * this.tfrac;
         }
         else
         {
            this.cdiff1 = Number(_global.chatObj.raceObj.r1Obj.dArr[_global.chatObj.raceObj.r1Obj.dArr.length - 1]) - Number(_global.chatObj.raceObj.r1Obj.dArr[_global.chatObj.raceObj.r1Obj.dArr.length - 2]);
            this.d1 += this.cdiff1 * this.intLength / 1000;
         }
         if(!this.cdiff1)
         {
            this.cdiff1 = 0;
         }
         this.v1 = 5 * this.cdiff1 * 0.68181818;
         this.tcdiff = Number(_global.chatObj.raceObj.r2Obj.dArr[this.c + 1]) - Number(_global.chatObj.raceObj.r2Obj.dArr[this.c]);
         if(this.tcdiff || this.tcdiff === 0)
         {
            this.cdiff2 = this.tcdiff;
            this.d2 = Number(_global.chatObj.raceObj.r2Obj.dArr[this.c]) + this.cdiff2 * this.tfrac;
         }
         else
         {
            this.cdiff2 = Number(_global.chatObj.raceObj.r2Obj.dArr[_global.chatObj.raceObj.r2Obj.dArr.length - 1]) - Number(_global.chatObj.raceObj.r2Obj.dArr[_global.chatObj.raceObj.r2Obj.dArr.length - 2]);
            this.d2 += this.cdiff2 * this.intLength / 1000;
         }
         if(!this.cdiff2)
         {
            this.cdiff2 = 0;
         }
         this.v2 = 5 * this.cdiff2 * 0.68181818;
         this._parent.updateSpectate(this.d1,this.d2,this.v1,this.v2,this.c);
         trace("Race::spectateDelay:");
         trace(_global.spectateDelay);
         if(!this.isLightsDone1)
         {
            if(_global.spectateDelay > 0 && this.dt >= this.bktLag1 + _global.spectateDelay)
            {
               classes.Race._MC.tree.syncLight("red1");
               if(!classes.Race._MC.tree.red1.isOn)
               {
                  classes.Race._MC.tree.syncLight("green1");
               }
               this.isLightsDone1 = true;
            }
            else
            {
               if(this.dt >= this.bktLag1 + 1500)
               {
                  classes.Race._MC.tree.syncLight("red1");
                  if(!classes.Race._MC.tree.red1.isOn)
                  {
                     classes.Race._MC.tree.syncLight("green1");
                  }
                  this.isLightsDone1 = true;
               }
               if(this.dt >= this.bktLag1 + 1000)
               {
                  classes.Race._MC.tree.syncLight("amber31");
               }
               if(this.dt >= this.bktLag1 + 500)
               {
                  classes.Race._MC.tree.syncLight("amber21");
               }
            }
            if(this.dt >= this.bktLag1)
            {
               classes.Race._MC.tree.syncLight("amber11");
               if(_global.spectateDelay > 0)
               {
                  classes.Race._MC.tree.syncLight("amber21");
                  classes.Race._MC.tree.syncLight("amber31");
               }
            }
         }
         if(!this.isLightsDone2)
         {
            if(_global.spectateDelay > 0 && this.dt >= this.bktLag1 + _global.spectateDelay)
            {
               classes.Race._MC.tree.syncLight("red2");
               if(!classes.Race._MC.tree.red1.isOn)
               {
                  classes.Race._MC.tree.syncLight("green2");
               }
               this.isLightsDone2 = true;
            }
            else
            {
               if(this.dt >= this.bktLag2 + 1500)
               {
                  classes.Race._MC.tree.syncLight("red2");
                  if(!classes.Race._MC.tree.red2.isOn)
                  {
                     classes.Race._MC.tree.syncLight("green2");
                  }
                  this.isLightsDone2 = true;
               }
               if(this.dt >= this.bktLag2 + 1000)
               {
                  classes.Race._MC.tree.syncLight("amber32");
               }
               if(this.dt >= this.bktLag2 + 500)
               {
                  classes.Race._MC.tree.syncLight("amber22");
               }
            }
            if(this.dt >= this.bktLag2)
            {
               classes.Race._MC.tree.syncLight("amber12");
               if(_global.spectateDelay > 0)
               {
                  classes.Race._MC.tree.syncLight("amber22");
                  classes.Race._MC.tree.syncLight("amber32");
               }
            }
         }
         var _loc3_ = classes.Race._MC.raceOverlay;
         if(!this.lightsGone)
         {
            if(classes.Race._MC.dSpec > 0)
            {
               classes.Race._MC.tree._visible = false;
               this.lightsGone = true;
            }
         }
         if(!this.rt1)
         {
            if(this.d1 > 0 || classes.Race._MC.racer1Obj.RT < 0)
            {
               _loc3_.raceTimes1._visible = true;
               this.rt1 = true;
            }
         }
         else if(!this.et1 && this.d1 >= 1320)
         {
            trace("spec: Racer1 finished");
            _loc3_.raceTimes1.txtET = !_loc3_.raceTimes1.holdET ? "" : _loc3_.raceTimes1.holdET;
            _loc3_.raceTimes1.txtTS = !_loc3_.raceTimes1.holdTS ? "" : _loc3_.raceTimes1.holdTS;
            _loc3_.raceTimes1.breakout._visible = _loc3_.raceTimes1.breakout.isOn;
            classes.Race._MC.showWinnerLight();
            this.et1 = true;
         }
         if(!this.rt2)
         {
            if(this.d2 > 0 || classes.Race._MC.racer2Obj.RT < 0)
            {
               _loc3_.raceTimes2._visible = true;
               this.rt2 = true;
            }
         }
         else if(!this.et2 && this.d2 >= 1320)
         {
            trace("spec: Racer2 finished");
            _loc3_.raceTimes2.txtET = !_loc3_.raceTimes2.holdET ? "" : _loc3_.raceTimes2.holdET;
            _loc3_.raceTimes2.txtTS = !_loc3_.raceTimes2.holdTS ? "" : _loc3_.raceTimes2.holdTS;
            _loc3_.raceTimes2.breakout._visible = _loc3_.raceTimes2.breakout.isOn;
            classes.Race._MC.showWinnerLight();
            this.et2 = true;
         }
      };
   }
   function clearSpectatorController()
   {
      delete this.amSpectator.onEnterFrame;
   }
   function countStagingTimer()
   {
      this.stagingTime = this.stagingTime - 1;
      if(this.isStaged)
      {
         this.tree.txtTime = "";
      }
      else
      {
         this.tree.txtTime = this.stagingTime;
      }
      if(this.stagingTime <= 0)
      {
         if(!this.isStaged && (this.myLane == 1 || this.myLane == 2))
         {
            _global.chatObj.raceRoomMC.showTimedOut();
            _root.raceKOTHReady(1);
         }
      }
   }
   function stagingTimer(t)
   {
      this.stagingTime = Math.max(0,t);
      if(this.isStaged)
      {
         this.tree.txtTime = "";
      }
      else
      {
         this.tree.txtTime = this.stagingTime;
      }
      if(this.stagingTime <= 0)
      {
         if(!this.isStaged && (this.myLane == 1 || this.myLane == 2))
         {
            _global.chatObj.raceRoomMC.showTimedOut();
         }
      }
   }
   function addVote(forID, isCheer, fromID)
   {
      trace("Race.addVote: " + forID + ", " + isCheer + ", " + fromID);
      var _loc3_;
      if(this.racer1Obj.id == forID)
      {
         _loc3_ = 1;
      }
      else if(this.racer2Obj.id == forID)
      {
         _loc3_ = 2;
      }
      if(_loc3_)
      {
         this.voteArr.push({forLane:_loc3_,isCheer:isCheer,fromID:fromID});
      }
      if(isCheer)
      {
         _root.sx.cheer.snd.start();
      }
      else
      {
         _root.sx.boo.snd.start();
      }
      this.showVotes();
   }
   function removeVotes(fromID)
   {
      var _loc3_ = this.voteArr.length - 1;
      var _loc2_;
      if(!isNaN(_loc3_))
      {
         _loc2_ = _loc3_;
         while(_loc2_ >= 0)
         {
            if(this.voteArr[_loc2_].fromID == fromID)
            {
               this.voteArr.splice(_loc2_,1);
            }
            _loc2_ = _loc2_ - 1;
         }
      }
      this.showVotes();
   }
   function showVotes()
   {
      var _loc6_ = this._parent.cy;
      var _loc4_;
      var _loc5_;
      var _loc3_ = 1;
      var _loc2_;
      while(_loc3_ <= 2)
      {
         _loc4_ = 0;
         _loc5_ = 0;
         _loc2_ = 0;
         while(_loc2_ < this.voteArr.length)
         {
            if(this.voteArr[_loc2_].forLane == _loc3_)
            {
               if(this.voteArr[_loc2_].isCheer == 0)
               {
                  _loc4_ = _loc4_ + 1;
               }
               else if(this.voteArr[_loc2_].isCheer == 1)
               {
                  _loc5_ = _loc5_ + 1;
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         this.raceOverlay["gaugeCheer" + _loc3_]._xscale = 100 * _loc4_ / _loc6_;
         this.raceOverlay["gaugeBoo" + _loc3_]._xscale = 100 * _loc5_ / _loc6_;
         _loc3_ = _loc3_ + 1;
      }
   }
   function traceVotes()
   {
      var _loc3_ = "";
      var _loc2_ = 0;
      while(_loc2_ < this.voteArr.length)
      {
         _loc3_ += " _ " + this.voteArr[_loc2_].forLane + ":" + this.voteArr[_loc2_].isCheer + ":" + this.voteArr[_loc2_].fromID;
         _loc2_ = _loc2_ + 1;
      }
      trace(_loc3_);
   }
   function getLaneByID(pid)
   {
      if(pid == this.racer1Obj.id)
      {
         return 1;
      }
      if(pid == this.racer2Obj.id)
      {
         return 2;
      }
      return undefined;
   }
   function tripWire(racerID, rt)
   {
      trace("tripWire [" + new Date().getTime() + "]");
      var raceTimesMC;
      var decimalPos;
      var rnum;
      if(racerID == this.racer1Obj.id)
      {
         raceTimesMC = this.raceOverlay.raceTimes1;
         this.racer1Obj.RT = rt;
         rnum = 1;
      }
      else if(racerID == this.racer2Obj.id)
      {
         raceTimesMC = this.raceOverlay.raceTimes2;
         this.racer2Obj.RT = rt;
         rnum = 2;
      }
      if(this.myLane)
      {
         raceTimesMC._visible = true;
      }
      with(raceTimesMC)
      {
         if(rt < 0)
         {
            if(rt == -1)
            {
               txtRT = "FOUL";
            }
            else if(rt == -2)
            {
               txtRT = "DNS";
            }
            if(!classes.Race._MC.myLane)
            {
               _root.raceSpectateCB("<i r=\"" + rnum + "\" t=\"0\" d=\"" + classes.Race["racer" + rnum + "Obj"].d + "\">");
            }
         }
         else
         {
            txtRT = classes.NumFuncs.zeroFill(rt,3);
         }
      }
      if(this.myLane || _global.chatObj.viewMC.isSpectator)
      {
         this.playEffect("launch",this.getLaneByID(racerID));
         if(racerID == classes.GlobalData.id)
         {
            this.tree._visible = false;
            _global.chatObj.raceObj.myObj.rt = rt;
         }
      }
   }
   function crossWire(racerID, et, ts)
   {
      trace("crossWire [" + new Date().getTime() + "]");
      trace("crossWire: " + racerID + ", " + et + ", " + ts);
      var _loc4_;
      var _loc3_;
      var _loc8_;
      if(classes.GlobalData.id == this.racer1Obj.id || classes.GlobalData.id == this.racer2Obj.id)
      {
         _loc8_ = true;
      }
      if(racerID == this.racer1Obj.id)
      {
         _loc3_ = this.raceOverlay.raceTimes1;
         this.racer1Obj.ET = et;
         this.racer1Obj.TS = ts;
         if(!this.racer1Obj.RT)
         {
            this.tripWire(racerID,-2);
         }
         _loc4_ = 1;
      }
      else if(racerID == this.racer2Obj.id)
      {
         _loc3_ = this.raceOverlay.raceTimes2;
         this.racer2Obj.ET = et;
         this.racer2Obj.TS = ts;
         if(!this.racer2Obj.RT)
         {
            this.tripWire(racerID,-2);
         }
         _loc4_ = 2;
      }
      if(racerID == classes.GlobalData.id)
      {
         _global.setTimeout(this.doEngineStop,2100);
         _global.chatObj.raceObj.myObj.et = et;
         _global.chatObj.raceObj.myObj.ts = ts;
      }
      _loc3_.holdET = "";
      _loc3_.holdTS = "";
      if(et != -1)
      {
         _loc3_.holdET = classes.NumFuncs.zeroFill(et,3);
         _loc3_.holdTS = classes.NumFuncs.zeroFill(ts,3);
      }
      _loc3_.txtET = _loc3_.holdET;
      _loc3_.txtTS = _loc3_.holdTS;
      _loc3_._visible = true;
      if(this["racer" + _loc4_ + "Obj"].bt && Number(this["racer" + _loc4_ + "Obj"].ET) > 0 && Number(this["racer" + _loc4_ + "Obj"].ET) < Number(this["racer" + _loc4_ + "Obj"].bt))
      {
         _loc3_.breakout.isOn = true;
         _loc3_.breakout._visible = true;
      }
      if(this.racer1Obj.ET != undefined && (this.racer2Obj.ET != undefined || !this.racer2Obj.id))
      {
         this.raceOverlay.finishOverlay._visible = true;
      }
      if(_loc8_)
      {
         this.winnerLightSI = _global.setTimeout(this,"showWinnerLight",2000);
      }
   }
   function showWinnerLight()
   {
      trace("showWinnerLight [" + new Date().getTime() + "]");
      var _loc3_ = 0;
      var _loc2_ = 0;
      var _loc5_;
      var _loc4_;
      if(Number(this.racer1Obj.bt) > 0 || Number(this.racer2Obj.bt) > 0)
      {
         _loc3_ = Number(this.racer1Obj.bt);
         _loc2_ = Number(this.racer2Obj.bt);
      }
      if(this.racer1Obj.ET != undefined && this.racer2Obj.ET != undefined)
      {
         if(this.racer1Obj.RT > -1 && this.racer2Obj.RT > -1 && this.racer1Obj.ET > -1 && this.racer2Obj.ET > -1)
         {
            if(!(_loc3_ && this.racer1Obj.ET < _loc3_ && _loc2_ && this.racer2Obj.ET < _loc2_))
            {
               _loc5_ = this.racer1Obj.RT + this.racer1Obj.ET - _loc3_;
               _loc4_ = this.racer2Obj.RT + this.racer2Obj.ET - _loc2_;
               if(_loc5_ < _loc4_ && this.racer1Obj.ET >= _loc3_)
               {
                  this.raceOverlay.finishLights2.prevFrame();
                  this.raceOverlay.finishLights1.nextFrame();
               }
               else if(_loc4_ < _loc5_ && this.racer2Obj.ET >= _loc2_)
               {
                  this.raceOverlay.finishLights1.prevFrame();
                  this.raceOverlay.finishLights2.nextFrame();
               }
            }
         }
      }
      else if(this.racer1Obj.RT > 0 && this.racer1Obj.ET > 0 && this.racer2Obj.RT <= 0)
      {
         this.raceOverlay.finishLights1.nextFrame();
      }
      else if(this.racer2Obj.RT > 0 && this.racer2Obj.ET > 0 && this.racer1Obj.RT <= 0)
      {
         this.raceOverlay.finishLights2.nextFrame();
      }
   }
   function doEngineStop()
   {
      _root.runEngineStop();
   }
   function spectatorRender(r, d, isRacing, v, a)
   {
      this["racer" + r + "Obj"].ld = this["racer" + r + "Obj"].d;
      this["racer" + r + "Obj"].d = d;
      this["racer" + r + "Obj"].v = v;
      this["racer" + r + "Obj"].a = a;
      if(this.racer1Obj.d <= this.racer2Obj.d)
      {
         this.amSpectator.rCam = 1;
         this.amSpectator.rOpp = 2;
         this.amSpectator.d = this.racer1Obj.d;
         this.amSpectator.v = this.racer1Obj.v;
         this.amSpectator.a = this.racer1Obj.a;
      }
      else
      {
         this.amSpectator.rCam = 2;
         this.amSpectator.rOpp = 1;
         this.amSpectator.d = this.racer2Obj.d;
         this.amSpectator.v = this.racer2Obj.v;
         this.amSpectator.a = this.racer2Obj.a;
      }
      this.amSpectator.bt = new Date();
      this.amSpectator.oppObj = this["racer" + this.amSpectator.rOpp + "Obj"];
      this.amSpectator.camObj = this["racer" + this.amSpectator.rCam + "Obj"];
      this.amSpectator.md = this.scaleLength;
   }
   function distanceInterpolator(r, d, isRacing, v)
   {
      if(amTrackInterp == undefined)
      {
         var amTrackInterp = this.createEmptyMovieClip("amTrackInterp",this.getNextHighestDepth());
      }
      amTrackInterp.r = r;
      if(!d)
      {
         d = -13;
      }
      amTrackInterp.d = d;
      amTrackInterp.isRacing = isRacing;
      amTrackInterp.v = v;
      amTrackInterp.lastTS = new Date();
      amTrackInterp.onEnterFrame = function()
      {
         trace("amTrackInterp");
         this.tt = (new Date() - this.lastTS) / 1000;
         this.newd = this.d + this.tt * this.v;
         if(this.d < 28)
         {
            if(this.d > 0)
            {
               this.gotoFrame = 1 + Math.floor(180 * this.newd / 28);
            }
            else
            {
               this.gotoFrame = 1;
            }
         }
         else
         {
            this.gotoFrame = 180 + Math.floor(869 * (this.d - 28) / 1292);
         }
         this._parent.screenEventShake.raceScreen.trackMov.straight.gotoAndStop(this.gotoFrame);
      };
   }
   function showTrackAtPos(d)
   {
      var _loc2_;
      if(d < 28)
      {
         if(d > 0)
         {
            _loc2_ = 1 + Math.floor(180 * d / 28);
         }
         else
         {
            _loc2_ = 1;
         }
      }
      else
      {
         _loc2_ = 180 + Math.floor(869 * (d - 28) / 1292);
      }
      if(_loc2_ != this.screenEventShake.raceScreen.trackMov.straight._currentframe)
      {
         this.screenEventShake.raceScreen.trackMov.straight.gotoAndStop(_loc2_);
      }
   }
   function setExtrapolate(r)
   {
      if(!this["amExtrapolate" + r])
      {
         this["amExtrapolate" + r] = this.createEmptyMovieClip("amExtrapolate" + r,this.getNextHighestDepth());
      }
      this["amExtrapolate" + r].its = new Date();
      this["amExtrapolate" + r].scaleLength = this.scaleLength;
      this["amExtrapolate" + r].r = r;
      this["amExtrapolate" + r].d = this["racer" + r + "Obj"].d;
      this["amExtrapolate" + r].v = this["racer" + r + "Obj"].v;
      this["amExtrapolate" + r].onEnterFrame = function()
      {
         this.dt = (new Date() - this.its) / 1000;
         var _loc4_ = this.d + this.v * this.dt;
         var _loc3_ = classes.Race._MC.trackLength - 1.487 * (_global.trackMovMC._currentframe - 1075);
         classes.Race._MC.renderCar(this.r,this.scaleLength + this.newD - this.camD);
         classes.Race._MC.gauge["car" + r]._y = (- this.newD / 1320) * classes.Race._MC.gauge.trackBar._height;
      };
   }
   function updateDistance(r, d, isRacing, v, a, t)
   {
      var _loc2_ = this["racer" + r + "Obj"];
      _loc2_.v = v;
      _loc2_.a = a;
      _loc2_.isRacing = isRacing;
      var _loc4_;
      var _loc7_;
      if(r == this.oppLane && !this.isCompRace)
      {
         _loc2_.raceOpp.addInt({t:t,d:d,v:v,a:a});
         _loc2_.lastTS = new Date();
         if(t)
         {
            _loc4_ = (_loc2_.tt - t) / 1000;
         }
         _loc4_ = !_loc4_ ? 0 : _loc4_;
         _loc7_ = d + Math.max(0,v * _loc4_ + 0.5 * a * _loc4_ * _loc4_);
         if(!isNaN(_loc7_))
         {
            _loc2_.nd = _loc7_;
         }
         if(_loc2_.tt)
         {
            _loc2_.nt = Math.max(t,_loc2_.tt);
         }
         else
         {
            _loc2_.nt = t;
         }
         _loc2_.dstep = 0;
      }
      else
      {
         _loc2_.d = d;
         _loc2_.t = t;
      }
      if(this.gaugeStaging._visible && r == this.myLane)
      {
         this.gaugeStaging.pointer._y = (- d / this.scaleLength) * this.gaugeStaging.stagingBar._height;
         if(d < -3)
         {
            this.gaugeStaging.pointer["pointer" + r].gotoAndStop(1);
         }
         else if(d < -2)
         {
            this.gaugeStaging.pointer["pointer" + r].gotoAndStop(2);
         }
         else if(d <= 0)
         {
            this.gaugeStaging.pointer["pointer" + r].gotoAndStop(3);
         }
         else
         {
            this.gaugeStaging.pointer["pointer" + r].gotoAndStop(4);
         }
      }
   }
   function updateSpectate(d1, d2, v1, v2, cts)
   {
      if(this.lastcts != cts && d1 < 1350 && d2 < 1350)
      {
      }
      var _loc6_;
      if(d1 || d1 === 0)
      {
         this.racer1Obj.d = d1;
      }
      if(d2 || d2 === 0)
      {
         this.racer2Obj.d = d2;
      }
      if(v1 || v1 === 0)
      {
         this.racer1Obj.v = v1;
      }
      if(v2 || v2 === 0)
      {
         this.racer2Obj.v = v2;
      }
      if(d1 < 13)
      {
         this.tree.showLight("pre1",d1 > -3 && d1 < 0);
         this.tree.showLight("staged1",d1 > -2 && d1 < 1);
      }
      if(d2 < 13)
      {
         this.tree.showLight("pre2",d2 > -3 && d2 < 0);
         this.tree.showLight("staged2",d2 > -2 && d2 < 1);
      }
      var _loc2_;
      var _loc5_;
      var _loc7_ = 25;
      var _loc10_ = 5;
      var _loc8_ = 200;
      if(this.racer1Obj.d > this.racer2Obj.d)
      {
         _loc2_ = 2;
         if(Math.abs(this.racer1Obj.d - this.racer2Obj.d) > _loc8_)
         {
            _loc2_ = 1;
         }
      }
      else
      {
         _loc2_ = 1;
         if(Math.abs(this.racer2Obj.d - this.racer1Obj.d) > _loc8_)
         {
            _loc2_ = 2;
         }
      }
      _loc5_ = _loc2_ % 2 + 1;
      if(this["racer" + _loc2_ + "Obj"].d < this["racer" + _loc5_ + "Obj"].d)
      {
         _loc7_ = 13;
      }
      var _loc9_ = Math.max(0,this["racer" + _loc2_ + "Obj"].d - _loc7_);
      this.dSpec = classes.Effects.getEasePoint(this.dSpec,_loc9_,35,_loc10_);
      this.dSpec = Math.min(this.dSpec,this.trackLength);
      if(this.dSpec < 28)
      {
         if(this.dSpec > 0)
         {
            this.renderCar(_loc2_,this.scaleLength + this["racer" + _loc2_ + "Obj"].d - this.dSpec);
            this.renderCar(_loc5_,this.scaleLength + this["racer" + _loc5_ + "Obj"].d - this.dSpec);
            _loc6_ = 1 + Math.floor(180 * this.dSpec / 28);
         }
         else
         {
            this.renderCar(1,this.racer1Obj.d + this.scaleLength);
            this.renderCar(2,this.racer2Obj.d + this.scaleLength);
         }
      }
      else
      {
         this.renderCar(_loc2_,this.scaleLength + this["racer" + _loc2_ + "Obj"].d - this.dSpec);
         this.renderCar(_loc5_,this.scaleLength + this["racer" + _loc5_ + "Obj"].d - this.dSpec);
         _loc6_ = 180 + Math.floor(869 * (this.dSpec - 28) / 1292);
      }
      this.turnWheels(1,this.racer1Obj.d);
      this.turnWheels(2,this.racer2Obj.d);
      if(_loc6_)
      {
         this.screenEventShake.raceScreen.trackMov.straight.gotoAndStop(_loc6_);
      }
      this.gauge.car1._y = (- this.racer1Obj.d / 1320) * this.gauge.trackBar._height;
      this.gauge.car2._y = (- this.racer2Obj.d / 1320) * this.gauge.trackBar._height;
   }
   function renderCar(r, diff)
   {
      var _loc2_ = 0;
      var _loc3_;
      var _loc4_;
      while(_loc2_ < this.scaleArrLength)
      {
         if(this.scaleArr[_loc2_].d < diff)
         {
            _loc3_ = this.scaleArr[_loc2_].s;
            if(_loc2_ > 0 && _loc2_ < this.scaleArrLength - 1)
            {
               _loc4_ = (diff - this.scaleArr[_loc2_].d) / (this.scaleArr[_loc2_ - 1].d - this.scaleArr[_loc2_].d);
               _loc3_ += _loc4_ * (this.scaleArr[_loc2_ - 1].s - this.scaleArr[_loc2_].s);
            }
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      this["car" + r]._xscale = _loc3_;
      this["car" + r]._yscale = Math.abs(this["car" + r]._xscale);
      this["car" + r]._visible = true;
   }
   function turnWheels(r, d)
   {
      if(this.myLane && classes.GlobalData.prefsObj.raceQuality <= 1 || !this.myLane && classes.GlobalData.prefsObj.spectateQuality <= 1)
      {
         return undefined;
      }
      var _loc4_ = 15;
      d += 13;
      var _loc2_ = this["car" + r].carAni_shift.carAni_Nitrous.carAni_speedJitter.carHolder.carBody;
      _loc2_.wheelR._visible = true;
      _loc2_.wheelF._visible = true;
      var _loc6_ = _loc2_.wheelR._totalframes;
      var _loc3_;
      var _loc7_;
      if(_loc2_.wheelR.d != undefined && d - _loc2_.wheelR.d > _loc4_ / 10.5)
      {
         _loc3_ = _loc2_.wheelR._currentframe + Math.ceil(_loc6_ * 2 / 5);
      }
      else
      {
         _loc7_ = d % _loc4_ / _loc4_;
         _loc3_ = 1 + Math.floor(_loc7_ * 360);
      }
      _loc3_ = 1 + _loc3_ % _loc6_;
      _loc2_.wheelF.gotoAndStop(_loc3_);
      _loc2_.wheelR.gotoAndStop(_loc3_);
      _loc2_.wheelR.d = d;
   }
   function hideWheels(r)
   {
      var _loc2_ = this["car" + r].carAni_shift.carAni_Nitrous.carAni_speedJitter.carHolder;
      _loc2_.tiresT._visible = false;
      _loc2_.tiresB._visible = false;
   }
   function onRaceStart()
   {
      trace("ONRACESTART ONRACESTART ONRACESTART ONRACESTART");
      this.voteBtns._visible = false;
      this.raceStarted = true;
      var _loc3_ = classes.Race._MC["racer" + this.oppLane + "Obj"];
      _loc3_.nt = 0;
      _loc3_.tt = 0;
      _loc3_.lastTS = new Date();
      this.tree.clearTimer();
      if(this.myLane == 1 || this.myLane == 2)
      {
         classes.Chat.disableWindow();
         _global.chatObj.raceRoomMC.optimizeBottom(false);
      }
      this.racerBubbles._visible = false;
   }
   function onRaceStartTime()
   {
      this.gauge._visible = true;
      this.gaugeStaging._visible = false;
   }
   function showFinish(delay)
   {
      trace("showFinish [" + new Date().getTime() + "]");
      if(this.showFinishFlag)
      {
         trace("showFinish Already Set");
         return undefined;
      }
      this.showFinishFlag = true;
      if(!delay)
      {
         delay = 6000;
      }
      this.raceOverlay.finishOverlay._visible = true;
      this.user1Info.badges._visible = false;
      this.user2Info.badges._visible = false;
      this.user1Info.updateCred(this.racer1Obj.sc);
      this.user2Info.updateCred(this.racer2Obj.sc);
      this.user1Info._visible = true;
      this.user2Info._visible = true;
      this.raceOverlay.SCChange.txt1 = this.racer1Obj.scc;
      this.raceOverlay.SCChange.txt2 = this.racer2Obj.scc;
      this.raceOverlay.SCChange._visible = true;
      var _loc3_ = new TextFormat();
      _loc3_.color = 16711680;
      _global.chatObj.raceObj.r1Obj.scc = Number(this.racer1Obj.scc);
      _global.chatObj.raceObj.r2Obj.scc = Number(this.racer2Obj.scc);
      var _loc4_;
      if(Number(this.wid) > 0)
      {
         _global.chatObj.wid = Number(this.wid);
         if(this.wid == this.racer1Obj.id)
         {
            this.raceOverlay.finishLights2.prevFrame();
            this.raceOverlay.finishLights1.nextFrame();
            this.raceOverlay.SCChange.txt1 = "+" + this.raceOverlay.SCChange.txt1;
            this.raceResultsOverlay.txtResults1 = "WINNER!";
            this.raceResultsOverlay.txtResults2 = "LOSER!";
            this.raceResultsOverlay.fldResults2.setTextFormat(_loc3_);
         }
         else if(this.wid == this.racer2Obj.id)
         {
            this.raceOverlay.finishLights1.prevFrame();
            this.raceOverlay.finishLights2.nextFrame();
            this.raceOverlay.SCChange.txt2 = "+" + this.raceOverlay.SCChange.txt2;
            this.raceResultsOverlay.txtResults1 = "LOSER!";
            this.raceResultsOverlay.txtResults2 = "WINNER!";
            this.raceResultsOverlay.fldResults1.setTextFormat(_loc3_);
         }
         if(_global.chatObj.raceRoomMC.isTeamRivals)
         {
            if(Number(this.wid) > 0)
            {
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
         }
      }
      else if(this.wid == -2)
      {
         _global.chatObj.wid = 0;
         this.raceResultsOverlay.txtResults1 = "FOUL";
         this.raceResultsOverlay.txtResults2 = "FOUL";
         this.raceResultsOverlay.fldResults1.setTextFormat(_loc3_);
         this.raceResultsOverlay.fldResults2.setTextFormat(_loc3_);
      }
      else
      {
         _global.chatObj.wid = 0;
         this.raceResultsOverlay.txtResults1 = "LOSE";
         this.raceResultsOverlay.txtResults2 = "LOSE";
         this.raceResultsOverlay.fldResults1.setTextFormat(_loc3_);
         this.raceResultsOverlay.fldResults2.setTextFormat(_loc3_);
      }
      if(_global.chatObj.raceObj.r1Obj.h == 1)
      {
         this.raceResultsOverlay.txtResults1 = "INVALID";
         this.raceResultsTimes.txt1 = "";
         this.raceResultsOverlay.fldResults1.setTextFormat(_loc3_);
      }
      if(_global.chatObj.raceObj.r2Obj.h == 1)
      {
         this.raceResultsOverlay.txtResults2 = "INVALID";
         this.raceResultsTimes.txt2 = "";
         this.raceResultsOverlay.fldResults2.setTextFormat(_loc3_);
      }
      if(_global.chatObj.raceRoomMC.isTeamRivals)
      {
         this.raceOverlay.SCChange._visible = false;
      }
      this.raceFinish();
      if(!_global.chatObj.raceRoomMC.isTeamRivals)
      {
         this.nextSI = _global.setTimeout(this.raceEnd,delay,this);
      }
   }
   function raceFinish()
   {
      trace("raceFinish [" + new Date().getTime() + "]");
      this.raceResultsTimes._visible = true;
      this.raceResultsOverlay._visible = true;
      trace(this.raceResultsOverlay);
   }
   function raceEnd(_obj)
   {
      trace("raceEnd [" + new Date().getTime() + "]");
      var _loc4_;
      if(_obj.nextSI)
      {
         clearInterval(_obj.nextSI);
         _root.raceSound.stopSound();
         _obj._parent.drawQueue();
         if(!_global.chatObj.raceRoomMC.container.victor)
         {
            _obj._parent.showKingInfo();
            _obj._parent.showContainer("raceNoWinner");
         }
         else if(_global.chatObj.roomType.substr(0,4) == "KOTH")
         {
            _obj._parent.showKingInfo();
            _obj._parent.showContainer("raceWinnerKOTH");
         }
         else if(_global.chatObj.roomType == "RIV" || _global.chatObj.roomType.substr(0,2) == "QM")
         {
            _loc4_ = Number(_global.chatObj.raceObj.bt);
            if(_loc4_ == -1)
            {
               _obj._parent.showContainer("raceAnnounceWin","pinks");
            }
            else if(_loc4_ > 0)
            {
               _obj._parent.showContainer("raceAnnounceWin","money");
            }
            else
            {
               _obj._parent.showContainer("raceAnnounceWin","friendly");
            }
         }
         else if(_global.chatObj.roomType.substr(0,2) == "HT")
         {
            classes.Control.htourneyMC.goWinOneAndContinue(Number(_global.chatObj.raceObj.bt));
         }
         else
         {
            _obj._parent.showWaiting();
         }
      }
      if(classes.RivalsChallengePanel._MC)
      {
         classes.RivalsChallengePanel._MC.drawIncomingList();
      }
      _global.chatObj.raceRoomMC.userListXML = _global.chatObj.userListXML;
      _global.chatObj.raceRoomMC.drawUserList();
      _global.chatObj.raceRoomMC.drawQueue();
   }
   function playEffect(fxName, lane)
   {
      if(classes.GlobalData.prefsObj.raceQuality < 3)
      {
         return undefined;
      }
      if(!lane)
      {
         lane = this.myLane;
      }
      switch(fxName)
      {
         case "launch":
            this.screenEventShake.raceScreen["carAni" + lane].gotoAndPlay("launchA");
            this.screenEventShake.gotoAndPlay("shakeLaunchA");
            break;
         case "nos":
            if(this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.carAni_Nitrous._currentframe == 1)
            {
               this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.carAni_Nitrous.gotoAndPlay(2);
            }
            this.screenEventShake.gotoAndPlay("shakeNitrous");
      }
      if(this["racer" + lane + "Obj"].v > 10 && this["racer" + lane + "Obj"].d > 0)
      {
         switch(fxName)
         {
            case "gear1":
               this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.gotoAndPlay("shiftA");
               this.screenEventShake.gotoAndPlay("shakeShiftA");
               return;
            case "gear2":
               this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.gotoAndPlay("shiftB");
               this.screenEventShake.gotoAndPlay("shakeShiftB");
               return;
            case "gear3":
               this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.gotoAndPlay("shiftC");
               this.screenEventShake.gotoAndPlay("shakeShiftC");
               return;
            default:
               this.screenEventShake.raceScreen["carAni" + lane].carAni_shift.gotoAndPlay("shiftC");
               return;
         }
      }
   }
   function setScreenJitter(vel, isRacing)
   {
      if(classes.GlobalData.prefsObj.raceQuality < 3)
      {
         return undefined;
      }
      if(!this.screenEventShake.baseY && this.screenEventShake.baseY !== 0)
      {
         this.screenEventShake.baseY = this.screenEventShake._y;
      }
      this.screenEventShake.vel = vel;
      this.screenEventShake.isRacing = true;
      if(!this.screenEventShake.cc)
      {
         this.screenEventShake.cc = 0;
      }
      this.screenEventShake.posArr = new Array(-1,1,-1,0);
      this.screenEventShake.onEnterFrame = function()
      {
         this.cc = this.cc + 1;
         if(this.vel < 6)
         {
            this._y = this.baseY;
            delete this.onEnterFrame;
         }
         else
         {
            this.cInt = 5 - Math.floor(4 * this.vel / 110);
            this.cInt = Math.max(this.cInt,1);
            if(this.cc >= this.cInt && this.isRacing)
            {
               if(Math.random() < 0.9)
               {
                  if(!this.pos)
                  {
                     this.pos = 0;
                  }
                  if(this.cInt == 1)
                  {
                     this._y = this.baseY + Math.min(this.cInt - 1,this.posArr[this.pos]);
                  }
                  else
                  {
                     this._y = this.baseY + this.posArr[this.pos];
                  }
                  this.pos = this.pos + 1;
                  if(this.pos >= this.posArr.length)
                  {
                     this.pos = 0;
                  }
               }
               this.cc = 0;
            }
         }
      };
   }
   function setCarBounce(r, vel)
   {
      if(classes.GlobalData.prefsObj.raceQuality < 3)
      {
         return undefined;
      }
      var carBody = this["car" + r].carAni_shift.carAni_Nitrous.carAni_speedJitter.carHolder.carBody;
      if(vel > 0)
      {
         carBody.amp = Math.max(1,3 - Math.floor(vel / 25));
      }
      else
      {
         carBody.amp = carBody.amp;
      }
      if(!carBody.baseY && carBody.baseY !== 0)
      {
         carBody.baseY = carBody._y;
      }
      carBody.tY = carBody.baseY - carBody.amp;
      carBody.vel = vel;
      carBody.freq = Math.max(2,70 - vel);
      carBody.sY = (carBody.baseY - carBody.tY) / carBody.freq;
      carBody.onEnterFrame = function()
      {
         with(this)
         {
            if(_y < tY)
            {
               dir = 1;
               _y = tY;
            }
            else if(_y > baseY)
            {
               dir = -1;
               _y = baseY;
            }
            if(!dir)
            {
               dir = -1;
            }
            if(this.vel > 0)
            {
               _y += dir * sY;
            }
         }
      };
   }
   function onScreenExit()
   {
      _root.runEngineStop();
      clearInterval(this.nextSI);
      clearInterval(this.winnerLightSI);
      clearInterval(this.stagingSI);
      _global.chatObj.raceRoomMC.bottomStatic.bmp.dispose();
   }
   static function checkChatMessage(senderName, msg)
   {
      if(_global.chatObj.raceRoomMC.isTeamRivals)
      {
         return undefined;
      }
      if(senderName == classes.Race._MC.racer1Obj.uName)
      {
         classes.Race.racerBubble(1,msg);
      }
      else if(senderName == classes.Race._MC.racer2Obj.uName)
      {
         classes.Race.racerBubble(2,msg);
      }
   }
   static function racerBubble(lane, msg)
   {
      var _loc1_;
      var _loc6_;
      var _loc5_;
      var _loc3_;
      if(lane && msg.length)
      {
         _loc1_ = classes.Race._MC.racerBubbles;
         _loc6_ = _loc1_.getNextHighestDepth();
         _loc5_ = {txt:msg,ww:148,lane:lane};
         if(lane == 2)
         {
            _loc5_._x = 612;
         }
         else
         {
            _loc5_._x = 40;
         }
         _loc3_ = _loc1_.attachMovie("racerBubble","racer" + lane + "Bubble" + _loc6_,_loc6_,_loc5_);
         for(var _loc4_ in _loc1_)
         {
            if(_loc4_.substr(0,12) == "racer" + lane + "Bubble" && _loc1_[_loc4_] != _loc3_)
            {
               _loc1_[_loc4_].anchor.removeMovieClip();
            }
         }
      }
   }
   static function racerBubbleMoveCB(skipBubble)
   {
      // Keep staging chat below the top chrome so both lanes can read it.
      var _loc5_ = 240;
      skipBubble._y = _loc5_ - skipBubble._height;
      var _loc3_ = skipBubble._height - skipBubble.anchor._height + 7;
      var _loc1_ = skipBubble._parent;
      for(var _loc4_ in _loc1_)
      {
         if(_loc4_.substr(0,12) == "racer" + skipBubble.lane + "Bubble" && _loc1_[_loc4_] != skipBubble)
         {
            _loc1_[_loc4_]._y -= _loc3_;
         }
      }
   }
   function hasLaunchControl(id, carXML)
   {
      var _loc3_ = false;
      trace("checking for launch controller");
      trace(carXML.firstChild.childNodes.length);
      trace(carXML);
      var _loc1_ = 0;
      while(_loc1_ < carXML.childNodes.length)
      {
         trace(carXML.childNodes[_loc1_]);
         trace(carXML.childNodes[_loc1_].attributes.ci);
         if(Number(carXML.childNodes[_loc1_].attributes["in"]) == 1)
         {
            trace(carXML.childNodes[_loc1_].attributes.ci);
            if(Number(carXML.childNodes[_loc1_].attributes.ci) == 166)
            {
               trace("launch controller found!");
               _loc3_ = true;
               break;
            }
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
}
