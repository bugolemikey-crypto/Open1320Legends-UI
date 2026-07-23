class classes.Control
{
   static var __ROOT;
   static var ctourneyMC;
   static var currentDialog;
   static var dockTabs;
   static var emailPt;
   static var emailSI;
   static var getUserID;
   static var htourneyMC;
   static var leaderboardMC;
   static var loginDone;
   static var loginObj;
   static var modToolsPt;
   static var nimPt;
   static var quickmatchMC;
   static var supportCenterPt;
   static var tourneyMenuMC;
   static var viewerPt;
   function Control(_context)
   {
      classes.Control.__ROOT = _context;
      classes.Control.dockTabs = new Array();
      classes.Control.loginObj = new Object();
      classes.Control.loginDone = false;
   }
   static function serverAvail()
   {
      if(_global.serverLocked)
      {
         return false;
      }
      classes.Frame.serverLights(true);
      _global.serverLocked = true;
      return true;
   }
   static function serverUnlock()
   {
      classes.Frame.serverLights(false);
      _global.serverLocked = false;
   }
   static function loginFinished(stage)
   {
      trace("loginFinished: " + stage);
      classes.Control.loginObj[stage] = true;
      if(classes.Control.loginObj.web && classes.Control.loginObj.socket && classes.Control.loginObj.cars)
      {
         trace("loginComplete!");
         classes.Control.loginObj.completed = true;
         classes.Control.loginDone = true;
         trace("facebookLinkPage: " + classes.Frame._MC.loginGroup.facebookLinkPage);
         if(classes.Frame._MC.loginGroup.facebookLinkPage == false)
         {
            classes.Frame._MC.loginGroup.gotoAndPlay("updater");
         }
         else
         {
            classes.Frame._MC.loginGroup.gotoAndPlay("updaterFB");
         }
      }
   }
   static function focusEmail(toUser)
   {
      classes.Control.__ROOT.main.overlay.tabEmail._visible = false;
      if(classes.Control.__ROOT.emailMan == undefined)
      {
         classes.Control.__ROOT.emailMan = new classes.Email(classes.Control.__ROOT,toUser);
      }
      else
      {
         classes.Control.__ROOT.email.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
         if(toUser.length)
         {
            classes.Email.compose(classes.Control.__ROOT,{to_user:toUser,subj:""});
         }
         if(!classes.Control.__ROOT.email._visible)
         {
            classes.Control.__ROOT.email._x = classes.Control.emailPt.x;
            classes.Control.__ROOT.email._y = classes.Control.emailPt.y;
            classes.Control.__ROOT.email._visible = true;
         }
      }
      _root.getEmailList();
   }
   static function focusViewer(uID, carID, tID)
   {
      var _loc7_;
      var _loc6_;
      var _loc3_ = 2;
      if(tID)
      {
         _loc3_ = 3;
      }
      else if(carID > 0)
      {
         _loc3_ = 1;
      }
      else if(!uID)
      {
         _loc3_ = 0;
      }
      classes.Control.removeTab(classes.Control.__ROOT.main.overlay.tabViewer);
      if(classes.Control.__ROOT.viewer == undefined)
      {
         _loc7_ = 9;
         _loc6_ = 86;
         classes.Control.__ROOT.attachMovie("viewer","viewer",classes.Control.__ROOT.getNextHighestDepth(),{_x:_loc7_,_y:_loc6_,sectionNum:_loc3_,uID:uID,carID:carID,tID:tID});
      }
      else
      {
         classes.Control.__ROOT.viewer.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
         classes.Control.__ROOT.viewer.sectionNum = _loc3_;
         if(tID)
         {
            if(classes.Control.__ROOT.viewer.tID != tID)
            {
               delete classes.Control.__ROOT.viewer.uID;
               delete classes.Control.__ROOT.viewer.carID;
               classes.Control.__ROOT.viewer.clearUser();
               classes.Control.__ROOT.viewer.tID = tID;
               classes.Control.__ROOT.viewer.goSection(_loc3_);
            }
         }
         else if(uID)
         {
            delete classes.Control.__ROOT.viewer.tID;
            if(classes.Control.__ROOT.viewer.uID != uID)
            {
               delete classes.Control.__ROOT.viewer.carID;
               classes.Control.__ROOT.viewer.clearUser();
               classes.Control.__ROOT.viewer.gotoAndPlay("loading");
               classes.Control.__ROOT.viewer.setShad();
               classes.Lookup.addCallback("getUser",classes.Control.__ROOT.viewer,classes.Control.__ROOT.viewer.CB_getUser,String(uID));
               _root.getUser(uID);
            }
            else if(carID != undefined)
            {
               classes.Control.__ROOT.viewer.carID = carID;
               classes.Control.__ROOT.viewer.goSection(_loc3_);
            }
         }
         else if(!classes.Control.__ROOT.viewer.uID && !classes.Control.__ROOT.viewer.tID)
         {
            classes.Control.__ROOT.viewer.goSearch();
         }
         if(!classes.Control.__ROOT.viewer._visible)
         {
            classes.Control.__ROOT.viewer._x = classes.Control.viewerPt.x;
            classes.Control.__ROOT.viewer._y = classes.Control.viewerPt.y;
            classes.Control.__ROOT.viewer._visible = true;
         }
      }
   }
   static function focusNim(uID)
   {
      classes.Control.__ROOT.main.overlay.tabNim._visible = false;
      classes.Control.__ROOT.panel.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
      if(!classes.Control.__ROOT.panel._visible)
      {
         classes.Control.__ROOT.panel._x = classes.Control.nimPt.x;
         classes.Control.__ROOT.panel._y = classes.Control.nimPt.y;
         classes.Control.__ROOT.panel._visible = true;
      }
      if(uID)
      {
         if(classes.Console.findConverse(uID) == undefined)
         {
            classes.Console.newConverse(uID);
         }
         else
         {
            classes.Console.focusConverse(uID);
         }
         classes.Console.nimBuddyID = uID;
         classes.Console.nimBuddyName = classes.Lookup.buddyName(uID);
         if(classes.Console.panelNum != 1)
         {
            classes.Console.changePanel(1);
         }
         else
         {
            classes.Control.__ROOT.panel.refreshMe();
         }
      }
   }
   static function focusSupportCenter(userType, startHere, username, userID)
   {
      classes.Control.__ROOT.main.overlay.tabSupport._visible = false;
      if(classes.Control.__ROOT.supportCenter == undefined)
      {
         classes.Control.__ROOT.supportCenter = new classes.SupportCenter();
         trace("new support center, userType: " + userType);
         classes.Control.__ROOT.supportCenter.init(classes.Control.__ROOT,classes.SupportCenter.USER,userType,startHere,-5.5,160,username,userID);
      }
      else
      {
         classes.Control.__ROOT.supportCenter.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
         if(!classes.Control.__ROOT.supportCenter._visible)
         {
            classes.Control.__ROOT.supportCenter._x = classes.Control.supportCenterPt.x;
            classes.Control.__ROOT.supportCenter._y = classes.Control.supportCenterPt.y;
            classes.Control.__ROOT.supportCenter._visible = true;
         }
         if(startHere)
         {
            classes.Control.__ROOT.supportCenter.gotoHere(startHere,username,userID);
         }
      }
   }
   static function focusModTools(userType, startHere, username, userID)
   {
      if(classes.Control.__ROOT.modTools == undefined)
      {
         classes.Control.__ROOT.modTools = new classes.SupportCenter();
         classes.Control.__ROOT.modTools.init(classes.Control.__ROOT,classes.SupportCenter.MOD,userType,startHere,-5.5,160,username,userID);
      }
      else
      {
         classes.Control.__ROOT.modTools.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
         if(!classes.Control.__ROOT.modTools._visible)
         {
            classes.Control.__ROOT.modTools._x = classes.Control.modToolsPt.x;
            classes.Control.__ROOT.modTools._y = classes.Control.modToolsPt.y;
            classes.Control.__ROOT.modTools._visible = true;
         }
         if(startHere)
         {
            classes.Control.__ROOT.modTools.gotoHere(startHere,username,userID);
         }
      }
   }
   static function focusBuddyList(showBuddyRequestsPanel)
   {
      classes.Control.__ROOT.panel.swapDepths(classes.Control.__ROOT.getNextHighestDepth());
      if(!classes.Control.__ROOT.panel._visible)
      {
         classes.Control.__ROOT.panel._x = classes.Control.nimPt.x;
         classes.Control.__ROOT.panel._y = classes.Control.nimPt.y;
         classes.Control.__ROOT.panel._visible = true;
      }
      if(showBuddyRequestsPanel)
      {
         if(classes.Console.panelNum != 2)
         {
            classes.Control.__ROOT.panel.tbB.showRequests = true;
            _root.getNimIncomingRequests();
         }
         else
         {
            classes.Control.__ROOT.panel.tbB.showRequests = true;
            classes.Control.__ROOT.panel.refreshMe();
         }
      }
      else
      {
         classes.Control.__ROOT.panel.tbB.showRequests = false;
         classes.Control.__ROOT.panel.refreshMe();
      }
   }
   static function dockNim()
   {
      classes.pmButton._mc.clearFlash();
      classes.Control.nimPt = new flash.geom.Point(classes.Control.__ROOT.panel._x,classes.Control.__ROOT.panel._y);
      classes.Control.__ROOT.panel._y = -1600;
      classes.Control.__ROOT.panel._visible = false;
      classes.Control.addTab(classes.Control.__ROOT.main.overlay.tabNim);
   }
   static function dockViewer()
   {
      classes.Control.viewerPt = new flash.geom.Point(classes.Control.__ROOT.viewer._x,classes.Control.__ROOT.viewer._y);
      classes.Control.__ROOT.viewer._y = -1600;
      classes.Control.__ROOT.viewer._visible = false;
      classes.Control.addTab(classes.Control.__ROOT.main.overlay.tabViewer);
   }
   static function dockEmail()
   {
      classes.Control.emailPt = new flash.geom.Point(classes.Control.__ROOT.email._x,classes.Control.__ROOT.email._y);
      classes.Control.__ROOT.email._y = -1600;
      classes.Control.__ROOT.email._visible = false;
      classes.Control.addTab(classes.Control.__ROOT.main.overlay.tabEmail);
   }
   static function dockSupportCenter()
   {
      if(classes.Control.__ROOT.supportCenter)
      {
         classes.Control.supportCenterPt = new flash.geom.Point(classes.Control.__ROOT.supportCenter._x,classes.Control.__ROOT.supportCenter._y);
         classes.Control.__ROOT.supportCenter._y = -1600;
         classes.Control.__ROOT.supportCenter._visible = false;
      }
      classes.Control.addTab(classes.Control.__ROOT.main.overlay.tabSupport);
   }
   static function dockModTools()
   {
      if(classes.Control.__ROOT.modTools)
      {
         classes.Control.modToolsPt = new flash.geom.Point(classes.Control.__ROOT.modTools._x,classes.Control.__ROOT.modTools._y);
         classes.Control.__ROOT.modTools._y = -1600;
         classes.Control.__ROOT.modTools._visible = false;
      }
   }
   static function addTab(ttab)
   {
      trace("addTab");
      trace(ttab);
      ttab._visible = true;
      var _loc1_ = 0;
      while(_loc1_ < classes.Control.dockTabs.length)
      {
         if(classes.Control.dockTabs[_loc1_] == ttab)
         {
            return undefined;
         }
         _loc1_ = _loc1_ + 1;
      }
      classes.Control.dockTabs.push(ttab);
      classes.Control.sortDockTabs();
   }
   static function removeTab(ttab)
   {
      var _loc1_ = 0;
      while(_loc1_ < classes.Control.dockTabs.length)
      {
         if(classes.Control.dockTabs[_loc1_] == ttab)
         {
            classes.Control.dockTabs.splice(_loc1_,1);
            classes.Control.sortDockTabs();
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function showTabs()
   {
      var _loc1_ = classes.Control.__ROOT.main.overlay;
      _loc1_.tabNim._visible = true;
      _loc1_.tabEmail._visible = true;
      _loc1_.tabViewer._visible = true;
      _loc1_.tabSupport._visible = true;
   }
   static function sortDockTabs()
   {
      var _loc2_ = classes.Control.__ROOT.main.overlay;
      _loc2_.tabNim._visible = false;
      _loc2_.tabEmail._visible = false;
      _loc2_.tabViewer._visible = false;
      _loc2_.tabSupport._visible = false;
      trace("cc.tabRight: " + _loc2_.tabRight + " " + _loc2_.tabRight.x);
      classes.Control.dockTabs[0]._x = _loc2_.tabRight._x - classes.Control.dockTabs[0]._width - 1;
      classes.Control.dockTabs[0]._visible = true;
      trace("sortDockTabs");
      trace(classes.Control.dockTabs.length);
      var _loc1_ = 1;
      while(_loc1_ < classes.Control.dockTabs.length)
      {
         classes.Control.dockTabs[_loc1_]._x = classes.Control.dockTabs[_loc1_ - 1]._x - classes.Control.dockTabs[_loc1_]._width - 1;
         classes.Control.dockTabs[_loc1_]._visible = true;
         _loc1_ = _loc1_ + 1;
      }
   }
   static function setMapButton(pageID)
   {
      var _loc2_ = _root.main.overlay.mapBtn.btn;
      switch(pageID)
      {
         case "practice":
            _loc2_.onRelease = function()
            {
               classes.RacePlay._MC.onScreenExit();
               _root.raceSound.stopSound();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "race":
            _loc2_.onRelease = function()
            {
               classes.Lookup.removeFromRaceCarsXMLByUser(classes.GlobalData.id);
               classes.RacePlay._MC.onScreenExit();
               _root.raceSound.stopSound();
               _root.chatLeave();
               classes.Chat.destroyWindow();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "nonrace":
            _loc2_.onRelease = function()
            {
               classes.Lookup.removeFromRaceCarsXMLByUser(classes.GlobalData.id);
               classes.RacePlay._MC.onScreenExit();
               _root.raceSound.stopSound();
               classes.Chat.destroyWindow();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "htTourney":
         case "tourneyRacing":
            _loc2_.onRelease = function()
            {
               var _loc2_ = function()
               {
                  classes.Lookup.removeFromRaceCarsXMLByUser(classes.GlobalData.id);
                  classes.RacePlay._MC.onScreenExit();
                  _root.raceSound.stopSound();
                  classes.Chat.destroyWindow();
                  _root.htQuit();
                  _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
               };
               classes.Control.genericDialog("Leaving the track now will cause you to forfeit the tournament.  Are you sure you want to leave?",_loc2_);
            };
            return;
         case "racing":
            _loc2_.onRelease = function()
            {
               var _loc2_ = function()
               {
                  classes.Lookup.removeFromRaceCarsXMLByUser(classes.GlobalData.id);
                  classes.RacePlay._MC.onScreenExit();
                  _root.raceSound.stopSound();
                  _root.chatLeave();
                  classes.Chat.destroyWindow();
                  _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
               };
               classes.Control.genericDialog("Leaving the track now will forfeit your current race.  Are you sure you want to leave?",_loc2_);
            };
            return;
         case "king":
            _loc2_.onRelease = function()
            {
               var _loc2_ = function()
               {
                  classes.Lookup.removeFromRaceCarsXMLByUser(classes.GlobalData.id);
                  classes.RacePlay._MC.onScreenExit();
                  _root.chatLeave();
                  classes.Chat.destroyWindow();
                  _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
               };
               classes.Control.genericDialog("Leaving the track now will cause you to step down as King.  Are you sure you want to leave?",_loc2_);
            };
            return;
         case "shop":
            _loc2_.onRelease = function()
            {
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "matching":
            _loc2_.onRelease = function()
            {
               _root.chatQMHLeave();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "matchingQMB":
            _loc2_.onRelease = function()
            {
               _root.chatQMBLeave();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "matchDone":
            _loc2_.onRelease = function()
            {
               _root.chatQMLeave();
               _root.main.sectionHolder.sectionClip.gotoAndPlay("map");
            };
            return;
         case "modInterview":
            _loc2_.onRelease = function()
            {
               _root.chatLeave();
               classes.SectionModElection.MC.doInterview();
            };
            return;
         default:
            _loc2_.onRelease = function()
            {
               if(_root.main.mapStatus)
               {
                  _root.main.destroyMap();
               }
               else
               {
                  _root.main.createMap();
               }
            };
            return;
      }
   }
   static function setPeriodicEmail()
   {
      clearInterval(classes.Control.emailSI);
      classes.Control.emailSI = setInterval(classes.Control.periodicEmail,60100);
   }
   static function periodicEmail()
   {
      if(classes.GlobalData.isDisconnected)
      {
         clearInterval(classes.Control.emailSI);
         return undefined;
      }
      var _loc1_ = new Date();
      if(classes.GlobalData.lastEmailRetrieveTime == undefined)
      {
         classes.GlobalData.lastEmailRetrieveTime = _loc1_ - 1000000;
      }
      if(_loc1_ - classes.GlobalData.lastEmailRetrieveTime > 300000)
      {
         classes.Control.getEmailNow();
      }
   }
   static function getEmailNow()
   {
      if(!classes.RacePlay._MC.myLane)
      {
         if(_root.email._visible)
         {
            _root.getEmailList();
         }
         else
         {
            _root.getEmailTotalNew();
         }
         classes.GlobalData.lastEmailRetrieveTime = Number(new Date());
      }
   }
   static function goSection(sectionName, locID)
   {
      classes.Frame._MC.goMainSection(sectionName,locID);
   }
   static function dialogAlert(pTitle, pMessage, onOK, alertIcon, hideCancel)
   {
      if(!alertIcon.length)
      {
         alertIcon = "warning";
      }
      _root.abc.closeMe();
      var _loc3_ = classes.AlertBox(_root.attachMovie("alertBox","abc",_root.getNextHighestDepth()));
      _loc3_.setValue(pTitle,pMessage,alertIcon);
      var _loc4_;
      if(onOK)
      {
         _loc3_.addButton("OK");
         if(!hideCancel)
         {
            _loc3_.addButton("Cancel");
         }
         _loc3_.onOK = onOK;
         _loc4_ = new Object();
         _loc4_.onRelease = function(theButton)
         {
            if(theButton.btnLabel.text == "OK")
            {
               theButton._parent._parent.onOK();
            }
            false;
            theButton._parent._parent.closeMe();
         };
         _root.abc.addListener(_loc4_);
      }
      else
      {
         _loc3_.addButton("Close");
      }
   }
   static function dialogContainer(linkageName, initObj)
   {
      if(!initObj)
      {
         initObj = new Object();
      }
      initObj.contentName = linkageName;
      _root.abc.closeMe();
      _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),initObj);
   }
   static function dialogTextBlob(title, msg, iconName)
   {
      _root.abc.closeMe();
      _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTextBlobContent",title:title,msg:msg,iconName:iconName});
   }
   static function dialogTextBrief(title, msg, iconName)
   {
      _root.abc.closeMe();
      _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTextBriefContent",title:title,msg:msg,iconName:iconName});
   }
   static function genericDialog(msg, onOK)
   {
      _root.abc.closeMe();
      _root.attachMovie("dialogWarning","abc",_root.getNextHighestDepth());
      _root.abc.contentMC.msg = msg;
      _root.abc.addButton("OK");
      _root.abc.addButton("Cancel");
      _root.abc.onOK = onOK;
      var _loc3_ = new Object();
      _loc3_.onRelease = function(theButton, keepBoxOpen)
      {
         if(theButton.btnLabel.text == "OK")
         {
            theButton._parent._parent.onOK();
         }
         if(!keepBoxOpen)
         {
            false;
            theButton._parent._parent.closeMe();
         }
      };
      _root.abc.addListener(_loc3_);
   }
   static function dialogClose()
   {
      _root.abc.closeMe();
      _root.alertMC.closeMe();
   }
}
