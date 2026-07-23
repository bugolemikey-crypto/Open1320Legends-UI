class classes.AvatarUploadBox extends classes.BaseBox
{
   var _fileRef;
   var _listener;
   var _parent;
   var addButton;
   var addDisabledButton;
   var clearButtons;
   var contentMC;
   var id = 18;
   var avatarType = "avatars";
   function AvatarUploadBox()
   {
      super();
      this.contentMC.avatarMC.swapDepths(this.contentMC.boxLine);
      this.contentMC.icoError.swapDepths(this.contentMC.avatarMC);
      this._listener = new Object();
      this._listener._parent = this;
      this._listener.onRelease = function(theButton, keepBoxOpen)
      {
         trace("listener action");
         var _loc3_;
         var _loc2_;
         switch(theButton.btnLabel.text)
         {
            case "Continue":
               trace("cont");
               this._parent.showUpload();
               break;
            case "Cancel":
               break;
            case "Upload":
               this._parent.doUpload();
               break;
            case "Browse":
               _loc3_ = new Array();
               _loc2_ = new Object();
               _loc2_.description = "JPEGs (*.jpg, *.jpeg)";
               _loc2_.extension = "*.jpg; *.jpeg";
               _loc3_.push(_loc2_);
               this._parent._fileRef.browse(_loc3_);
         }
         if(!keepBoxOpen)
         {
            false;
            theButton._parent._parent.removeMovieClip();
         }
      };
      var _loc4_ = new Object();
      _loc4_._parent = this;
      _loc4_.onSelect = function(file)
      {
         var _loc3_ = new LoadVars();
         _loc3_.t = this._parent.avatarType;
         _loc3_.fn = file.name;
         _loc3_.id = this._parent.id;
         _root.avatarUploadRequest(_loc3_);
      };
      _loc4_.onProgress = function(file, bytesLoaded, bytesTotal)
      {
         this._parent.contentMC.progBar._xscale = bytesLoaded / bytesTotal * 100;
      };
      _loc4_.onComplete = function(file)
      {
         this._parent.showSuccess();
      };
      _loc4_.onHTTPError = function(file, httpError)
      {
         trace("onHTTPError: " + file.name);
         trace("httpError: " + httpError);
         switch(httpError)
         {
            case 404:
               this._parent.showError("The image you have selected does not meet the file requirements below. Please try again\n\nRequirements:\nFormat: JPG");
               break;
            case 406:
               this._parent.showError("The image size you have selected is too large. Please try again\n\nRequirements:\nSize limit: 1MB");
               break;
            case 407:
               this._parent.showError("The image you have selected does not meet the file requirements below. Please try again\n\nRequirements:\nImage size: 96 x 80 pixels");
               break;
            case 408:
               this._parent.showError("The image you have selected does not meet the file requirements below. Please try again\n\nRequirements:\nFormat: JPG");
               break;
            case 409:
               this._parent.showError("Database writing error.");
               break;
            case 410:
               this._parent.showError("Script error.");
            default:
               return;
         }
      };
      _loc4_.onIOError = function(file)
      {
         this._parent.showError("Script error.");
      };
      _loc4_.onSecurityError = function(file, errorString)
      {
         this._parent.showError("Script error.");
      };
      this._fileRef = new flash.net.FileReference();
      this._fileRef.addListener(_loc4_);
      this.showInstruction();
   }
   function showInstruction()
   {
      this.clearButtons();
      this.addButton("Continue",true);
      this.addButton("Close");
      this.contentMC.lblTitle.text = "Avatar Upload";
      this.contentMC.icoError._visible = false;
      this.contentMC.lblMessage.text = "Warning:\nThis game does not allow the use of any pornographic, racist, or offensive material.  Uploading imagery of this nature will be cause for the account to banned without question.";
      this.contentMC.progBar._visible = false;
      this.loadAvatar();
   }
   function showUpload()
   {
      this.clearButtons();
      this.addButton("Browse",true);
      this.addButton("Cancel");
      this.contentMC.lblTitle.text = "Avatar Upload";
      this.contentMC.icoError._visible = false;
      this.contentMC.lblMessage.text = "Click the browse button to search your computer for the image you would like to use as your avatar. Once you have selected your image, click OK to upload.\n\nRequired Format: JPG\nSuggested size: 96 x 80 pixels";
   }
   function showUploadProgress()
   {
      this.clearButtons();
      this.addDisabledButton("Browse");
      this.addDisabledButton("Cancel");
      this.contentMC.lblTitle.text = "Avatar Upload";
      this.contentMC.icoError._visible = false;
      this.contentMC.lblMessage.text = "";
      this.contentMC.progBar._xscale = 0;
      this.contentMC.progBar._visible = true;
   }
   function showSuccess()
   {
      this.loadAvatar();
      this.clearButtons();
      this.addButton("Browse",true);
      this.addButton("OK");
      this.contentMC.lblTitle.text = "Avatar Upload";
      this.contentMC.icoError._visible = false;
      this.contentMC.lblMessage.text = "Your new avatar has been successfully loaded!\nIf you are satisfied with your new avatar click OK.\nIf not, you can continue to browse by clicking the browse button.";
      this.contentMC.progBar._visible = false;
      switch(this.avatarType)
      {
         case "avatars":
            classes.SectionHome.__MC.userInfo.updateAvatar();
            break;
         case "teamavatars":
            classes.SectionTeamHQ._MC.teamAvatar.teamInfo.updateAvatar();
         default:
            return;
      }
   }
   function showError(e)
   {
      this.clearButtons();
      this.addButton("Browse",true);
      this.addButton("Cancel");
      this.contentMC.lblTitle.text = "Error";
      this.contentMC.icoError._visible = true;
      this.contentMC.lblMessage.text = e;
      this.contentMC.progBar._visible = false;
   }
   function uploadRequestCB(s)
   {
      if(s == 1)
      {
         this.showReadyToUpload();
      }
      else if(s == 0)
      {
         this.showError("Connection error. Please try again.");
      }
      else if(s == -1)
      {
         this.showError("You do not have a permission to update this avatar.");
      }
   }
   function showReadyToUpload()
   {
      this.clearButtons();
      this.addButton("Upload",true);
      this.addButton("Cancel");
      this.contentMC.lblTitle.text = "Avatar Upload";
      this.contentMC.icoError._visible = false;
      this.contentMC.lblMessage.text = "Your image is ready. Click Upload to send it.";
      this.contentMC.progBar._visible = false;
   }
   function doUpload()
   {
      if(!this._fileRef.upload(_global.mainURL + "AccountUpload.aspx"))
      {
         this.showError("File upload error. Please try again.");
      }
      else
      {
         this.showUploadProgress();
      }
   }
   function loadAvatar()
   {
      classes.Drawing.portrait(this.contentMC.avatarMC,this.id,2,0,0,1,false,this.avatarType,true);
   }
}
