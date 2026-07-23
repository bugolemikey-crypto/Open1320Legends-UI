class classes.UserInfo extends MovieClip
{
   var badgeAreaWidth;
   var badges;
   var badgesReceived;
   var changeAvatarEnabled;
   var fldName;
   var id;
   var isReversed;
   var photo;
   var scDial;
   var scale;
   var showBadgesXML;
   var tID;
   var tName;
   var teamGroup;
   var uCred;
   var uID;
   var uName;
   function UserInfo()
   {
      super();
      trace("UserInfo Parent: " + this._parent);
      trace(_root);
      trace(_root.badgesHolder);
      this.teamGroup._visible = false;
      if(!this.scale)
      {
         this.scale = 100;
      }
      if(this.scale == 50)
      {
         this.badgeAreaWidth = 103;
      }
      else
      {
         this.badgeAreaWidth = 206 * this.scale / 100;
      }
      trace("hello");
      this.init();
   }
   function init()
   {
      trace("init");
      var _loc4_;
      if(this.tID)
      {
         this.teamGroup.createEmptyMovieClip("pic",this.teamGroup.getNextHighestDepth());
         this.teamGroup.pic._xscale = this.teamGroup.pic._yscale = 50;
         this.teamGroup.pic._y = -5;
         this.teamGroup.pic.id = this.tID;
         this.teamGroup.pic.onRelease = function()
         {
            classes.Control.focusViewer(null,null,this.id);
         };
         classes.Drawing.portrait(this.teamGroup.pic,this.tID,1,0,0,2,false,"teamavatars");
         if(this.tName)
         {
            this.teamGroup.fldTeam.text = this.tName;
            this.teamGroup._visible = true;
         }
         else if(this.tID)
         {
            _loc4_ = function(d)
            {
               var _loc3_ = new XML(d);
               var _loc2_ = _loc3_.firstChild.firstChild.attributes.n;
               if(_loc2_)
               {
                  this.teamGroup.fldTeam.text = _loc2_;
               }
               else
               {
                  this.teamGroup._visible = false;
               }
            };
            classes.Lookup.addCallback("teamInfo",this,_loc4_,"");
            _root.teamInfo(this.tID);
         }
      }
      if(this.isReversed)
      {
         classes.Drawing.portrait(this,this.uID,1,289,0,Math.ceil(100 / this.scale));
      }
      else
      {
         classes.Drawing.portrait(this,this.uID,1,0,0,Math.ceil(100 / this.scale));
      }
      this.photo.uID = this.uID;
      if(this.changeAvatarEnabled && this.uID == classes.GlobalData.id)
      {
         this.photo.onRelease = function()
         {
            _root.aub = classes.AvatarUploadBox(_root.attachMovie("avatarUploadBox","aub",_root.getNextHighestDepth(),{id:this.uID,avatarType:"avatars"}));
         };
      }
      else
      {
         this.photo.onRelease = function()
         {
            classes.Control.focusViewer(this.uID);
         };
      }
      this.photo._xscale = this.photo._yscale = this.scale;
      this.fldName.text = this.uName;
      classes.SCDial.setSCDial(this.scDial,this.uCred);
      this.scDial.uCred = this.uCred;
      this.scDial.hot.onRelease = function()
      {
         classes.Control.dialogContainer("dialogStreetCredAnalysisContent",{sc:this._parent.uCred});
      };
      this.badgesReceived = false;
      this.getBadges();
   }
   function updateAvatar()
   {
      classes.Drawing.portrait(this,this.uID,1,0,0,Math.ceil(100 / this.scale));
   }
   function updateCred(nsc)
   {
      this.uCred = nsc;
      this.scDial.ticks.txt = String(this.uCred);
   }
   function CB_getBadges(d)
   {
      var _loc2_ = new XML(d);
      this.showBadgesXML = new XML(_loc2_.firstChild.firstChild.toString());
      false;
      this.badgesReceived = true;
      trace("badges received");
      this.showBadges();
   }
   function getBadges()
   {
      trace("getBadges: " + this.showBadgesXML);
      if(!this.showBadgesXML)
      {
         if(Number(this.uID))
         {
            trace("get badges");
            classes.Lookup.addCallback("getUser",this,this.CB_getBadges,String(this.uID));
            _root.getUser(this.uID);
         }
      }
      else
      {
         this.badgesReceived = true;
         trace("already had badges");
         this.showBadges();
      }
   }
   function showBadges()
   {
      trace("root!: " + _root);
      trace("parent!: " + this._parent);
      var _loc4_ = new Array();
      var _loc3_ = 0;
      while(_loc3_ < this.showBadgesXML.firstChild.childNodes.length)
      {
         if(this.showBadgesXML.firstChild.childNodes[_loc3_].attributes.v == "1")
         {
            _loc4_.push(this.showBadgesXML.firstChild.childNodes[_loc3_].attributes);
         }
         _loc3_ = _loc3_ + 1;
      }
      classes.Badges.drawBadges(this.badges,_loc4_,this.badgeAreaWidth,this.isReversed);
   }
   function showBadge(show, badgeNumber)
   {
      var _loc4_ = _global.badgesXML.firstChild.childNodes.length;
      var _loc3_ = 0;
      while(_loc3_ < _loc4_)
      {
         if(badgeNumber == this.showBadgesXML.firstChild.childNodes[_loc3_].attributes.i)
         {
            if(show == true)
            {
               trace("show=true");
               this.showBadgesXML.firstChild.childNodes[_loc3_].attributes.v = "1";
            }
            else
            {
               trace("show=false");
               this.showBadgesXML.firstChild.childNodes[_loc3_].attributes.v = "0";
            }
            break;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.showBadges();
   }
}
