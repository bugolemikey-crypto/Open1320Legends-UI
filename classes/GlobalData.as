class classes.GlobalData
{
   static var attr;
   static var bypassRequirements;
   static var currentAccountCarID;
   static var dailyAwardAmount;
   static var dailyAwardType;
   static var engineSound;
   static var facebookConnected;
   static var hasShiftLightGauge;
   static var id;
   static var isDisconnected;
   static var isVIPUser;
   static var lastEmailRetrieveTime;
   static var meetsAccountLengthRequirement;
   static var onCarAlert;
   static var onUpdateCars;
   static var prefsXML;
   static var priorSelectedCarID;
   static var priorStreetCredit;
   static var raceControlsID;
   static var role;
   static var serverTimeOffset;
   static var shiftLightGaugeRPM;
   static var teamRivalBracketPenalty;
   static var teamRivalPenalty;
   static var temp;
   static var testDriveCarAccountID;
   static var testDriveCarExpired;
   static var testDriveCarPointPrice;
   static var testDriveCarPrice;
   static var testDriveInvitationID;
   static var testDriveTimeRemaining;
   static var tournamentChatRoomID;
   static var uname;
   static var prefsObj = new Object();
   static var removeCarsArr = new Array();
   function GlobalData()
   {
   }
   static function updateInfo(prop, val)
   {
      if(!String(val).length)
      {
         trace("no val data");
         return undefined;
      }
      var _loc6_;
      var _loc7_;
      var _loc5_;
      var _loc3_;
      switch(prop)
      {
         case "m":
            _loc6_ = Number(val);
            _loc7_ = Number(_global.loginXML.firstChild.firstChild.attributes.m);
            _global.loginXML.firstChild.firstChild.attributes.m = _loc6_;
            _root.main.overlay.txtMoney = "$: " + (_loc6_ >= 10000000 ? _loc6_ : classes.NumFuncs.commaFormat(_loc6_));
            if(_loc7_ < _loc6_)
            {
               classes.Frame._MC.overlay.moneyAnim.play();
            }
            break;
         case "p":
            _loc6_ = Number(val);
            _global.loginXML.firstChild.firstChild.attributes.p = _loc6_;
            _root.main.overlay.txtPoints = "P: " + (_loc6_ >= 10000000 ? _loc6_ : classes.NumFuncs.commaFormat(_loc6_));
            break;
         case "sc":
            _global.loginXML.firstChild.firstChild.attributes.sc = val;
            _root.main.overlay.txtCred = "SC: " + val;
            break;
         case "lid":
            _global.loginXML.firstChild.firstChild.attributes.lid = Number(val);
            break;
         case "im":
            if(val == "count")
            {
               _loc5_ = 0;
               _loc3_ = 0;
               while(_loc3_ < _global.inbox_xml.firstChild.childNodes.length)
               {
                  if(Number(_global.inbox_xml.firstChild.childNodes[_loc3_].attributes.n) == 1)
                  {
                     _loc5_ = _loc5_ + 1;
                  }
                  _loc3_ = _loc3_ + 1;
               }
               _global.loginXML.firstChild.firstChild.attributes.im = _loc5_;
               _root.main.overlay.txtEmail = _loc5_;
            }
            else
            {
               _root.main.overlay.txtEmail = val;
            }
            trace("w1: " + _root.main.overlay.fldEmail._width);
            classes.Frame._MC.overlay.emailIcon._x = classes.Frame._MC.overlay.fldEmail._x - classes.Frame._MC.overlay.emailIcon._width - 2;
            break;
         case "tr":
            _global.loginXML.firstChild.firstChild.attributes.tr = Number(val);
            break;
         case "ti":
            _global.loginXML.firstChild.firstChild.attributes.ti = Number(val);
            break;
         case "bg":
            _global.loginXML.firstChild.firstChild.attributes.bg = val;
            break;
         case "act":
            _global.loginXML.firstChild.firstChild.attributes.act = Number(val);
         default:
            return;
      }
   }
   static function addFunds(amt)
   {
      var _loc1_;
      if(amt)
      {
         _loc1_ = Number(classes.GlobalData.attr.m) + amt;
         classes.GlobalData.updateInfo("m",_loc1_);
      }
   }
   static function addPoints(amt)
   {
      var _loc1_;
      if(amt)
      {
         _loc1_ = Number(classes.GlobalData.attr.p) + amt;
         classes.GlobalData.updateInfo("p",_loc1_);
      }
   }
   static function getSelectedCarXML()
   {
      trace("selected car: " + _global.loginXML.firstChild.firstChild.attributes.dc);
      var _loc2_;
      if(Number(_global.loginXML.firstChild.firstChild.attributes.dc) > 0)
      {
         trace(_global.garageXML.firstChild.childNodes.length);
         _loc2_ = 0;
         while(_loc2_ < _global.garageXML.firstChild.childNodes.length)
         {
            if(_global.loginXML.firstChild.firstChild.attributes.dc == _global.garageXML.firstChild.childNodes[_loc2_].attributes.i)
            {
               trace(_global.garageXML.firstChild.childNodes[_loc2_]);
               trace(_global.garageXML.firstChild.childNodes[_loc2_].firstChild.childNodes.length);
               return _global.garageXML.firstChild.childNodes[_loc2_];
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      _loc2_ = 0;
      while(_loc2_ < _global.garageXML.firstChild.childNodes.length)
      {
         if(_global.garageXML.firstChild.childNodes[_loc2_].attributes.sel == 1)
         {
            _global.loginXML.firstChild.firstChild.attributes.dc = _global.garageXML.firstChild.childNodes[_loc2_].attributes.i;
            return _global.garageXML.firstChild.childNodes[_loc2_];
         }
         _loc2_ = _loc2_ + 1;
      }
      trace("none selected!");
      trace("new selected car: " + _global.garageXML.firstChild.childNodes[0].attributes.i);
      _global.loginXML.firstChild.firstChild.attributes.dc = _global.garageXML.firstChild.childNodes[0].attributes.i;
      return _global.garageXML.firstChild.childNodes[0];
   }
   static function setSelectedCar(id)
   {
      _global.loginXML.firstChild.firstChild.attributes.dc = id;
   }
   static function removeCar(cid)
   {
      trace("removeCar: " + cid);
      var _loc3_ = _global.garageXML.firstChild.childNodes.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         if(cid == _global.garageXML.firstChild.childNodes[_loc2_].attributes.i)
         {
            trace(_global.garageXML.firstChild.childNodes[_loc2_].attributes.i);
            trace("removing node!");
            _global.garageXML.firstChild.childNodes[_loc2_].removeNode();
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function replaceCarNode(d)
   {
      var _loc4_ = new XML(d);
      var _loc5_ = _loc4_.firstChild.firstChild.attributes.i;
      var _loc6_ = _global.garageXML.firstChild.childNodes.length;
      var _loc3_;
      var _loc2_ = 0;
      while(_loc2_ < _loc6_)
      {
         if(_global.garageXML.firstChild.childNodes[_loc2_].attributes.i == _loc5_)
         {
            _loc3_ = _global.garageXML.firstChild.childNodes[_loc2_];
            _global.garageXML.firstChild.insertBefore(_loc4_.firstChild.firstChild,_loc3_);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc3_)
      {
         _loc3_.removeNode();
      }
   }
   static function addToRemoveCars(acid)
   {
      if(acid)
      {
         classes.GlobalData.removeCarsArr.push(acid);
      }
   }
   static function doRemoveCars()
   {
      var _loc1_ = 0;
      while(_loc1_ < classes.GlobalData.removeCarsArr.length)
      {
         classes.GlobalData.removeCar(classes.GlobalData.removeCarsArr[_loc1_]);
         _loc1_ = _loc1_ + 1;
      }
      classes.GlobalData.removeCarsArr = new Array();
      classes.Frame._MC.overlay.carIcon.prevFrame();
      delete classes.Frame._MC.overlay.carIcon.onRelease;
      delete classes.GlobalData.onUpdateCars;
      trace("doRemoveCars");
      trace("previous frame carIcon!");
   }
   static function doGetAllCars()
   {
      classes.GlobalData.removeCarsArr = new Array();
      _root.getCars();
      classes.Frame._MC.overlay.carIcon.prevFrame();
      delete classes.Frame._MC.overlay.carIcon.onRelease;
      delete classes.GlobalData.onUpdateCars;
   }
   static function carWasSold()
   {
      var _loc2_ = "One or more of your used cars have been sold.";
      if(classes.Frame._MC.sectionHolder.sectionClip.objectName == "sectionClassified")
      {
         classes.GlobalData.onUpdateCars();
         _loc2_ += "  Your garage has been updated.";
      }
      else
      {
         _loc2_ += "  Please go to Used Cars to update your garage.";
      }
      _loc2_ += " Hit ok to deposit the money from the sold car(s) in your account";
      var _loc3_ = function()
      {
         _root.claimPendingUCLProfit();
      };
      classes.Control.dialogAlert("Garage Update",_loc2_,_loc3_,"warningtriangle",true);
   }
   static function carWasTraded()
   {
      var _loc1_ = "One or more of your trade offers have been accepted.";
      if(classes.Frame._MC.sectionHolder.sectionClip.objectName == "sectionClassified")
      {
         classes.GlobalData.onUpdateCars();
         _loc1_ += "  Your garage has been updated.";
      }
      else
      {
         _loc1_ += "  Please go to Used Cars to update your garage.";
      }
      classes.Control.dialogAlert("Garage Update",_loc1_,undefined,"warningtriangle",true);
   }
   static function updateCarAttr(cid, attr, val)
   {
      var _loc3_ = _global.garageXML.firstChild.childNodes.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         if(cid == _global.garageXML.firstChild.childNodes[_loc2_].attributes.i)
         {
            _global.garageXML.firstChild.childNodes[_loc2_].attributes[attr] = val;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function setMyRaceCarNode(acid)
   {
      var _loc2_ = 0;
      while(_loc2_ < _global.garageXML.firstChild.childNodes.length)
      {
         if(acid == _global.garageXML.firstChild.childNodes[_loc2_].attributes.i)
         {
            _global.chatObj.myRaceCarNode = _global.garageXML.firstChild.childNodes[_loc2_];
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function setGlobalXML(newName, xmlStr)
   {
      _global[newName] = new XML();
      _global[newName].ignoreWhite = true;
      _global[newName].parseXML(xmlStr);
   }
   static function getPlateXML(id)
   {
      var _loc2_ = 0;
      while(_loc2_ < _global.platesXML.firstChild.childNodes.length)
      {
         if(id == Number(_global.platesXML.firstChild.childNodes[_loc2_].attributes.i))
         {
            return _global.platesXML.firstChild.childNodes[_loc2_];
         }
         _loc2_ = _loc2_ + 1;
      }
      return null;
   }
   static function setPrefsObj()
   {
      trace("setPrefsObj");
      trace(classes.GlobalData.prefsXML.firstChild.nodeName);
      if(!classes.GlobalData.prefsXML || classes.GlobalData.prefsXML.firstChild.nodeName != "n2" || !classes.GlobalData.prefsXML.firstChild.attributes.spectateQuality)
      {
         classes.GlobalData.prefsXML = new XML("<n2 raceQuality=\"3\" spectateQuality=\"3\" disableProfanityFilter=\"0\" broadcastRead=\"0\" didFirstRun=\"0\" didViewTrack=\"0\" i=\"\" dt=\"0\"></n2>");
      }
      var _loc1_ = classes.GlobalData.prefsXML.firstChild.attributes;
      classes.GlobalData.prefsObj.raceQuality = !(Number(_loc1_.raceQuality) || Number(_loc1_.raceQuality) === 0) ? 3 : Number(_loc1_.raceQuality);
      classes.GlobalData.prefsObj.spectateQuality = !Number(_loc1_.spectateQuality) ? 3 : Number(_loc1_.spectateQuality);
      classes.GlobalData.prefsObj.disableProfanityFilter = !Number(_loc1_.disableProfanityFilter) ? 0 : Number(_loc1_.disableProfanityFilter);
      classes.GlobalData.prefsObj.broadcastRead = !Number(_loc1_.broadcastRead) ? 0 : Number(_loc1_.broadcastRead);
      classes.GlobalData.prefsObj.didFirstRun = !Number(_loc1_.didFirstRun) ? 0 : Number(_loc1_.didFirstRun);
      classes.GlobalData.prefsObj.didViewTrack = !Number(_loc1_.didViewTrack) ? 0 : Number(_loc1_.didViewTrack);
      classes.GlobalData.prefsObj.didViewRace = !Number(_loc1_.didViewRace) ? 0 : Number(_loc1_.didViewRace);
      classes.GlobalData.prefsObj.bannerRead = !Number(_loc1_.bannerRead) ? 0 : Number(_loc1_.bannerRead);
      classes.GlobalData.prefsObj.ll = !Number(_loc1_.ll) ? 0 : Number(_loc1_.ll);
      classes.GlobalData.prefsObj.ldc = !Number(_loc1_.ldc) ? 0 : Number(_loc1_.ldc);
      trace("bannerRead: " + classes.GlobalData.prefsObj.bannerRead);
      if(_loc1_.i)
      {
         classes.GlobalData.prefsObj.incentiveArray = _loc1_.i.split(",");
      }
      else
      {
         classes.GlobalData.prefsObj.incentiveArray = new Array("");
      }
      classes.GlobalData.prefsObj.dev = !Number(_loc1_.dev) ? 0 : Number(_loc1_.dev);
      classes.GlobalData.prefsObj.fb = !Number(_loc1_.fb) ? 0 : Number(_loc1_.fb);
   }
   static function savePrefsObj()
   {
      var _loc2_ = classes.GlobalData.prefsXML.firstChild.attributes;
      _loc2_.raceQuality = classes.GlobalData.prefsObj.raceQuality;
      _loc2_.spectateQuality = classes.GlobalData.prefsObj.spectateQuality;
      _loc2_.disableProfanityFilter = classes.GlobalData.prefsObj.disableProfanityFilter;
      _loc2_.broadcastRead = classes.GlobalData.prefsObj.broadcastRead;
      _loc2_.didFirstRun = classes.GlobalData.prefsObj.didFirstRun;
      _loc2_.didViewTrack = classes.GlobalData.prefsObj.didViewTrack;
      _loc2_.didViewRace = classes.GlobalData.prefsObj.didViewRace;
      _loc2_.bannerRead = classes.GlobalData.prefsObj.bannerRead;
      _loc2_.ll = classes.GlobalData.prefsObj.ll;
      _loc2_.ldc = classes.GlobalData.prefsObj.ldc;
      _loc2_.i = classes.GlobalData.prefsObj.incentiveArray.toString();
      _loc2_.fb = classes.GlobalData.prefsObj.fb;
      if(classes.GlobalData.prefsObj.dev)
      {
         _loc2_.dev = "1";
      }
      _loc2_.dt = classes.GlobalData.attr.dt;
      _root.saveFile("prefs.txt",classes.GlobalData.prefsXML.toString());
   }
   static function setLL()
   {
      var _loc1_ = new Date();
      classes.GlobalData.prefsObj.ll = _loc1_.valueOf();
      classes.GlobalData.savePrefsObj();
   }
   static function getLL()
   {
      return classes.GlobalData.prefsObj.ll;
   }
   static function setLDC(challengeID)
   {
      classes.GlobalData.prefsObj.ldc = challengeID;
      classes.GlobalData.savePrefsObj();
   }
   static function getLDC()
   {
      return classes.GlobalData.prefsObj.ldc;
   }
   static function savePrefsXMLDT(dt)
   {
      classes.GlobalData.attr.dt = dt;
      classes.GlobalData.savePrefsObj();
   }
   static function getTestDriveCarXML()
   {
      var _loc2_ = 0;
      while(_loc2_ < _global.garageXML.firstChild.childNodes.length)
      {
         if(_global.garageXML.firstChild.childNodes[_loc2_].attributes.td == true)
         {
            return _global.garageXML.firstChild.childNodes[_loc2_];
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function makeTestDriveCarExpired()
   {
      var _loc1_ = classes.GlobalData.getTestDriveCarXML();
      _loc1_.attributes.tdex = 1;
      classes.GlobalData.testDriveCarExpired = true;
   }
   static function doesSelCarHaveSpecialGauge()
   {
      var _loc2_ = classes.GlobalData.getSelectedCarXML();
      var _loc3_ = false;
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.childNodes.length)
      {
         if(Number(_loc2_.childNodes[_loc1_].attributes.ci) == 15 && _loc2_.childNodes[_loc1_].nodeName == "p")
         {
            trace("found special gauge!");
            _loc3_ = true;
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   static function doesCarHaveDiagnosticToolInstalled()
   {
      var _loc2_ = classes.GlobalData.getSelectedCarXML();
      var _loc3_ = false;
      trace("looking for diagnostic tool");
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.childNodes.length)
      {
         if(Number(_loc2_.childNodes[_loc1_].attributes.ci) == 173 && _loc2_.childNodes[_loc1_].nodeName == "p")
         {
            trace("found diagnostic tool!");
            _loc3_ = true;
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   static function getSelCarRPM()
   {
      return classes.GlobalData.shiftLightGaugeRPM;
   }
}
