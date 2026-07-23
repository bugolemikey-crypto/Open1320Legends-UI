class classes.TeamRivalsChallengePanel extends MovieClip
{
   var clr;
   var detailNode;
   var id;
   var panel;
   static var _MC;
   static var arrList;
   function TeamRivalsChallengePanel()
   {
      super();
      classes.TeamRivalsChallengePanel._MC = this;
      this.init();
   }
   function init()
   {
      this.panel.cover.useHandCursor = false;
      if(!_global.chatObj.challengesXML.firstChild.childNodes.length)
      {
         this.panel._visible = false;
      }
   }
   static function addChallenge(xmlStr)
   {
      var _loc2_ = new XML(xmlStr);
      if(!_global.chatObj.challengesXML)
      {
         _global.chatObj.challengesXML = new XML("<chall></chall>");
      }
      _global.chatObj.challengesXML.firstChild.appendChild(_loc2_.firstChild);
      classes.TeamRivalsChallengePanel._MC.drawIncomingList();
   }
   static function removeChallenge(id)
   {
      trace("removeChallenge: " + id);
      var _loc3_;
      var _loc2_ = 0;
      while(_loc2_ < _global.chatObj.challengesXML.firstChild.childNodes.length)
      {
         if(id == _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].attributes.id)
         {
            _global.chatObj.challengesXML.firstChild.childNodes[_loc2_].removeNode();
            _loc3_ = true;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc3_ && !classes.RacePlay._MC.myLane)
      {
         classes.TeamRivalsChallengePanel._MC.drawIncomingList();
      }
   }
   static function clearChallenges()
   {
      _global.chatObj.challengesXML = new XML("<chall></chall>");
      classes.TeamRivalsChallengePanel._MC.drawIncomingList();
   }
   static function clearChallengesFrom(uid)
   {
      trace("clearChallengesFrom: " + uid);
      var _loc3_;
      var _loc5_ = 0;
      var _loc2_;
      while(_loc5_ < _global.chatObj.challengesXML.firstChild.childNodes.length)
      {
         _loc3_ = _global.chatObj.challengesXML.firstChild.childNodes[_loc5_];
         if(_loc3_.attributes.ai1 == uid)
         {
            classes.TeamRivalsChallengePanel.removeChallenge(_loc3_.attributes.id);
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < _loc3_.childNodes.length)
            {
               if(_loc3_.childNodes[_loc2_].attributes.ai1 == uid || _loc3_.childNodes[_loc2_].attributes.ai2 == uid)
               {
                  classes.TeamRivalsChallengePanel.removeChallenge(_loc3_.attributes.id);
               }
               _loc2_ = _loc2_ + 1;
            }
         }
         _loc5_ = _loc5_ + 1;
      }
   }
   function drawIncomingList()
   {
      trace("drawIncomingList");
      if(classes.RacePlay._MC.myLane)
      {
         return undefined;
      }
      classes.TeamRivalsChallengePanel.arrList = _global.chatObj.challengesXML.firstChild.childNodes;
      var _loc6_;
      var _loc4_;
      for(var _loc13_ in this.panel.rivalsList)
      {
         _loc6_ = false;
         _loc4_ = 0;
         while(_loc4_ < classes.TeamRivalsChallengePanel.arrList.length)
         {
            if(classes.TeamRivalsChallengePanel.arrList[_loc4_].attributes.id == this.panel.rivalsList[_loc13_].id)
            {
               _loc6_ = true;
            }
            _loc4_ = _loc4_ + 1;
         }
         if(!_loc6_)
         {
            trace("caught & remove: " + _loc13_);
            this.panel.rivalsList[_loc13_].removeMovieClip();
         }
      }
      var _loc3_ = 0;
      var _loc5_;
      while(_loc3_ < classes.TeamRivalsChallengePanel.arrList.length)
      {
         if(this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id] == undefined)
         {
            trace("creating: item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id);
            _loc5_ = this.panel.rivalsList.attachMovie("teamRivalsListItem","item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id,this.panel.rivalsList.getNextHighestDepth(),{id:classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id,userName:classes.Lookup.buddyName(classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.ai1),teamName:this._parent.lookupTeamName(classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.ti1),teamID:classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.ti1});
            _loc5_._x = -3;
            classes.Drawing.portrait(_loc5_,classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.ai1,2,0,0,4,false,"teamavatars");
            _loc5_.photo._xscale = _loc5_.photo._yscale = 25;
            _loc5_.photo._x = 115;
            this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id].onRollOver = this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id].onDragOver = function()
            {
               this.clr = new Color(this);
               this.clr.setTransform({rb:80,gb:80,bb:80});
            };
            this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id].onRollOut = this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id].onDragOut = function()
            {
               this.clr.setTransform({rb:0,gb:0,bb:0});
            };
            this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc3_].attributes.id].onRelease = function()
            {
               this.clr.setTransform({rb:0,gb:0,bb:0});
               classes.TeamRivalsChallengePanel._MC.showDetail(this.id);
            };
            _loc5_.cacheAsBitmap = true;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.orderIncomingList();
   }
   function orderIncomingList()
   {
      var _loc4_ = 30;
      var _loc3_ = classes.TeamRivalsChallengePanel.arrList.length;
      if(!_loc3_)
      {
         _loc3_ = 0;
      }
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         this.panel.rivalsList["item" + classes.TeamRivalsChallengePanel.arrList[_loc2_].attributes.id]._y = _loc2_ * _loc4_;
         _loc2_ = _loc2_ + 1;
      }
      this.panel.txtCount = "(" + _loc3_ + ")";
      if(_loc3_ > 0)
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
      while(_loc2_ < classes.TeamRivalsChallengePanel.arrList.length)
      {
         trace(classes.TeamRivalsChallengePanel.arrList[_loc2_].attributes.id);
         if(classes.TeamRivalsChallengePanel.arrList[_loc2_].attributes.id == id)
         {
            this.detailNode = classes.TeamRivalsChallengePanel.arrList[_loc2_];
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.gotoAndPlay("detail");
   }
}
