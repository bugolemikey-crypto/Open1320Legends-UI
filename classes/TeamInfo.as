class classes.TeamInfo extends MovieClip
{
   var badgeAreaWidth;
   var badges;
   var canChange;
   var fldCred;
   var fldName;
   var id;
   var photo;
   var scale;
   var tCred;
   var tID;
   var tName;
   var teamXML;
   function TeamInfo()
   {
      super();
      if(!this.scale)
      {
         this.scale = 100;
      }
      if(this.scale == 50)
      {
         this.badgeAreaWidth = 85;
      }
      else
      {
         this.badgeAreaWidth = 170 * this.scale / 100;
      }
      if(!this.tID)
      {
         this.tID = 0;
      }
      this.updateAvatar();
      this.photo._xscale = this.photo._yscale = this.scale;
      if(this.canChange)
      {
         this.photo.id = this.tID;
         this.photo.onRelease = function()
         {
            _root.aub = classes.AvatarUploadBox(_root.attachMovie("avatarUploadBox","aub",_root.getNextHighestDepth(),{id:this.id,avatarType:"teamavatars"}));
         };
      }
      this.fldName.text = this.tName;
      this.fldCred.text = String(this.tCred);
      this.showBadges(this.teamXML);
   }
   function updateAvatar()
   {
      trace("UPDATING TEAM AVATAR");
      classes.Drawing.portrait(this,this.tID,1,0,0,Math.ceil(100 / this.scale),false,"teamavatars",true);
   }
   function showBadges(bxml)
   {
      var _loc5_ = new Array();
      var _loc4_;
      trace("bxml: ");
      trace(bxml);
      var _loc2_ = 0;
      while(_loc2_ < bxml.firstChild.firstChild.childNodes.length)
      {
         trace(bxml.firstChild.firstChild.childNodes[_loc2_].nodeName);
         if(bxml.firstChild.firstChild.childNodes[_loc2_].nodeName == "b")
         {
            trace("found badge!");
            _loc4_ = bxml.firstChild.firstChild.childNodes[_loc2_].attributes;
            _loc5_.push(_loc4_);
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc6_ = false;
      classes.Badges.drawBadges(this.badges,_loc5_,this.badgeAreaWidth,_loc6_);
   }
}
