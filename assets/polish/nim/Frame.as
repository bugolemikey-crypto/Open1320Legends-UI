class classes.Frame extends MovieClip
{
   var loginGroup;
   var map;
   var mapMask;
   var mapStatus;
   var overlay;
   var sectionHolder;
   static var _MC;
   static var __MC;
   static var assetLoader;
   static var globalSound;
   function Frame()
   {
      super();
      classes.Frame.__MC = this;
      classes.Frame._MC = this;
      classes.Frame.globalSound = new Sound(_root);
      classes.Frame.globalSound.setVolume(50);
      this.overlay.carIcon._visible = false;
      this.overlay.systemMsg._visible = false;
      this.overlay.serverLights.light1._visible = false;
      this.overlay.serverLights.light2._visible = false;
      this.overlay.txtRelease = _root.splashPre.toUpperCase() + _global.releaseNumber;
      this.sectionHolder = this.createEmptyMovieClip("sectionHolder",2);
      classes.Frame._MC.overlay.swapDepths(10);
      this.initTabs();
      this.showModToolButton(false);
      classes.Frame._MC.overlay.btnSettings.onRelease = function()
      {
         classes.Control.dialogContainer("dialogGraphicSettingsContent");
      };
      classes.Frame._MC.overlay.emailIcon._visible = false;
      classes.Frame._MC.overlay.emailIcon.onRelease = function()
      {
         classes.Control.focusEmail();
      };
      classes.Frame._MC.overlay.fldEmail.autoSize = "right";
      this.destroyMap();
      classes.Frame._MC.hit._alpha = 0;
      classes.Frame._MC.hit.onPress = function()
      {
         classes.Frame._MC.startDrag(false);
         if(_root.chatWindow._x == classes.Frame._MC._x + _root.chatWindow.dockedAddX && _root.chatWindow._y == classes.Frame._MC._y + _root.chatWindow.dockedAddY)
         {
            _root.chatWindow.onMouseMove = function()
            {
               _root.chatWindow._x = classes.Frame._MC._x + _root.chatWindow.dockedAddX;
               _root.chatWindow._y = classes.Frame._MC._y + _root.chatWindow.dockedAddY;
            };
         }
      };
      classes.Frame._MC.hit.onRelease = classes.Frame._MC.hit.onReleaseOutside = function()
      {
         classes.Frame._MC.stopDrag();
         _root.chatWindow.onMouseMove();
         delete _root.chatWindow.onMouseMove;
      };
   }
   function CB_getSession(argObj)
   {
      if(argObj.result == 0)
      {
         classes.Frame._MC.txtFacebookMessage.text = "No matching Legends account! Log in and link accounts or create a new one";
      }
   }
   function createMap()
   {
      this.mapStatus = true;
      this.map = this.attachMovie("map","map",1,{_x:this.mapMask._x,_y:this.mapMask._y});
      this.map.bubblesGroup.court._visible = false;
      var _loc3_ = new Object();
      _loc3_.onLoadInit = this.promoLoaded;
      var _loc4_ = new MovieClipLoader();
      _loc4_.addListener(_loc3_);
      _loc4_.loadClip(_global.assetPath + "/misc/promos.swf",this.map.promos);
      this.map.setMask(this.mapMask);
      this.sectionHolder.sectionClip._visible = false;
   }
   function promoLoaded(target_mc)
   {
      classes.Frame._MC._promosTarget = target_mc;
      trace("promos.swf loaded");
      var _loc2_ = new Object();
      classes.Frame._MC._promosTarget.init(_loc2_);
   }
   function destroyMap()
   {
      this.mapStatus = false;
      classes.Frame._MC.map.removeMovieClip();
      delete classes.Frame._MC.map;
      classes.Frame._MC.sectionHolder.sectionClip._visible = true;
   }
   function resetMap()
   {
      this.mapStatus = true;
      classes.Frame._MC.map.removeMovieClip();
      delete classes.Frame._MC.map;
      this.createMap();
   }
   function initTabs()
   {
      classes.Frame._MC.overlay.tabNim._visible = false;
      classes.Frame._MC.overlay.tabNim.hilite._visible = false;
      classes.Frame._MC.overlay.tabNim.onRelease = function()
      {
         classes.Control.focusNim();
         classes.Control.removeTab(this);
      };
      classes.Frame._MC.overlay.tabEmail._visible = false;
      classes.Frame._MC.overlay.tabEmail.onRelease = function()
      {
         classes.Control.focusEmail("");
         classes.Control.removeTab(this);
      };
      classes.Frame._MC.overlay.tabViewer._visible = false;
      classes.Frame._MC.overlay.tabViewer.onRelease = function()
      {
         classes.Control.focusViewer();
         classes.Control.removeTab(this);
      };
      classes.Frame._MC.overlay.tabSupport._visible = false;
      classes.Frame._MC.overlay.tabSupport.onRelease = function()
      {
         trace("tabSupport released!");
         var _loc2_ = classes.SupportCenter.USER_TYPE;
         trace("user role: " + classes.GlobalData.role);
         if(classes.GlobalData.role == 1 || classes.GlobalData.role == 8)
         {
            _loc2_ = classes.SupportCenter.SENIOR_MOD_TYPE;
         }
         else if(classes.GlobalData.role == 2)
         {
            _loc2_ = classes.SupportCenter.MOD_TYPE;
         }
         classes.Control.focusSupportCenter(_loc2_);
         classes.Control.removeTab(this);
      };
   }
   function showSupportButton(bool)
   {
      classes.Frame._MC.overlay.btnSupport._visible = bool;
      if(bool == true)
      {
         classes.Frame._MC.overlay.btnSupport.onRelease = function()
         {
            trace("btnSupport released!");
            this._parent._parent.showSupportButton(false);
            var _loc3_ = classes.SupportCenter.USER_TYPE;
            _root.supportCenterPreLogin = new classes.SupportCenter();
            _root.supportCenterPreLogin.init(_root,classes.SupportCenter.USER,_loc3_,classes.data.SupportCenterData.ACCOUNT_RECOVERY_NOT_LOGGED_IN,-5.5,160);
         };
      }
   }
   function showModToolButton(bool)
   {
      trace("showModToolButton");
      if(bool == true)
      {
         trace(classes.Frame._MC.overlay.mvModTool);
         classes.Frame._MC.overlay.mvModTool._visible = true;
         classes.Effects.roBounce(classes.Frame._MC.overlay.mvModTool);
         classes.Frame._MC.overlay.mvModTool.onRelease = function()
         {
            var _loc1_ = classes.SupportCenter.USER_TYPE;
            if(classes.GlobalData.role == 1 || classes.GlobalData.role == 8)
            {
               _loc1_ = classes.SupportCenter.SENIOR_MOD_TYPE;
            }
            else if(classes.GlobalData.role == 2)
            {
               _loc1_ = classes.SupportCenter.MOD_TYPE;
            }
            classes.Control.focusModTools(_loc1_);
         };
      }
      else
      {
         classes.Frame._MC.overlay.mvModTool._visible = false;
      }
   }
   function showInitTabs()
   {
      classes.Control.dockViewer();
      classes.Control.dockEmail();
      classes.Control.dockSupportCenter();
      classes.Control.showTabs();
   }
   function updateLoginGroupUsernamePasswordAndLogin(username, password)
   {
      this.loginGroup.username = username;
      this.loginGroup.pass = password;
      this.loginGroup.facebookLogin = false;
      trace("login group username: " + username);
      trace("login group password: " + password);
      this.loginGroup.tryLogin();
   }
   function updateFBLoginGroupUsernamePasswordAndLogin(username, password)
   {
      trace("updateFBLoginGroupUsernamePasswordAndLogin");
      this.loginGroup.username = username;
      this.loginGroup.pass = password;
      this.loginGroup.fbUsername = username;
      this.loginGroup.fbPass = password;
      this.loginGroup.facebookLogin = true;
      trace("login group username: " + username);
      trace("login group password: " + password);
      this.loginGroup.tryLoginWithFB();
   }
   function goMainSection(sectionName, locID, skipToCar)
   {
      trace("goMainSection, " + sectionName + ", " + locID);
      this.destroyMap();
      classes.Control.setMapButton();
      var _loc6_;
      trace("member: " + _global.loginXML.firstChild.firstChild.attributes.mb);
      switch(sectionName)
      {
         case "home":
            _loc6_ = "sectionHome";
            break;
         case "shop":
            _loc6_ = "sectionShop";
            break;
         case "dealer":
            _loc6_ = "sectionDealer";
            break;
         case "teamhq":
            _loc6_ = "sectionTeamHQ";
            break;
         case "track":
            _loc6_ = "sectionTrack";
            break;
         case "impound":
            _loc6_ = "sectionImpound";
            break;
         case "classified":
            _loc6_ = "sectionClassified";
            break;
         case "modElection":
            _loc6_ = "sectionModElection";
            break;
         case "newsRoom":
            _loc6_ = "sectionNewsRoom";
      }
      if(classes.SectionModElection.MC)
      {
         classes.SectionModElection.MC.cleanUp();
      }
      classes.Frame._MC.sectionHolder.sectionClip.removeMovieClip();
      if(_loc6_)
      {
         classes.Frame._MC.sectionHolder.attachMovie(_loc6_,"sectionClip",1,{objectName:_loc6_,locationID:locID});
      }
      if(skipToCar)
      {
         classes.Frame._MC.sectionHolder.sectionClip.skipToCar = skipToCar;
      }
      else
      {
         classes.Frame._MC.sectionHolder.sectionClip.skipToCar = 0;
      }
   }
   static function serverLights(animate)
   {
      if(animate)
      {
         classes.Frame._MC.overlay.serverLights.light1.onEnterFrame = function()
         {
            if(Math.random() < 0.8)
            {
               this._visible = true;
            }
            else
            {
               this._visible = false;
            }
         };
         classes.Frame._MC.overlay.serverLights.light2.onEnterFrame = function()
         {
            if(Math.random() < 0.8)
            {
               this._visible = true;
            }
            else
            {
               this._visible = false;
            }
         };
      }
      else
      {
         classes.Frame._MC.overlay.serverLights.light1._visible = false;
         classes.Frame._MC.overlay.serverLights.light2._visible = false;
         delete classes.Frame._MC.overlay.serverLights.light1.onEnterFrame;
         delete classes.Frame._MC.overlay.serverLights.light2.onEnterFrame;
      }
   }
}
