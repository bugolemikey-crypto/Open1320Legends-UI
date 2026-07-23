class classes.RivalsChallengePanel extends MovieClip
{
   var betAmount;
   var betType;
   var brt1;
   var brt2;
   var bt;
   var guid;
   var oppCar;
   var oppID;
   var oppName;
   var panel;
   var selCar;
   var selCarXML;
   var selOppCarXML;
   static var _MC;
   static var arrList;
   function RivalsChallengePanel()
   {
      super();
      classes.RivalsChallengePanel._MC = this;
      this.init();
   }
   function init()
   {
      classes.RivalsChallengePanel.arrList = new Array();
      this.panel.cover.useHandCursor = false;
      var _loc10_ = 0;
      var _loc3_;
      var _loc4_;
      while(_loc10_ < _global.chatObj.challengesXML.firstChild.childNodes.length)
      {
         _loc3_ = _global.chatObj.challengesXML.firstChild.childNodes[_loc10_].attributes;
         _loc4_ = _loc3_.icid + "_" + _loc3_.cicid;
         classes.RivalsChallengePanel.arrList.push({idx:classes.RivalsChallengePanel.arrList.length,id:_loc4_,i:_loc3_.i,ci:_loc3_.ci,icid:_loc3_.icid,cicid:_loc3_.cicid,bt:_loc3_.bt,brt1:_loc3_.b});
         _loc10_ = _loc10_ + 1;
      }
      if(!classes.RivalsChallengePanel.arrList.length)
      {
         this.panel._visible = false;
      }
   }
   function CB_getTwoRacersCars(carPairXML)
   {
      trace("CB_getTwoRacersCars");
      var _loc3_ = carPairXML.firstChild.childNodes[0].attributes.i + "_" + carPairXML.firstChild.childNodes[1].attributes.i;
      var _loc2_ = 0;
      while(_loc2_ < classes.RivalsChallengePanel.arrList.length)
      {
         if(classes.RivalsChallengePanel.arrList[_loc2_].id == _loc3_)
         {
            classes.RivalsChallengePanel.arrList[_loc2_].car1XML = new XML(carPairXML.firstChild.childNodes[0].toString());
            classes.RivalsChallengePanel.arrList[_loc2_].car2XML = new XML(carPairXML.firstChild.childNodes[1].toString());
            classes.Drawing.carView(this.panel.rivalsList["item" + _loc3_].car1,classes.RivalsChallengePanel.arrList[_loc2_].car1XML,24);
            classes.Drawing.carView(this.panel.rivalsList["item" + _loc3_].car2,classes.RivalsChallengePanel.arrList[_loc2_].car2XML,24);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      false;
   }
   static function addChallenge(xmlStr)
   {
      var _loc3_ = new XML(xmlStr);
      if(!_global.chatObj.challengesXML)
      {
         _global.chatObj.challengesXML = new XML("<chall></chall>");
      }
      _global.chatObj.challengesXML.firstChild.appendChild(_loc3_.firstChild);
      var _loc2_ = _global.chatObj.challengesXML.firstChild.lastChild.attributes;
      var _loc4_ = _loc2_.icid + "_" + _loc2_.cicid;
      classes.RivalsChallengePanel.arrList.push({idx:classes.RivalsChallengePanel.arrList.length,id:_loc4_,i:_loc2_.i,ci:_loc2_.ci,icid:_loc2_.icid,cicid:_loc2_.cicid,bt:_loc2_.bt,brt1:_loc2_.b,guid:_loc2_.r});
      classes.RivalsChallengePanel._MC.drawIncomingList();
   }
   static function removeChallenge(id)
   {
      trace("removeChallenge: " + id);
      var _loc4_;
      var _loc2_ = 0;
      while(_loc2_ < _global.chatObj.challengesXML.firstChild.childNodes.length)
      {
         if(id == _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].attributes.icid + "_" + _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].attributes.cicid || id == _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].attributes.r)
         {
            _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].removeNode();
            _loc4_ = true;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < classes.RivalsChallengePanel.arrList.length)
      {
         if(id == classes.RivalsChallengePanel.arrList[_loc2_].id || id == classes.RivalsChallengePanel.arrList[_loc2_].guid)
         {
            _loc4_ = true;
            if(classes.RivalsChallengePanel._MC.viewingDetail && classes.RivalsChallengePanel._MC.oppCar == classes.RivalsChallengePanel.arrList[_loc2_].icid && classes.RivalsChallengePanel._MC.selCar == classes.RivalsChallengePanel.arrList[_loc2_].cicid)
            {
               classes.RivalsChallengePanel._MC.gotoAndPlay("cancel");
            }
            classes.RivalsChallengePanel.arrList.splice(_loc2_,1);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc4_ && !classes.RacePlay._MC.myLane)
      {
         classes.RivalsChallengePanel._MC.drawIncomingList();
      }
   }
   static function clearChallenges()
   {
      _global.chatObj.challengesXML = new XML("<chall></chall>");
      classes.RivalsChallengePanel._MC.drawIncomingList();
   }
   static function clearChallengesFrom(senderID)
   {
      trace("clearChallengesFrom: " + senderID);
      var _loc3_;
      var _loc4_ = _global.chatObj.challengesXML.firstChild.childNodes.length - 1;
      var _loc2_;
      if(!isNaN(_loc4_))
      {
         _loc2_ = _loc4_;
         while(_loc2_ >= 0)
         {
            _loc3_ = _global.chatObj.challengesXML.firstChild.childNodes[_loc2_];
            if(_loc3_.attributes.i == senderID)
            {
               classes.RivalsChallengePanel.removeChallenge(_loc3_.attributes.icid + "_" + _loc3_.attributes.cicid);
            }
            _loc2_ = _loc2_ - 1;
         }
      }
   }
   function drawIncomingList()
   {
      trace("drawIncomingList");
      if(classes.RacePlay._MC.myLane)
      {
         return undefined;
      }
      var _loc5_;
      var _loc4_;
      for(var _loc9_ in this.panel.rivalsList)
      {
         _loc5_ = false;
         _loc4_ = 0;
         while(_loc4_ < classes.RivalsChallengePanel.arrList.length)
         {
            if(classes.RivalsChallengePanel.arrList[_loc4_].id == this.panel.rivalsList[_loc9_].id)
            {
               _loc5_ = true;
            }
            _loc4_ = _loc4_ + 1;
         }
         if(!_loc5_)
         {
            trace("caught & remove: " + _loc9_);
            this.panel.rivalsList[_loc9_].removeMovieClip();
         }
      }
      var _loc3_ = 0;
      while(_loc3_ < classes.RivalsChallengePanel.arrList.length)
      {
         if(this.panel.rivalsList["item" + classes.RivalsChallengePanel.arrList[_loc3_].id] == undefined)
         {
            trace("creating: item" + classes.RivalsChallengePanel.arrList[_loc3_].id);
            this.panel.rivalsList.attachMovie("rivalsListItem","item" + classes.RivalsChallengePanel.arrList[_loc3_].id,this.panel.rivalsList.getNextHighestDepth(),{id:classes.RivalsChallengePanel.arrList[_loc3_].id,userName1:classes.Lookup.buddyName(classes.RivalsChallengePanel.arrList[_loc3_].i),userName2:classes.GlobalData.uname});
            this.panel.rivalsList["item" + classes.RivalsChallengePanel.arrList[_loc3_].id].btn.onRelease = function()
            {
               this._parent._parent._parent._parent.showDetail(this._parent.id);
            };
            classes.Lookup.addCallback("raceGetTwoRacersCars",this,this.CB_getTwoRacersCars,classes.RivalsChallengePanel.arrList[_loc3_].icid + "," + classes.RivalsChallengePanel.arrList[_loc3_].cicid);
            _root.raceGetTwoRacersCars(classes.RivalsChallengePanel.arrList[_loc3_].icid,classes.RivalsChallengePanel.arrList[_loc3_].cicid);
         }
         _loc3_ = _loc3_ + 1;
      }
      this.orderIncomingList();
   }
   function orderIncomingList()
   {
      var _loc4_ = 20;
      var _loc3_ = 0;
      while(_loc3_ < classes.RivalsChallengePanel.arrList.length)
      {
         this.panel.rivalsList["item" + classes.RivalsChallengePanel.arrList[_loc3_].id]._y = _loc3_ * _loc4_;
         _loc3_ = _loc3_ + 1;
      }
      var _loc5_ = _global.chatObj.challengesXML.firstChild.childNodes.length;
      if(!_loc5_)
      {
         _loc5_ = 0;
      }
      this.panel.txtCount = "(" + _loc5_ + ")";
      if(_loc5_ > 0)
      {
         this.panel._visible = true;
      }
      else if(this._currentframe == 1)
      {
         this.panel._visible = false;
      }
   }
   function showDetail(id)
   {
      var _loc2_ = 0;
      while(true)
      {
         if(_loc2_ >= classes.RivalsChallengePanel.arrList.length)
         {
            this.gotoAndPlay("detail");
            return;
         }
         addr158a:
         if(classes.RivalsChallengePanel.arrList[_loc2_].id == id)
         {
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.selOppCarXML = classes.RivalsChallengePanel.arrList[_loc2_].car1XML;
      this.selCarXML = classes.RivalsChallengePanel.arrList[_loc2_].car2XML;
      this.selCar = this.selCarXML.firstChild.attributes.i;
      this.oppCar = this.selOppCarXML.firstChild.attributes.i;
      this.oppID = classes.RivalsChallengePanel.arrList[_loc2_].i;
      this.oppName = classes.Lookup.buddyName(this.oppID);
      this.bt = Number(classes.RivalsChallengePanel.arrList[_loc2_].bt);
      this.brt1 = Number(classes.RivalsChallengePanel.arrList[_loc2_].brt1);
      this.brt2 = -1;
      this.guid = classes.RivalsChallengePanel.arrList[_loc2_].guid;
      switch(this.bt)
      {
         case -1:
            this.betType = 3;
            break;
         case 0:
            this.betType = 1;
            break;
         default:
            this.betType = 2;
            this.betAmount = Number(classes.RivalsChallengePanel.arrList[_loc2_].bt);
      }
      §§goto(addr158a);
   }
}
