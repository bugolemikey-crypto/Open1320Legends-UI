class classes.SupportCenter
{
   var _badUser;
   var _currentSelection;
   var _dropDownMenu;
   var _error;
   var _goingBack;
   var _notLoggedIn;
   var _parent;
   var _selectedUserID;
   var _sm;
   var _supportCenterType;
   var _typeOfResultForm;
   var _userType;
   var accountID;
   var enabled;
   var isErrorForm;
   var sc;
   var sm;
   static var _callID = 1;
   static var USER = 1;
   static var MOD = 2;
   static var USER_TYPE = 1;
   static var MOD_TYPE = 2;
   static var SENIOR_MOD_TYPE = 3;
   static var NUM_OF_FIELDS = 7;
   function SupportCenter()
   {
   }
   function init(context, supportCenterType, userType, startHere, x, y, badUser, userID)
   {
      this._goingBack = false;
      this._error = false;
      this._notLoggedIn = false;
      this._userType = userType;
      var _loc5_;
      if(supportCenterType == classes.SupportCenter.USER)
      {
         _loc5_ = "scu";
      }
      else
      {
         _loc5_ = "scm";
      }
      trace("init!");
      this._badUser = "";
      this._sm = context.attachMovie("SupportCenterMovie",_loc5_,context.getNextHighestDepth());
      if(supportCenterType == classes.SupportCenter.USER)
      {
         _global.supportCenterLimitedAccessAlert = this._sm.limitedAccessAlert;
         classes.LimitedAccessFunctions.checkForLimitedAccessAlert(this._sm.limitedAccessAlert);
      }
      else
      {
         classes.LimitedAccessFunctions.showLimitedAccessAlert(false,this._sm.limitedAccessAlert);
      }
      this._sm._x = x;
      this._sm._y = y;
      this._supportCenterType = supportCenterType;
      trace("userType: " + userType);
      classes.data.SupportCenterData.init(userType,supportCenterType);
      var _loc4_ = new TextFormat();
      _loc4_.font = "ArialBold";
      this._sm.txtTitle.embedFonts = true;
      this._sm.txtTitle.setTextFormat(_loc4_);
      trace(this._sm.btnClose);
      this._sm.btnWinDrag.sm = this;
      this._sm.btnWinDrag.onPress = function()
      {
         trace("onPress");
         this.sm.swapDepths();
         trace(this._parent);
         this._parent.startDrag(false);
         trace("after startDrag");
      };
      this._sm.btnWinDrag.onRelease = this._sm.btnWinDrag.onReleaseOutside = function()
      {
         trace("onRelease");
         this._parent.stopDrag();
      };
      this._sm.btnWinDrag.useHandCursor = false;
      this._sm.btnClose.sc = this;
      this._sm.btnClose.onRelease = function()
      {
         trace("btnClose pushed!");
         this.sc.closeSupportCenter();
      };
      this._sm.btnBack.sc = this;
      this._sm.btnBack.onRelease = function()
      {
         trace("btnBack pushed!");
         this.sc.backButtonPushed();
      };
      if(!startHere)
      {
         startHere = 0;
      }
      this.gotoHere(startHere,badUser,userID);
   }
   function gotoHere(startHere, badUser, userID)
   {
      this.cleanUp();
      if(startHere && (startHere == classes.data.SupportCenterData.REPORT_MISCONDUCT || startHere == classes.data.SupportCenterData.USER_DETAILS))
      {
         if(badUser)
         {
            this._badUser = badUser;
         }
         if(userID)
         {
            trace("selectedUserID");
            trace(this._selectedUserID);
            this._selectedUserID = String(userID);
         }
      }
      if(this._supportCenterType == classes.SupportCenter.USER)
      {
         this._sm.bg.userBG._visible = true;
         this._sm.bg.modBG._visible = false;
         this._sm.userContent._visible = true;
         if(startHere == 0)
         {
            this._currentSelection = classes.data.SupportCenterData.getSelection(classes.data.SupportCenterData.MAIN_MENU,this._supportCenterType);
         }
         else if(startHere == classes.data.SupportCenterData.ACCOUNT_RECOVERY_NOT_LOGGED_IN)
         {
            trace("not logged in!");
            this._notLoggedIn = true;
            classes.LimitedAccessFunctions.showLimitedAccessAlert(false,this._sm.limitedAccessAlert);
            _global.supportCenterLimitedAccessAlert = null;
            this._currentSelection = classes.data.SupportCenterData.getSelection(classes.data.SupportCenterData.MAIN_MENU,this._supportCenterType);
         }
         else
         {
            this._currentSelection = classes.data.SupportCenterData.getSelection(startHere,this._supportCenterType);
         }
         this._sm.txtTitle.text = "Support Center";
         trace("txtTitle.text: " + this._sm.txtTitle.text);
      }
      else
      {
         this._sm.bg.userBG._visible = false;
         this._sm.bg.modBG._visible = true;
         this._sm.userContent._visible = false;
         if(startHere == 0)
         {
            this._currentSelection = classes.data.SupportCenterData.getSelection(classes.data.SupportCenterData.PLAYER_LOOKUP,this._supportCenterType);
         }
         else
         {
            this._currentSelection = classes.data.SupportCenterData.getSelection(startHere,this._supportCenterType);
         }
         this._sm.txtTitle.text = "Moderator Tools";
      }
      this.displayCurrentSelection();
   }
   function displayCurrentSelection()
   {
      trace("displayCurrentSelection");
      trace(this._currentSelection.objType);
      trace(this._currentSelection.priorItem);
      trace(this._currentSelection.index);
      if(this._currentSelection.priorItem && this._currentSelection.index != 0)
      {
         trace("btnBack visible!");
         this._sm.btnBack._visible = true;
         this._sm.btnBack.enabled = true;
      }
      else
      {
         trace("btnBack invisible!");
         this._sm.btnBack._visible = false;
         this._sm.btnBack.enabled = false;
      }
      switch(this._currentSelection.objType)
      {
         case classes.SupportCenterSelection.MENU:
            this.showThis(classes.SupportCenterSelection.MENU);
            this.displayMenu();
            break;
         case classes.SupportCenterSelection.FORM:
            this.showThis(classes.SupportCenterSelection.FORM);
            this.displayForm();
            break;
         case classes.SupportCenterSelection.PLAYER_LOOKUP:
            this.showThis(classes.SupportCenterSelection.PLAYER_LOOKUP);
            this.displayPlayerLookup();
            break;
         case classes.SupportCenterSelection.USER_DETAILS:
            this.showThis(classes.SupportCenterSelection.USER_DETAILS);
            this.displayUserDetails();
      }
      this._error = false;
      this._goingBack = false;
   }
   function showThis(whatToShow)
   {
      this._sm.form._visible = false;
      this._sm.scUserInfo._visible = false;
      this._sm.txtMenuTitle.text = "";
      switch(whatToShow)
      {
         case classes.SupportCenterSelection.MENU:
            this._sm.txtTitle._visible = true;
            break;
         case classes.SupportCenterSelection.FORM:
            this._sm.form._visible = true;
            break;
         case classes.SupportCenterSelection.PLAYER_LOOKUP:
         case classes.SupportCenterSelection.USER_DETAILS:
         default:
            return;
      }
   }
   function displayMenu()
   {
      trace("displayMenu");
      var _loc4_;
      var _loc6_ = 130;
      var _loc10_ = 112;
      var _loc11_ = 33;
      var _loc9_ = new TextFormat();
      _loc9_.font = "ArialBold";
      this._sm.txtMenuTitle.embedFonts = true;
      this._sm.txtMenuTitle.setTextFormat(_loc9_);
      this._sm.txtMenuTitle.text = this._currentSelection.theTitle;
      var _loc8_ = this._sm.menuButtonsHolder;
      _loc4_ = this._currentSelection.menuItems;
      if(_loc4_.length < 8)
      {
         _loc6_ = 130;
      }
      else
      {
         _loc6_ = 110;
      }
      var _loc7_ = 0;
      var _loc3_ = 0;
      var _loc2_;
      var _loc5_;
      for(; _loc3_ < _loc4_.length; _loc3_ = _loc3_ + 1)
      {
         if(this._supportCenterType == classes.SupportCenter.USER && this._currentSelection.index == classes.data.SupportCenterData.REPORT_MISCONDUCT)
         {
            _loc6_ = 130;
            if(_loc4_[_loc3_].itemIndex == classes.data.SupportCenterData.UNFAIRLY_BANNED_SOMEONE || _loc4_[_loc3_].itemIndex == classes.data.SupportCenterData.FALSE_MISCONDUCT_REPORT)
            {
               continue;
            }
         }
         _loc2_ = _loc8_.attachMovie("mvSupportCenterMenuButton","btnMenu" + _loc3_,_loc8_.getNextHighestDepth());
         _loc2_._x = _loc10_;
         _loc2_._y = _loc6_ + _loc7_ * _loc11_;
         _loc7_ = _loc7_ + 1;
         _loc2_.sc = this;
         _loc2_.tgt = _loc4_[_loc3_].itemIndex;
         _loc2_.displayText = _loc4_[_loc3_].displayText;
         trace(_loc2_);
         trace(_loc2_.btn);
         trace(_loc2_.txtBtn);
         trace(_loc2_.booyaa);
         trace(_loc4_[_loc3_].displayText);
         _loc5_ = _loc2_.txtBtn;
         _loc2_.txtBtnGray._visible = false;
         if(this._notLoggedIn == true)
         {
            if(this._currentSelection.index == classes.data.SupportCenterData.MAIN_MENU && _loc4_[_loc3_].itemIndex != classes.data.SupportCenterData.ACCOUNT_RECOVERY && _loc4_[_loc3_].itemIndex != classes.data.SupportCenterData.COMPROMISED_ACCOUNT)
            {
               _loc2_.txtBtnGray._visible = true;
               _loc2_.txtBtn._visible = false;
               _loc5_ = _loc2_.txtBtnGray;
               _loc2_.btn.enabled = false;
            }
         }
         _loc5_.setTextFormat(_loc9_);
         _loc5_.embedFonts = true;
         _loc5_.text = _loc4_[_loc3_].displayText;
         _loc2_.btn.onRelease = function()
         {
            trace(this._parent.sc);
            this._parent.sc.menuButtonPushed(this._parent.tgt,this._parent.displayText);
            trace("menuButtonPushed!");
         };
      }
   }
   function displaySubmissionResult(returnObj)
   {
      var _loc2_ = Number(returnObj.s);
      var _loc6_ = String(returnObj.m);
      var _loc5_ = String(returnObj.t);
      var _loc3_ = this._currentSelection.index;
      this._currentSelection = new classes.SupportCenterSelection(classes.SupportCenterSelection.FORM,null,"",0);
      this._currentSelection.priorItem = _loc3_;
      trace("errorCode: " + _loc2_);
      if(_loc2_ == 1)
      {
         this._currentSelection.errorForm = false;
      }
      else
      {
         this._currentSelection.errorForm = true;
      }
      this._currentSelection.ticketNumber = _loc5_;
      this._currentSelection.displayText = _loc6_;
      this._currentSelection.okButton = true;
      this.displayCurrentSelection();
   }
   function displayForm()
   {
      var _loc5_ = new TextFormat();
      _loc5_.font = "ArialBold";
      this._sm.form.txtTitle.embedFonts = true;
      this._sm.form.txtTitle.setTextFormat(_loc5_);
      this._sm.form.btnFormHolderMod._visible = false;
      this._sm.form.btnFormHolder._visible = false;
      this._sm.form.txtTitle.text = "";
      this._sm.form.txtTitle.text = this._currentSelection.theTitle;
      this._sm.form.txtContent.htmlText = "";
      this._sm.form.resultContent.text = "";
      if(this._currentSelection.index == 0)
      {
         if(this._typeOfResultForm == classes.SupportCenterSelection.REPORT_MISCONDUCT && this._currentSelection.errorForm == false && this._userType == classes.SupportCenter.USER_TYPE)
         {
            this._sm.form.txtTitle.text = "Thank you. Your misconduct report has been successfully submitted against " + this._badUser + ".";
            this._sm.form.txtContent.htmlText = "<br><br>Your report has been filed and will be investigated. Once the report has been properly investigated the appropriate action will be taken which may or may not include a ban. It is important to understand that not all reports have enough evidence to warrant action against the player.";
         }
         else if(this._currentSelection.ticketNumber != "0")
         {
            this._sm.form.txtContent.htmlText = "<font size=\'20\'>Support Claim Number:</font><br><font size=\'22\'>" + this._currentSelection.ticketNumber + "</font><br><br>" + this._currentSelection.displayText;
         }
         else
         {
            this._sm.form.resultContent.text = this._currentSelection.displayText;
         }
         if(this._currentSelection.errorForm == false)
         {
            this._badUser = "";
         }
      }
      else
      {
         this._sm.form.txtContent.htmlText = this._currentSelection.displayText;
      }
      trace("text title: " + this._sm.form.txtTitle.text);
      if(this._currentSelection.submitButton == true || this._currentSelection.okButton == true)
      {
         this._sm.form.btnFormHolder._visible = true;
         this._sm.form.btnFormHolder.btnForm.tabEnabled = false;
         this._sm.form.btnFormHolderMod.btnForm.tabEnabled = false;
         this._sm.form.btnFormHolder.btnForm.enabled = false;
         this._sm.form.btnFormHolderMod.btnForm.enabled = false;
         this._sm.form.btnFormHolder.btnForm.sc = this;
         this._sm.form.btnFormHolderMod.btnForm.sc = this;
         if(this._currentSelection.submitButton == true)
         {
            if(this._supportCenterType == classes.SupportCenter.USER)
            {
               this._sm.form.btnFormHolder._visible = true;
               this._sm.form.btnFormHolder.txtLabel.text = "SUBMIT";
               this._sm.form.btnFormHolder.btnForm.enabled = true;
               this._sm.form.btnFormHolder.btnForm.onRelease = function()
               {
                  trace("submit!");
                  trace(this);
                  trace(this.enabled);
                  this.enabled = false;
                  this.sc.submitButtonPushed();
               };
            }
            else
            {
               this._sm.form.btnFormHolderMod._visible = true;
               this._sm.form.btnFormHolderMod.btnForm.enabled = true;
               this._sm.form.btnFormHolderMod.btnForm.onRelease = function()
               {
                  this.enabled = false;
                  this.sc.banButtonPushed();
               };
            }
         }
         else
         {
            trace("okButton!");
            this._sm.form.btnFormHolder._visible = true;
            this._sm.form.btnFormHolder.txtLabel.text = "OK";
            this._sm.form.btnFormHolder.btnForm.isErrorForm = this._currentSelection.errorForm;
            this._sm.form.btnFormHolder.btnForm.enabled = true;
            this._sm.form.btnFormHolder.btnForm.onRelease = function()
            {
               this.enabled = false;
               if(this.isErrorForm == true)
               {
                  this.sc.okButtonPushedError();
               }
               else
               {
                  this.sc.okButtonPushed();
               }
            };
         }
      }
      var _loc2_ = 1;
      while(_loc2_ <= classes.SupportCenter.NUM_OF_FIELDS)
      {
         this._sm.form["formField" + _loc2_].fldForm.tabEnabled = false;
         this._sm.form["formField" + _loc2_]._visible = false;
         trace("_error: " + this._error);
         if(this._error == false && this._currentSelection.index != 0)
         {
            trace("error is false!");
            this._sm.form["formField" + _loc2_].fldForm.text = "";
         }
         _loc2_ = _loc2_ + 1;
      }
      trace("formFields.length");
      trace(this._currentSelection.formFields.length);
      _loc2_ = 0;
      var _loc4_;
      var _loc3_;
      while(_loc2_ < this._currentSelection.formFields.length)
      {
         _loc4_ = classes.data.SupportCenterData.getFormFieldsObject(this._currentSelection.formFields[_loc2_].fld);
         if(this._currentSelection.formFields[_loc2_].pos)
         {
            _loc3_ = this._currentSelection.formFields[_loc2_].pos;
         }
         else
         {
            _loc3_ = _loc4_.fieldNum;
         }
         _loc5_ = new TextFormat();
         _loc5_.color = _loc4_.labelColor;
         this._sm.form["formField" + _loc3_]._visible = true;
         this._sm.form["formField" + _loc3_].txtFieldTitle.setTextFormat(_loc5_);
         this._sm.form["formField" + _loc3_].txtFieldTitle.text = _loc4_.fieldLabel;
         this._sm.form["formField" + _loc3_].fldForm.tabEnabled = true;
         this._sm.form["formField" + _loc3_].fldForm.tabIndex = _loc2_;
         if(this._currentSelection.formFields[_loc2_].fld == classes.data.SupportCenterData.USERNAME_OF_OFFENDER && this._badUser.length > 0)
         {
            this._sm.form["formField" + _loc3_].fldForm.text = this._badUser;
         }
         else if(this._currentSelection.formFields[_loc2_].fld == classes.data.SupportCenterData.YOUR_EMAIL_ADDRESS && classes.GlobalData.attr.em)
         {
            this._sm.form["formField" + _loc3_].fldForm.text = classes.GlobalData.attr.em;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function displayPlayerLookup()
   {
      this._badUser = "";
      var _loc2_ = new TextFormat();
      _loc2_.font = "ArialBold";
      this._sm.txtMenuTitle.embedFonts = true;
      this._sm.txtMenuTitle.setTextFormat(_loc2_);
      this._sm.txtMenuTitle.text = this._currentSelection.theTitle;
      this._sm.attachMovie("SCPlayerLookupMovie","playerLookup",this._sm.getNextHighestDepth());
      this._sm.playerLookup._x = 111.8;
      this._sm.playerLookup._y = 138.4;
      this._dropDownMenu = new classes.ui.UserSearchDropDown2(this._sm.playerLookup,"scMenuBase","Arial","Arial",200,19.6,false,241,19.6,this,"2");
      this._sm.playerLookup.btnPlayerLookup.enabled = false;
      this._sm.playerLookup.btnPlayerLookup.sc = this;
      this._sm.playerLookup.btnPlayerLookup.onRelease = function()
      {
         this.sc.playerLookupPushed();
      };
   }
   function showUser(viewXML, context, x, y)
   {
      var _loc12_ = viewXML.firstChild.firstChild.attributes.i;
      var _loc2_ = Number(viewXML.firstChild.firstChild.attributes.ti);
      var _loc3_ = viewXML.firstChild.firstChild.attributes.tn;
      var _loc9_ = viewXML.firstChild.firstChild.attributes.u;
      var _loc5_ = viewXML.firstChild.firstChild.attributes.sc;
      var _loc10_ = context.attachMovie("userInfo","userInfo",context.getNextHighestDepth(),{_x:x,_y:y,uID:_loc12_,uName:_loc9_,tID:_loc2_,tName:_loc3_,uCred:_loc5_,showBadgesXML:new XML(viewXML.firstChild.firstChild.toString())});
   }
   function playerLookupPushed()
   {
      trace("playerLookupPushed");
      this._selectedUserID = this._dropDownMenu.currentSelected.value;
      this._badUser = this._dropDownMenu.currentSelected.label;
      this._dropDownMenu.destroy();
      var _loc2_ = this._currentSelection.index;
      this._currentSelection = classes.data.SupportCenterData.getSelection(classes.data.SupportCenterData.USER_DETAILS,this._supportCenterType);
      this._currentSelection.priorItem = _loc2_;
      this._sm.playerLookup.removeMovieClip();
      this.displayCurrentSelection();
   }
   function nomineeSelected(id)
   {
      this._sm.playerLookup.btnPlayerLookup.enabled = true;
   }
   function textEnteredInSearchBox()
   {
      this._sm.playerLookup.btnPlayerLookup.enabled = false;
   }
   function displayUserDetails()
   {
      this._sm.btnBack._visible = false;
      this._sm.btnBack.enabled = false;
      if(this._goingBack == false)
      {
         trace("displaying user: " + this._selectedUserID);
         if(this._sm.scUserInfo.userInfo)
         {
            this._sm.scUserInfo.userInfo.removeMovieClip();
         }
         this._sm.scUserInfo.mvViewBanHistory._visible = false;
         this._sm.scUserInfo.btnPendingMisconduct._visible = false;
         classes.Frame.serverLights(true);
         classes.Lookup.addCallback("getUser",this,this.CB_getUser,this._selectedUserID);
         _root.getUser(this._selectedUserID);
         classes.Lookup.addCallback("getMisconductCount",this,this.CB_getMisconductCount,this._selectedUserID);
         _root.getMisconductCount(Number(this._selectedUserID));
      }
      else
      {
         this.setupUserInfoDisplay();
      }
   }
   function CB_getMisconductCount(returnObj)
   {
      var _loc5_ = returnObj.r;
      var _loc3_ = returnObj.b;
      var accountID = returnObj.id;
      if(_loc3_ > 0)
      {
         this._sm.scUserInfo.mvViewBanHistory._visible = true;
         this._sm.scUserInfo.mvViewBanHistory.txtBanHistory.text = "View ban history: " + _loc3_;
         this._sm.scUserInfo.mvViewBanHistory.btnBanHistory.accountID = accountID;
         this._sm.scUserInfo.mvViewBanHistory.btnBanHistory.onRelease = function()
         {
            _root.openBanURL(this.accountID);
         };
      }
      if(_loc5_ > 0)
      {
         this._sm.scUserInfo.btnPendingMisconduct._visible = true;
         if(this._sm.scUserInfo.mvViewBanHistory._visible == true)
         {
            this._sm.scUserInfo.btnPendingMisconduct._y = 188;
         }
         else
         {
            this._sm.scUserInfo.btnPendingMisconduct._y = 154.5;
         }
         this._sm.scUserInfo.btnPendingMisconduct.accountID = accountID;
         this._sm.scUserInfo.btnPendingMisconduct.onRelease = function()
         {
            _root.openReportsURL(this.accountID);
         };
      }
   }
   function CB_getUser(d)
   {
      trace("CB_getUser");
      classes.Frame.serverLights(false);
      var _loc2_ = new XML(d);
      var _loc3_ = _loc2_.firstChild.firstChild.attributes.mb;
      trace("member: " + _loc2_.firstChild.firstChild.attributes.mb);
      trace("mb: " + _loc3_);
      if(_loc3_ == "True")
      {
         this._sm.scUserInfo.txtMember.text = "Member: YES";
      }
      else
      {
         this._sm.scUserInfo.txtMember.text = "Member: NO";
      }
      this.showUser(_loc2_,this._sm.scUserInfo,0,0);
      this.setupUserInfoDisplay();
   }
   function setupUserInfoDisplay()
   {
      trace("setupUserInfoDisplay");
      trace(this._sm.scUserInfo);
      this._sm.scUserInfo._visible = true;
      this._sm.btnBack._visible = true;
      this._sm.btnBack.enabled = true;
      this._sm.scUserInfo.btnBanPlayer.sc = this;
      this._sm.scUserInfo.btnBanPlayer.onRelease = function()
      {
         this.sc.btnBanPlayerPushed();
      };
   }
   function btnBanPlayerPushed()
   {
      trace("btnBanPlayerPushed");
      var _loc2_ = this._currentSelection.index;
      trace("priorSelectionIndex: " + _loc2_);
      this._currentSelection = classes.data.SupportCenterData.getSelection(classes.data.SupportCenterData.REPORT_MISCONDUCT,this._supportCenterType);
      this._currentSelection.priorItem = _loc2_;
      this.displayCurrentSelection();
   }
   function banButtonPushed()
   {
      trace("banButtonPushed");
      this._sm.form.btnFormHolderMod.btnForm.enabled = false;
      this.submitButtonPushed();
   }
   function submitButtonPushed()
   {
      this._sm.form.btnFormHolder.enabled = false;
      trace(this._sm.form.btnFormHolderMod.btnForm.enabled);
      trace(this._sm.form.btnFormHolder.btnForm.enabled);
      this._sm.form.btnFormHolderMod.btnForm.enabled = false;
      this._sm.form.btnFormHolder.btnForm.enabled = false;
      trace("submitButtonPushed");
      trace(this);
      trace(this._currentSelection);
      var _loc5_ = new classes.SupportCenterVars();
      trace(this._currentSelection.formFields.length);
      this._typeOfResultForm = this._currentSelection.resultFormType;
      var _loc4_ = 0;
      var _loc3_;
      while(_loc4_ < this._currentSelection.formFields.length)
      {
         _loc3_ = this._sm.form["formField" + this._currentSelection.formFields[_loc4_].pos].fldForm.text;
         trace("field: " + this._currentSelection.formFields[_loc4_].fld);
         trace("fieldvalue: " + _loc3_);
         trace(_loc3_.length);
         if(_loc3_.length == 0)
         {
            _loc3_ = " ";
         }
         switch(this._currentSelection.formFields[_loc4_].fld)
         {
            case classes.data.SupportCenterData.USERNAME_OF_COMPROMISED_ACCOUNT:
            case classes.data.SupportCenterData.PLAYER_NAME:
               _loc5_.playerName = _loc3_;
               break;
            case classes.data.SupportCenterData.YOUR_EMAIL_ADDRESS:
               _loc5_.email = _loc3_;
               break;
            case classes.data.SupportCenterData.USERNAME_OF_OFFENDER:
               _loc5_.offenderUsername = _loc3_;
               this._badUser = _loc3_;
               break;
            case classes.data.SupportCenterData.LINK_TO_PHISHING_SITE:
            case classes.data.SupportCenterData.LINK_TO_ILLEGAL_GAME_SITE:
            case classes.data.SupportCenterData.DESCRIPTION:
            case classes.data.SupportCenterData.DESCRIBE_BUG:
            case classes.data.SupportCenterData.PETITION:
            case classes.data.SupportCenterData.PURCHASE_CONFIRMATION_NUMBER:
               _loc5_.notes1 = _loc3_;
               break;
            case classes.data.SupportCenterData.STEPS_TO_REPRODUCE_BUG:
               _loc5_.notes2 = _loc3_;
         }
         _loc4_ = _loc4_ + 1;
      }
      trace("calling getSupport: " + this._currentSelection.supportID);
      var _loc6_ = classes.SupportCenter.callID;
      trace(_loc6_);
      classes.Lookup.addCallback("getSupport",this,this.displaySubmissionResult,String(_loc6_));
      _root.getSupport(this._currentSelection.supportID,_loc5_,_loc6_);
   }
   function okButtonPushed()
   {
      if(this._notLoggedIn == true)
      {
         this.gotoHere(classes.data.SupportCenterData.ACCOUNT_RECOVERY_NOT_LOGGED_IN);
      }
      else
      {
         this.gotoHere(0);
      }
   }
   function okButtonPushedError()
   {
      trace("okButtonPushedError()");
      trace(this._currentSelection.errorForm);
      if(this._currentSelection.errorForm == true)
      {
         this._error = true;
      }
      this.backButtonPushed();
   }
   function menuButtonPushed(selectionIndex, displayText)
   {
      trace("in menuButtonPushed");
      trace(this);
      trace(this._currentSelection);
      trace(selectionIndex);
      this.clearCurrentScreen();
      var _loc2_ = this._currentSelection.index;
      this._currentSelection = classes.data.SupportCenterData.getSelection(selectionIndex,this._supportCenterType);
      this._currentSelection.priorItem = _loc2_;
      this._currentSelection.theTitle = displayText;
      trace(this._currentSelection);
      this.displayCurrentSelection();
   }
   function clearCurrentScreen()
   {
      this.removeMenuButtons();
   }
   function removeMenuButtons()
   {
      trace("in removeMenuButtons");
      for(var _loc2_ in this._sm.menuButtonsHolder)
      {
         trace("child!");
         trace(_loc2_);
         this._sm.menuButtonsHolder[_loc2_].removeMovieClip();
      }
   }
   function backButtonPushed()
   {
      this._goingBack = true;
      this.clearCurrentScreen();
      this._currentSelection = classes.data.SupportCenterData.getSelection(this._currentSelection.priorItem,this._supportCenterType);
      trace(this._currentSelection);
      this.displayCurrentSelection();
   }
   function closeSupportCenter()
   {
      trace("clearing bad user!");
      trace("closing support center!");
      if(this._notLoggedIn == true)
      {
         this.cleanUp();
         this._sm.removeMovieClip();
         classes.Frame._MC.showSupportButton(true);
      }
      else if(this._supportCenterType == classes.SupportCenter.USER)
      {
         classes.Control.dockSupportCenter();
      }
      else
      {
         classes.Control.dockModTools();
      }
   }
   function set badUser(user)
   {
      this._badUser = this.badUser;
   }
   function get badUser()
   {
      return this._badUser;
   }
   function set _visible(bool)
   {
      this._sm._visible = bool;
   }
   function get _visible()
   {
      return this._sm._visible;
   }
   function set _x(x)
   {
      this._sm._x = x;
   }
   function get _x()
   {
      return this._sm._x;
   }
   function set _y(y)
   {
      this._sm._y = y;
   }
   function get _y()
   {
      return this._sm._y;
   }
   function swapDepths()
   {
      trace("swapping depths! support center");
      this._sm.swapDepths(this._sm._parent.getNextHighestDepth());
   }
   function cleanUp()
   {
      this._badUser = "";
      if(this._dropDownMenu)
      {
         this._dropDownMenu.destroy();
      }
      if(this._sm.scUserInfo.userInfo)
      {
         this._sm.scUserInfo.userInfo.removeMovieClip();
      }
      if(this._sm.playerLookup)
      {
         this._sm.playerLookup.removeMovieClip();
      }
      this.removeMenuButtons();
   }
   static function get callID()
   {
      return classes.SupportCenter._callID;
   }
}
