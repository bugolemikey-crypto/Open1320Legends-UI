class classes.RacePlay extends classes.Race
{
   var _parent;
   var amLive;
   var amSpectator;
   var createEmptyMovieClip;
   var dIntro;
   var getNextHighestDepth;
   var isSpectator;
   var myLane;
   var oppLane;
   var racer1Obj;
   var racer2Obj;
   var voteArr;
   static var _MC;
   function RacePlay()
   {
      super();
      trace("RacePlay Constructor");
      classes.RacePlay._MC = this;
      _root.raceSound.enableSound();
      this.voteArr = new Array();
      this.racer1Obj = new Object();
      this.racer1Obj.id = _global.chatObj.raceObj.r1Obj.id;
      this.racer1Obj.bt = _global.chatObj.raceObj.r1Obj.bt;
      this.racer1Obj.uName = _global.chatObj.raceObj.r1Obj.un;
      this.racer1Obj.sc = _global.chatObj.raceObj.r1Obj.sc;
      this.racer1Obj.d = -13;
      this.racer1Obj.nd = -13;
      this.racer1Obj.ld = -13;
      this.racer1Obj.td = -13;
      this.racer1Obj.v = 0;
      this.racer1Obj.a = 0;
      this.racer1Obj.t = 0;
      this.racer2Obj = new Object();
      this.racer2Obj.id = _global.chatObj.raceObj.r2Obj.id;
      this.racer2Obj.bt = _global.chatObj.raceObj.r2Obj.bt;
      this.racer2Obj.uName = _global.chatObj.raceObj.r2Obj.un;
      this.racer2Obj.sc = _global.chatObj.raceObj.r2Obj.sc;
      this.racer2Obj.d = -13;
      this.racer2Obj.nd = -13;
      this.racer2Obj.ld = -13;
      this.racer2Obj.td = -13;
      this.racer2Obj.v = 0;
      this.racer2Obj.a = 0;
      this.racer2Obj.t = 0;
      this._parent.racer1Obj = new Object();
      this._parent.racer1Obj.id = this.racer1Obj.id;
      this._parent.racer1Obj.uName = this.racer1Obj.uName;
      this._parent.racer2Obj = new Object();
      this._parent.racer2Obj.id = this.racer2Obj.id;
      this._parent.racer2Obj.uName = this.racer2Obj.uName;
      if(classes.GlobalData.id == this.racer1Obj.id)
      {
         this.myLane = 1;
         this.oppLane = 2;
      }
      else if(classes.GlobalData.id == this.racer2Obj.id)
      {
         this.myLane = 2;
         this.oppLane = 1;
      }
      if(this._parent.tourneyType == "tourneyA" || this._parent.tourneyType == "tourneyS" || this._parent.tourneyType == "tourneyP")
      {
         this.setAmComp();
      }
      else if(_global.chatObj.roomType == "PT")
      {
         this.setAmComp();
      }
      else if(this.myLane == 1 || this.myLane == 2)
      {
         trace("racePlay.myLane: " + this.myLane);
         if(_global.chatObj.roomType.substr(0,2) == "HT")
         {
            classes.Control.setMapButton("tourneyRacing");
         }
         else
         {
            classes.Control.setMapButton("racing");
         }
         if(!this.amLive)
         {
            this.setAmLive();
         }
      }
      else
      {
         trace("racePlay.... im a spectator");
         this.isSpectator = true;
         classes.Control.setMapButton("race");
         if(!this.amSpectator)
         {
            trace("racePlay... create amSpectator");
            this.amSpectator = this.createEmptyMovieClip("amSpectator",this.getNextHighestDepth());
            this.amSpectator.dIntro = 1331;
            this.amSpectator.onEnterFrame = function()
            {
               classes.RacePlay._MC.showTrackAtPos(this.dIntro);
               if(this.dIntro < 13)
               {
                  classes.RacePlay._MC.renderCar(1,classes.RacePlay._MC.racer1Obj.d + classes.RacePlay._MC.scaleLength - this.dIntro);
                  classes.RacePlay._MC.renderCar(2,classes.RacePlay._MC.racer2Obj.d + classes.RacePlay._MC.scaleLength - this.dIntro);
               }
               if(this.dIntro < 1)
               {
                  classes.RacePlay._MC.tree._visible = true;
               }
               this.dIntro = classes.Effects.getEasePoint(this.dIntro,0,30,3);
            };
         }
      }
   }
}
