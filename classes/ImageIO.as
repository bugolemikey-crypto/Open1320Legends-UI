class classes.ImageIO
{
   var _aid;
   var _alpha;
   var _mv;
   var listener;
   var mcLoader;
   var onEnterFrame;
   var _avatarType = "avatars";
   function ImageIO()
   {
      this.listener = new Object();
      this.listener.onLoadError = function(target, errorCode)
      {
         this.showDefaultAvatar();
      };
      this.listener.onLoadComplete = function(target)
      {
         target.onEnterFrame = function()
         {
            if(this._alpha < 100)
            {
               this._alpha += 20;
            }
            else
            {
               this._alpha = 100;
               delete this.onEnterFrame;
            }
         };
         this.mcLoader.removeListener(this);
      };
      this.mcLoader = new MovieClipLoader();
      this.mcLoader.addListener(this.listener);
   }
   function set avatarType(at)
   {
      this._avatarType = at;
   }
   function loadAvatar(mv, aid, noCache)
   {
      this._aid = aid;
      this._mv = mv;
      _root.getAvatar(this._aid,this,this._avatarType,noCache);
   }
   function showAvatar()
   {
      trace("showAvatar: " + this._aid);
      this.mcLoader.loadClip("cache/" + this._avatarType + "/" + this._aid + ".jpg",this._mv);
   }
   function showDefaultAvatar()
   {
      trace("showDefaultAvatar: " + this._aid);
      if(this._avatarType == "teamavatars")
      {
         this._mv.attachMovie("portraitTeamAvatar","noImage",1);
      }
      else
      {
         this._mv.attachMovie("portrait_offline","noImage",1);
      }
      this._mv.onEnterFrame = function()
      {
         if(this._alpha < 100)
         {
            this._alpha += 20;
         }
         else
         {
            this._alpha = 100;
            delete this.onEnterFrame;
         }
      };
      this.mcLoader.removeListener(this.listener);
   }
   function idToPath(aid)
   {
      return Math.floor(aid / 1000000).toString() + "/" + Math.floor(aid / 10000 % 100).toString() + "/" + Math.floor(aid / 100 % 100).toString() + "/" + Math.floor(aid % 100).toString();
   }
}
