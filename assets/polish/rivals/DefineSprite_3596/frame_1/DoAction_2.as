function checkForData()
{
   trace("checkForData");
   if(_global.chatObj.userListXML != undefined && _global.chatObj.teamXML != undefined)
   {
      trace("made it!");
      userListXML = _global.chatObj.userListXML;
      teamXML = _global.chatObj.teamXML;
      createUserList();
      classes.Chat.createWindow(chatWindow,_global.newRoomName);
      classes.InterviewChat.createWindow(chatWindowInterview,_global.newRoomName);
      _root.GetElectionInterviewList();
   }
}
function userLeaves(uid)
{
   userList.scrollerContent["item" + uid].removeMovieClip();
   var _loc2_ = 0;
   while(_loc2_ < _global.chatObj.userListXML.firstChild.childNodes.length)
   {
      if(uid == _global.chatObj.userListXML.firstChild.childNodes[_loc2_].attributes.i)
      {
         _global.chatObj.userListXML.firstChild.childNodes[_loc2_].removeNode();
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = 0;
   while(_loc2_ < _global.chatObj.queueXML.firstChild.childNodes.length)
   {
      if(uid == _global.chatObj.queueXML.firstChild.childNodes[_loc2_].attributes.i || uid == _global.chatObj.queueXML.firstChild.childNodes[_loc2_].attributes.ci)
      {
         _global.chatObj.queueXML.firstChild.childNodes[_loc2_].removeNode();
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   classes.RivalsChallengePanel.clearChallengesFrom(uid);
}
function createUserList()
{
   if(userListGroup.scrollContent == undefined)
   {
      userListGroup.createEmptyMovieClip("scrollContent",1);
      userListGroup.scrollerObj = new controls.ScrollPane(userListGroup.scrollContent,333,232,null,null,322);
   }
   drawUserList();
}
function drawUserList()
{
   var _loc3_ = _global.chatObj.userListXML;
   var _loc10_;
   var _loc13_;
   var _loc4_;
   var _loc6_;
   for(var _loc21_ in userListGroup.scrollContent)
   {
      _loc10_ = false;
      if(_loc21_.indexOf("item") > -1)
      {
         _loc4_ = 0;
         while(_loc4_ < _loc3_.firstChild.childNodes.length)
         {
            if(userListGroup.scrollContent[_loc21_].userID == _loc3_.firstChild.childNodes[_loc4_].attributes.i)
            {
               _loc10_ = true;
               break;
            }
            _loc4_ = _loc4_ + 1;
         }
      }
      else if(_loc21_.indexOf("team") > -1)
      {
         _loc13_ = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_.firstChild.childNodes.length)
         {
            if(userListGroup.scrollContent[_loc21_].teamID == _loc3_.firstChild.childNodes[_loc6_].attributes.ti)
            {
               _loc13_ = _loc13_ + 1;
            }
            _loc6_ = _loc6_ + 1;
         }
         if(_loc13_ > 1)
         {
            _loc10_ = true;
         }
      }
      if(!_loc10_)
      {
         userListGroup.scrollContent[_loc21_].removeMovieClip();
      }
   }
   var _loc7_;
   var _loc5_;
   var _loc12_;
   var _loc9_ = new Array();
   var _loc11_;
   _loc4_ = 0;
   var _loc8_;
   var _loc15_;
   var _loc14_;
   while(_loc4_ < _loc3_.firstChild.childNodes.length)
   {
      if(!userListGroup.scrollContent["item" + _loc3_.firstChild.childNodes[_loc4_].attributes.i])
      {
         _loc8_ = userListGroup.scrollContent.attachMovie("userListItem","item" + _loc3_.firstChild.childNodes[_loc4_].attributes.i,userListGroup.scrollContent.getNextHighestDepth(),{_x:190,_y:80,userID:_loc3_.firstChild.childNodes[_loc4_].attributes.i,userName:_loc3_.firstChild.childNodes[_loc4_].attributes.un,tf:_loc3_.firstChild.childNodes[_loc4_].attributes.tf});
         _loc15_ = classes.Lookup.getMemberColor(Number(_loc3_.firstChild.childNodes[_loc4_].attributes.ms));
         _loc14_ = new TextFormat();
         _loc14_.color = _loc15_;
         _loc8_.fld.setTextFormat(_loc14_);
         classes.Drawing.portrait(_loc8_,_loc3_.firstChild.childNodes[_loc4_].attributes.i,2,0,0,4);
         _loc7_ = _loc8_.photo;
         _loc7_._xscale = 25;
         _loc7_._yscale = 25;
         _loc7_._x = 100;
         _loc8_.onRelease = function()
         {
            classes.Console.openProfileCard(this.userID,this.userName);
         };
         if(_loc3_.firstChild.childNodes[_loc4_].attributes.iv == 1)
         {
            _loc8_._alpha = 50;
         }
      }
      _loc5_ = Number(_loc3_.firstChild.childNodes[_loc4_].attributes.ti);
      if(_loc5_ && !userListGroup.scrollContent["team" + _loc5_])
      {
         _loc11_ = false;
         _loc6_ = 0;
         while(_loc6_ < _loc9_.length)
         {
            if(_loc5_ == _loc9_[_loc6_])
            {
               _loc11_ = true;
            }
            _loc6_ = _loc6_ + 1;
         }
         if(!_loc11_)
         {
            _loc9_.push(_loc5_);
         }
         else
         {
            _loc12_ = "";
            _loc6_ = 0;
            while(_loc6_ < teamXML.firstChild.childNodes.length)
            {
               if(teamXML.firstChild.childNodes[_loc6_].attributes.i == _loc5_)
               {
                  _loc12_ = teamXML.firstChild.childNodes[_loc6_].attributes.n;
                  break;
               }
               _loc6_ = _loc6_ + 1;
            }
            userListGroup.scrollContent.attachMovie("teamListItem","team" + _loc5_,userListGroup.scrollContent.getNextHighestDepth(),{_x:40,teamID:_loc5_,teamName:_loc12_});
            classes.Drawing.portrait(userListGroup.scrollContent["team" + _loc5_],0,2,0,0,4);
            _loc7_ = userListGroup.scrollContent["team" + _loc5_].photo;
            _loc7_._xscale = 25;
            _loc7_._yscale = 25;
         }
      }
      _loc4_ = _loc4_ + 1;
   }
   orderUserList();
}
function orderUserList()
{
   var userListXML = _global.chatObj.userListXML;
   userListGroup.scrollContent.clear();
   var vMargin = 9;
   var vSpace = 24;
   var orderArr = new Array();
   var rightOrderArr = new Array();
   var i = 0;
   while(i < userListXML.firstChild.childNodes.length)
   {
      orderArr.push({id:userListXML.firstChild.childNodes[i].attributes.i,teamID:userListXML.firstChild.childNodes[i].attributes.ti,uName:userListXML.firstChild.childNodes[i].attributes.un});
      i++;
   }
   orderArr.sortOn(["teamID","uName"],[Array.NUMERIC,Array.CASEINSENSITIVE]);
   var yPointerL = -10;
   var yPointerR = vMargin;
   var tCounter;
   var cTeamID;
   var cTeamTop;
   i = 0;
   while(i < orderArr.length)
   {
      if(orderArr[i].teamID && userListGroup.scrollContent["team" + orderArr[i].teamID] != undefined)
      {
         if(cTeamID != orderArr[i].teamID)
         {
            if(cTeamID)
            {
               yPointerL += 10;
               classes.Drawing.rect(userListGroup.scrollContent,164,yPointerL - cTeamTop,16777215,15,10,cTeamTop,8,1,16777215,40);
            }
            cTeamID = orderArr[i].teamID;
            yPointerL += 17;
            userListGroup.scrollContent["team" + cTeamID]._y = yPointerL;
            yPointerL += 17;
            cTeamTop = yPointerL;
            yPointerL += 8;
         }
         userListGroup.scrollContent["item" + orderArr[i].id]._y = yPointerL;
         userListGroup.scrollContent["item" + orderArr[i].id]._x = 41;
         yPointerL += vSpace;
      }
      else
      {
         rightOrderArr.push(orderArr[i]);
      }
      userListGroup.scrollContent["item" + orderArr[i].id].swapDepths(0);
      userListGroup.scrollContent["item" + orderArr[i].id].swapDepths(i + 1);
      i++;
   }
   if(cTeamID)
   {
      yPointerL += 10;
      classes.Drawing.rect(userListGroup.scrollContent,164,yPointerL - cTeamTop,16777215,15,10,cTeamTop,8,1,16777215,40);
   }
   rightOrderArr.sortOn("uName",Array.CASEINSENSITIVE);
   i = 0;
   while(i < orderArr.length)
   {
      userListGroup.scrollContent["item" + rightOrderArr[i].id]._y = yPointerR;
      userListGroup.scrollContent["item" + rightOrderArr[i].id]._x = 190;
      yPointerR += vSpace;
      userListGroup.scrollContent["item" + rightOrderArr[i].id].swapDepths(0);
      userListGroup.scrollContent["item" + rightOrderArr[i].id].swapDepths(i + 1);
      i++;
   }
   with(userListGroup.scrollContent)
   {
      moveTo(0,0);
      beginFill(0,0);
      lineTo(10,0);
      lineTo(10,_height + vMargin);
      endFill();
   }
   userListGroup.scrollerObj.refreshScroller();
}
function removeUser(uID)
{
   var _loc2_ = 0;
   while(_loc2_ < _global.chatObj.userListXML.firstChild.childNodes.length)
   {
      if(uID == _global.chatObj.userListXML.firstChild.childNodes[_loc2_].attributes.i)
      {
         _global.chatObj.userListXML.firstChild.childNodes[_loc2_].removeNode();
         drawUserList();
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
}
function addUser(userID, userName, teamID)
{
   var _loc3_;
   var _loc2_;
   if(userID && userName.length)
   {
      _loc3_ = new XML();
      _loc2_ = _loc3_.createElement("u");
      _loc2_.attributes.i = userID;
      _loc2_.attributes.un = userName;
      _loc2_.attributes.ti = teamID;
      _global.chatObj.userListXML.firstChild.appendChild(_loc2_);
      drawUserList();
   }
}
function lookupUserName(uid)
{
   return classes.Lookup.buddyName(uid);
}
function lookupTeamID(uid)
{
   var _loc2_ = 0;
   while(_loc2_ < _global.chatObj.userListXML.firstChild.childNodes.length)
   {
      if(_global.chatObj.userListXML.firstChild.childNodes[_loc2_].attributes.i == uid)
      {
         return Number(_global.chatObj.userListXML.firstChild.childNodes[_loc2_].attributes.ti);
      }
      _loc2_ = _loc2_ + 1;
   }
   return 0;
}
function lookupTeamName(tid)
{
   var _loc3_ = "";
   var _loc2_ = 0;
   while(_loc2_ < _global.chatObj.teamXML.firstChild.childNodes.length)
   {
      if(_global.chatObj.teamXML.firstChild.childNodes[_loc2_].attributes.i == tid)
      {
         _loc3_ = _global.chatObj.teamXML.firstChild.childNodes[_loc2_].attributes.n;
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   return _loc3_;
}
function drawQueue(raceInProgress)
{
   var queueXML = _global.chatObj.queueXML;
   var _loc6_ = _global.chatObj.userListXML;
   var _loc21_ = 20;
   var _loc23_ = queueXML.firstChild.childNodes.length;
   var _loc13_ = 7;
   if(container.linkName == "raceAnnounce" || container.linkName == "racePlay")
   {
      raceInProgress = true;
   }
   if(!_loc23_)
   {
      queueGroup._visible = false;
   }
   else
   {
      queueGroup._visible = true;
   }
   _loc13_ = Math.min(_loc13_,_loc23_);
   var _loc7_;
   var _loc8_;
   var _loc4_;
   var _loc10_;
   var _loc9_;
   var _loc5_;
   var _loc12_;
   var _loc11_;
   if(!classes.RacePlay._MC.myLane)
   {
      _loc7_ = false;
      _loc8_ = new Array();
      var tID;
      for(var _loc22_ in queueGroup)
      {
         if(_loc22_.indexOf("queueItem") > -1)
         {
            _loc7_ = false;
            _loc4_ = 0;
            while(_loc4_ < _loc13_)
            {
               tID = queueXML.firstChild.childNodes[_loc4_].attributes.icid + "_" + queueXML.firstChild.childNodes[_loc4_].attributes.cicid;
               if(queueGroup[_loc22_].id == tID)
               {
                  _loc7_ = true;
                  _loc8_.push(tID);
                  break;
               }
               _loc4_ = _loc4_ + 1;
            }
            if(!_loc7_)
            {
               queueGroup[_loc22_].removeMovieClip();
            }
         }
      }
      _loc4_ = 0;
      while(_loc4_ < _loc13_)
      {
         tID = queueXML.firstChild.childNodes[_loc4_].attributes.icid + "_" + queueXML.firstChild.childNodes[_loc4_].attributes.cicid;
         _loc7_ = false;
         _loc5_ = 0;
         while(_loc5_ < _loc8_.length)
         {
            if(_loc8_[_loc5_] == tID)
            {
               _loc7_ = true;
               break;
            }
            _loc5_ = _loc5_ + 1;
         }
         if(!_loc7_)
         {
            _loc10_ = "";
            _loc9_ = "";
            _loc5_ = 0;
            while(_loc5_ < _loc6_.firstChild.childNodes.length)
            {
               if(queueXML.firstChild.childNodes[_loc4_].attributes.i == _loc6_.firstChild.childNodes[_loc5_].attributes.i)
               {
                  _loc10_ = _loc6_.firstChild.childNodes[_loc5_].attributes.un;
               }
               if(queueXML.firstChild.childNodes[_loc4_].attributes.ci == _loc6_.firstChild.childNodes[_loc5_].attributes.i)
               {
                  _loc9_ = _loc6_.firstChild.childNodes[_loc5_].attributes.un;
               }
               _loc5_ = _loc5_ + 1;
            }
            _loc12_ = queueGroup.attachMovie("rivalsListItem","queueItem" + tID,queueGroup.getNextHighestDepth(),{id:tID,uID1:queueXML.firstChild.childNodes[_loc4_].attributes.i,userName1:_loc10_,carID1:queueXML.firstChild.childNodes[_loc4_].attributes.icid,uID2:queueXML.firstChild.childNodes[_loc4_].attributes.ci,carID2:queueXML.firstChild.childNodes[_loc4_].attributes.cicid,userName2:_loc9_});
            _loc12_.car1.onRelease = function()
            {
               classes.Control.focusViewer(this._parent.uID1,this._parent.carID1);
            };
            _loc12_.car2.onRelease = function()
            {
               classes.Control.focusViewer(this._parent.uID2,this._parent.carID2);
            };
            _loc11_ = function(d, carID)
            {
               var _loc1_ = 0;
               while(_loc1_ < queueXML.firstChild.childNodes.length)
               {
                  if(carID == queueXML.firstChild.childNodes[_loc1_].attributes.icid)
                  {
                     classes.Drawing.carView(queueGroup["queueItem" + tID].car1,new XML(d),24);
                     break;
                  }
                  if(carID == queueXML.firstChild.childNodes[_loc1_].attributes.cicid)
                  {
                     classes.Drawing.carView(queueGroup["queueItem" + tID].car2,new XML(d),24);
                     break;
                  }
                  _loc1_ = _loc1_ + 1;
               }
            };
            classes.Lookup.addCallback("getRacersCars",this,_loc11_,String(queueXML.firstChild.childNodes[_loc4_].attributes.icid));
            classes.Lookup.addCallback("getRacersCars",this,_loc11_,String(queueXML.firstChild.childNodes[_loc4_].attributes.cicid));
            _root.getRacersCars(queueXML.firstChild.childNodes[_loc4_].attributes.icid + "," + queueXML.firstChild.childNodes[_loc4_].attributes.cicid);
         }
         queueGroup["queueItem" + tID]._y = _loc4_ * _loc21_;
         _loc4_ = _loc4_ + 1;
      }
      if(_loc23_ > _loc13_)
      {
         queueGroup.txtTotal = "..." + _loc23_;
      }
      else
      {
         queueGroup.txtTotal = "";
      }
   }
}
function updateQueue(d, remove)
{
   var _loc2_ = new XML(d);
   var _loc4_ = _loc2_.firstChild.attributes.icid;
   var _loc3_ = _loc2_.firstChild.attributes.cicid;
   if(remove)
   {
      removeQueueNode(_loc4_,_loc3_);
   }
   else
   {
      _global.chatObj.queueXML.firstChild.appendChild(_loc2_.firstChild);
   }
   drawQueue();
}
function removeQueueNode(car1ID, car2ID)
{
   var _loc2_ = 0;
   while(_loc2_ < _global.chatObj.queueXML.firstChild.childNodes.length)
   {
      if(_global.chatObj.queueXML.firstChild.childNodes[_loc2_].attributes.icid == car1ID && _global.chatObj.queueXML.firstChild.childNodes[_loc2_].attributes.cicid == car2ID)
      {
         _global.chatObj.queueXML.firstChild.childNodes[_loc2_].removeNode();
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
}
function optimizeBottom(isVisible)
{
   trace("optimizeBottom...");
   var _loc4_;
   var _loc2_;
   if(isVisible)
   {
      bottomStatic.bmp.dispose();
      bottomStatic.removeMovieClip();
      delete bottomStatic;
   }
   else if(!bottomStatic)
   {
      bottomStatic = this.createEmptyMovieClip("bottomStatic",this.getNextHighestDepth());
      bottomStatic._y = 344;
      bottomStatic.bmp.dispose();
      bottomStatic.bmp = new flash.display.BitmapData(800,256,false,0);
      _loc4_ = new flash.geom.Matrix(1,0,0,1,0,-344);
      _loc2_ = new flash.geom.ColorTransform(0.5,0.5,0.5,1,0,0,0,0);
      bottomStatic.bmp.draw(btmBG,new flash.geom.Matrix(),_loc2_,"normal");
      bottomStatic.bmp.draw(usersBG,new flash.geom.Matrix(1,0,0,1,usersBG._x,usersBG._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(userListHeads,new flash.geom.Matrix(1,0,0,1,userListHeads._x,userListHeads._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(userListGroup,new flash.geom.Matrix(1,0,0,1,userListGroup._x,userListGroup._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(chatWindow,new flash.geom.Matrix(1,0,0,1,chatWindow._x,chatWindow._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(queueGroup,new flash.geom.Matrix(1,0,0,1,queueGroup._x,queueGroup._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(panelOut,new flash.geom.Matrix(1,0,0,1,panelOut._x,panelOut._y - btmBG._y),_loc2_,"normal");
      bottomStatic.bmp.draw(panelIn,new flash.geom.Matrix(1,0,0,1,panelIn._x,panelIn._y - btmBG._y),_loc2_,"normal");
      bottomStatic.attachBitmap(bottomStatic.bmp,1);
   }
   btmBG._visible = isVisible;
   userListGroup._visible = isVisible;
   chatWindow._visible = isVisible;
   queueGroup._visible = isVisible;
   usersBG._visible = isVisible;
   panelOut._visible = isVisible;
   panelIn._visible = isVisible;
   userListHeads._visible = isVisible;
}
function showChallengerNew(showSecond)
{
   _root.abc.closeMe();
   _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogRivalNewContent"});
   _root.abc.dialog = "dialogRivalNew";
   classes.ClipFuncs.newClip(_root.abc.contentMC,"viewLogo",24,158,50);
   classes.Drawing.carLogo(_root.abc.contentMC.viewLogo,_global.chatObj.myRaceCarNode.attributes.ci);
   classes.ClipFuncs.newClip(_root.abc.contentMC,"viewThumb",250,132);
   classes.Drawing.carView(_root.abc.contentMC.viewThumb,new XML(_global.chatObj.myRaceCarNode.toString()),28,"front");
   classes.ClipFuncs.newClip(_root.abc.contentMC,"viewPlate",27,193);
   classes.Drawing.plateView(_root.abc.contentMC.viewPlate,Number(_global.chatObj.myRaceCarNode.attributes.pi),_global.chatObj.myRaceCarNode.attributes.pn,30,true);
   with(_root.abc.contentMC)
   {
      btnChicken._visible = false;
      btnStage.btnLabel.text = "OK";
      btnChicken.btnLabel.text = "Chicken Out";
      timer._visible = false;
      bet = 0;
   }
   _root.abc.contentMC.btnStage.onRelease = function()
   {
      this._parent._parent.closeMe();
   };
   _root.abc.contentMC.btnChicken.onRelease = function()
   {
      clearInterval(this._parent.timer.countSI);
      _root.chatRIVLeave();
      this._parent._parent.closeMe();
      showChickenOut();
   };
   if(showSecond)
   {
      showChallengerNew2();
   }
}
function showChallengerNew2()
{
   if(_root.abc.dialog == "dialogRivalNew")
   {
      _root.abc.dialog = "dialogRivalNew";
      with(_root.abc.contentMC)
      {
         btnStage.btnLabel.text = "Stage Up";
         btnStage.onRelease = function()
         {
            clearInterval(this._parent.timer.countSI);
            _root.raceRIVOK();
            this._parent._parent.closeMe();
         };
         btnChicken._visible = true;
         txtMsg = "This is your last chance to back out of this race without penalty.  Stage Up to continue or Chicken Out!";
      }
      onTimeOut = function()
      {
         _global.chatObj.raceRoomMC.showTimedOut();
      };
      var tReduce = 2;
      if(_global.chatObj.newRaceTS)
      {
         tReduce += Math.ceil((new Date() - _global.chatObj.newRaceTS) / 1000);
      }
      _root.abc.addTimer(_global.chatObj.raceObj.timeToRespond - tReduce,onTimeOut);
   }
   else
   {
      showChallengerNew(true);
   }
}
function showChickenOut()
{
   _root.abc.closeMe();
   _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogChickenOutContent"});
   _root.abc.addButton("OK");
   optimizeBottom(true);
}
function showTimedOut()
{
   _root.abc.closeMe();
   _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTimedOutContent"});
   _root.abc.addButton("OK");
   optimizeBottom(true);
}
function showContainer(linkName, type)
{
   this.container.removeMovieClip();
   var _loc3_;
   if(linkName.length)
   {
      this.attachMovie(linkName,"container",this.getNextHighestDepth(),{linkName:linkName,type:type});
   }
   else
   {
      _loc3_ = Number(_global.chatObj.raceObj.bt);
      if(_loc3_ == -1)
      {
         type = "pinks";
      }
      else if(_loc3_ > 0)
      {
         type = "money";
      }
      else
      {
         type = "friendly";
      }
      this.attachMovie("raceAnnounce","container",this.getNextHighestDepth(),{linkName:"raceAnnounce",type:type});
   }
   if(containerMask == undefined)
   {
      this.createEmptyMovieClip("containerMask",this.getNextHighestDepth());
      classes.Drawing.rect(containerMask,800,344,0,0);
   }
   container._x = 0;
   container._y = 0;
   container.setMask(containerMask);
   container.swapDepths(panelOut);
   panelIn.swapDepths(this.getNextHighestDepth());
}
function CB_listUsers()
{
   var _loc8_ = new Array();
   var _loc6_ = new Array();
   var _loc10_;
   var _loc4_ = 0;
   while(_loc4_ < _global.chatObj.userListXML.firstChild.childNodes.length)
   {
      _loc10_ = Number(_global.chatObj.userListXML.firstChild.childNodes[_loc4_].attributes.ti);
      if(_loc10_)
      {
         _loc8_.push(_loc10_);
      }
      _loc4_ = _loc4_ + 1;
   }
   var _loc7_;
   var _loc11_;
   var _loc9_;
   var _loc12_;
   var _loc5_;
   var _loc13_;
   if(_loc8_.length)
   {
      _loc8_.sort();
      _loc7_ = new Array();
      _loc4_ = 0;
      while(_loc4_ < _global.chatObj.teamsXML.firstChild.childNodes.length)
      {
         _loc7_.push(_global.chatObj.teamsXML.firstChild.childNodes[_loc4_].attributes.i);
         _loc4_ = _loc4_ + 1;
      }
      _loc4_ = 0;
      while(_loc4_ < _loc8_.length)
      {
         if(!_loc11_ || _loc6_[_loc6_.length - 1] != _loc11_)
         {
            _loc6_.push(_loc8_[_loc4_]);
         }
         _loc11_ = _loc8_[_loc4_];
         _loc4_ = _loc4_ + 1;
      }
      _loc12_ = _loc6_.length - 1;
      _loc4_ = _loc12_;
      while(_loc4_ >= 0)
      {
         _loc9_ = false;
         _loc5_ = 0;
         while(_loc5_ < _loc7_.length)
         {
            if(_loc6_[_loc4_] == _loc7_[_loc5_])
            {
               _loc9_ = true;
            }
            _loc5_ = _loc5_ + 1;
         }
         if(_loc9_)
         {
            _loc6_.splice(_loc4_,1);
         }
         _loc4_ = _loc4_ - 1;
      }
      if(_loc6_.length)
      {
         _loc13_ = function(d)
         {
            _global.chatObj.teamXML = new XML(d);
            checkForData();
         };
         delete _global.chatObj.teamXML;
         classes.Lookup.addCallback("teamInfo",this,_loc13_,"");
         _root.teamInfo(_loc6_.toString());
      }
      else
      {
         _global.chatObj.teamXML = new XML();
         checkForData();
      }
   }
   else
   {
      _global.chatObj.teamXML = new XML();
      checkForData();
   }
}
function onRaceResults(xmlStr)
{
   var _loc4_ = new XML(xmlStr);
   _global.chatObj.raceObj.lastResultsXML = _loc4_;
   _global.chatObj.raceObj.r1Obj.h = _loc4_.firstChild.attributes.h1;
   _global.chatObj.raceObj.r2Obj.h = _loc4_.firstChild.attributes.h2;
   if(_loc4_.firstChild.attributes.wid == "-2")
   {
      container.wid = -2;
      container.racer1Obj.RT = "FOUL";
      container.racer2Obj.RT = "FOUL";
      container.victor = 0;
   }
   else
   {
      container.wid = _loc4_.firstChild.attributes.wid;
      container.racer1Obj.RT = _loc4_.firstChild.attributes.rt1;
      container.racer2Obj.RT = _loc4_.firstChild.attributes.rt2;
      if(_loc4_.firstChild.attributes.wid == container.racer1Obj.id)
      {
         container.victor = 1;
      }
      else if(_loc4_.firstChild.attributes.wid == container.racer2Obj.id)
      {
         container.victor = -1;
      }
      else
      {
         container.victor = 0;
      }
   }
   container.racer1Obj.ET = _loc4_.firstChild.attributes.et1;
   container.racer1Obj.TS = _loc4_.firstChild.attributes.ts1;
   container.racer2Obj.ET = _loc4_.firstChild.attributes.et2;
   container.racer2Obj.TS = _loc4_.firstChild.attributes.ts2;
   container.racer1Obj.scc = _loc4_.firstChild.attributes.c1;
   container.racer2Obj.scc = _loc4_.firstChild.attributes.c2;
   container.racer1Obj.sc = Number(container.racer1Obj.sc) + Number(_loc4_.firstChild.attributes.c1);
   container.racer2Obj.sc = Number(container.racer2Obj.sc) + Number(_loc4_.firstChild.attributes.c2);
   if(classes.GlobalData.id == _loc4_.firstChild.attributes.r1id)
   {
      classes.GlobalData.updateInfo("sc",container.racer1Obj.sc);
      classes.GlobalData.updateInfo("m",Number(classes.GlobalData.attr.m) + Number(_loc4_.firstChild.attributes.m1));
      if(_global.chatObj.raceObj.bt == -1)
      {
         _root.getCars();
      }
   }
   else if(classes.GlobalData.id == _loc4_.firstChild.attributes.r2id)
   {
      classes.GlobalData.updateInfo("sc",container.racer2Obj.sc);
      classes.GlobalData.updateInfo("m",Number(classes.GlobalData.attr.m) + Number(_loc4_.firstChild.attributes.m2));
      if(_global.chatObj.raceObj.bt == -1)
      {
         _root.getCars();
      }
   }
   classes.Chat.enableWindow();
   optimizeBottom(true);
   classes.Control.setMapButton("race");
   if(classes.GlobalData.id == _loc4_.firstChild.attributes.r1id || classes.GlobalData.id == _loc4_.firstChild.attributes.r2id)
   {
      container.showFinish();
   }
   else
   {
      _global.setTimeout(this,"doShowFinish",5000);
   }
}
function doShowFinish()
{
   container.showFinish(3000);
}
function showWaiting()
{
   showContainer("waitRivals");
}
var bottomStatic;
