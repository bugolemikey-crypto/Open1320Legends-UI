class classes.mc.TrackPractice extends MovieClip
{
   var carBox;
   var container;
   var containerMask;
   var selCarID;
   var selCarXML;
   var tutorialSelector;
   static var _mc;
   static var finishSI;
   function TrackPractice()
   {
      super();
      classes.mc.TrackPractice._mc = this;
      this.selCarXML = classes.GlobalData.getSelectedCarXML();
      this.selCarID = Number(this.selCarXML.attributes.i);
      this.carBox.btnDiffCar.hot.onRelease = function()
      {
         classes.Control.dialogContainer("dialogPickCarContent");
      };
   }
   function resetTrack()
   {
      trace("resetTrack");
      this.tutorialSelector._visible = false;
      this.showCar(this.selCarID,_global.chatObj.raceObj.myObj.rt,_global.chatObj.raceObj.myObj.et);
      this.container.onScreenExit();
      _global.chatObj = new Object();
      _global.chatObj.roomType = "PT";
      _global.chatObj.raceRoomMC = this;
      _global.chatObj.raceObj = new Object();
      _global.chatObj.raceObj.myObj = new Object();
      var _loc4_ = _global.chatObj.raceObj.myObj;
      _loc4_.cid = this.selCarID;
      _loc4_.id = classes.GlobalData.id;
      _loc4_.un = classes.GlobalData.uname;
      _loc4_.ti = classes.GlobalData.attr.ti;
      _loc4_.tn = classes.GlobalData.attr.tn;
      _loc4_.sc = classes.GlobalData.attr.sc;
      _global.chatObj.raceObj.r1Obj = _global.chatObj.raceObj.myObj;
      _global.chatObj.twoRacersCarsXML = new XML("<n2></n2>");
      var _loc5_ = new XML(this.selCarXML.toString());
      _global.chatObj.twoRacersCarsXML.firstChild.appendChild(_loc5_.firstChild);
      _root.raceSound.stopSound();
      _global.clearTimeout(classes.mc.TrackPractice.finishSI);
      this.showContainer("racePlay");
      classes.util.Tutorial._mc.swapDepths(this.getNextHighestDepth());
   }
   function showCar(acid, rt, et)
   {
      if(this.carBox.curCarID == acid)
      {
         if(rt == -1)
         {
            this.carBox.fldRT.text = "FOUL";
         }
         else if(rt > 0)
         {
            this.carBox.fldRT.text = classes.NumFuncs.zeroFill(rt,3);
         }
         else
         {
            this.carBox.fldRT.text = "--.---";
         }
         if(et == -1)
         {
            this.carBox.fldET.text = "FOUL";
         }
         else if(et > 0)
         {
            this.carBox.fldET.text = classes.NumFuncs.zeroFill(et,3);
         }
         else
         {
            this.carBox.fldET.text = "--.---";
         }
         return undefined;
      }
      this.carBox.fldRT.text = "--.---";
      this.carBox.fldET.text = "--.---";
      this.carBox.curCarID = acid;
      classes.ClipFuncs.removeAllClips(this.carBox.plateThumb);
      classes.Drawing.plateView(this.carBox.plateThumb,Number(this.selCarXML.attributes.pi),this.selCarXML.attributes.pn,25,true,true);
      this.carBox.carThumb.clearCarView();
      classes.Drawing.carView(this.carBox.carThumb,new XML(this.selCarXML.toString()),50);
   }
   function finishRace(et, ts)
   {
      this.container.crossWire(classes.GlobalData.id,et,ts);
      classes.mc.TrackPractice.finishSI = _global.setTimeout(this,"finishFinish",5000);
   }
   function finishFinish()
   {
      _root.raceSound.soundFadeOut();
   }
   function showContainer(linkName, type)
   {
      this.container.removeMovieClip();
      if(linkName.length)
      {
         this.container = this.attachMovie(linkName,"container",this.getNextHighestDepth(),{linkName:linkName,type:type});
      }
      if(this.containerMask == undefined)
      {
         this.containerMask = this.createEmptyMovieClip("containerMask",this.getNextHighestDepth());
         classes.Drawing.rect(this.containerMask,800,344,0,0);
      }
      this.container._x = 0;
      this.container._y = 0;
      this.container.setMask(this.containerMask);
   }
   function onRaceResults(xmlStr)
   {
      var _loc4_ = new XML(xmlStr);
      _global.chatObj.raceObj.lastResultsXML = _loc4_;
      _global.chatObj.raceObj.r1Obj.h = _loc4_.firstChild.attributes.h1;
      _global.chatObj.raceObj.r2Obj.h = _loc4_.firstChild.attributes.h2;
      if(_loc4_.firstChild.attributes.wid == "-2")
      {
         this.container.wid = -2;
         this.container.racer1Obj.RT = "FOUL";
         this.container.racer2Obj.RT = "FOUL";
         this.container.victor = 0;
      }
      else
      {
         this.container.wid = _loc4_.firstChild.attributes.wid;
         this.container.racer1Obj.RT = _loc4_.firstChild.attributes.rt1;
         this.container.racer2Obj.RT = _loc4_.firstChild.attributes.rt2;
         if(_loc4_.firstChild.attributes.wid == this.container.racer1Obj.id)
         {
            this.container.victor = 1;
         }
         else if(_loc4_.firstChild.attributes.wid == this.container.racer2Obj.id)
         {
            this.container.victor = -1;
         }
         else
         {
            this.container.victor = 0;
         }
      }
      this.container.racer1Obj.ET = _loc4_.firstChild.attributes.et1;
      this.container.racer1Obj.TS = _loc4_.firstChild.attributes.ts1;
      this.container.racer2Obj.ET = _loc4_.firstChild.attributes.et2;
      this.container.racer2Obj.TS = _loc4_.firstChild.attributes.ts2;
      this.container.racer1Obj.scc = _loc4_.firstChild.attributes.c1;
      this.container.racer2Obj.scc = _loc4_.firstChild.attributes.c2;
      this.container.racer1Obj.sc = Number(this.container.racer1Obj.sc) + Number(_loc4_.firstChild.attributes.c1);
      this.container.racer2Obj.sc = Number(this.container.racer2Obj.sc) + Number(_loc4_.firstChild.attributes.c2);
      if(classes.GlobalData.id == _loc4_.firstChild.attributes.r1id)
      {
         classes.GlobalData.updateInfo("sc",this.container.racer1Obj.sc);
         classes.GlobalData.updateInfo("m",Number(classes.GlobalData.attr.m) + Number(_loc4_.firstChild.attributes.m1));
         if(_global.chatObj.raceObj.bt == -1)
         {
            _root.getCars();
         }
      }
      else if(classes.GlobalData.id == _loc4_.firstChild.attributes.r2id)
      {
         classes.GlobalData.updateInfo("sc",this.container.racer2Obj.sc);
         classes.GlobalData.updateInfo("m",Number(classes.GlobalData.attr.m) + Number(_loc4_.firstChild.attributes.m2));
         if(_global.chatObj.raceObj.bt == -1)
         {
            _root.getCars();
         }
      }
      classes.Chat.enableWindow();
      classes.Control.setMapButton("race");
      if(classes.GlobalData.id == _loc4_.firstChild.attributes.r1id || classes.GlobalData.id == _loc4_.firstChild.attributes.r2id)
      {
         this.container.showFinish();
      }
      else
      {
         _global.setTimeout(this,"doShowFinish",5000);
      }
   }
   function doShowFinish()
   {
      this.container.showFinish(3000);
   }
}
