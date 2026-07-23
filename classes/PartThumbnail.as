class classes.PartThumbnail
{
   var _di;
   var _mcLoader;
   var _pcid;
   var _failNo = 0;
   function PartThumbnail(mc, pcid, pid, pt, di)
   {
      this._mcLoader = new MovieClipLoader();
      this._mcLoader.addListener(this);
      this._pcid = pcid;
      if(this._pcid == 165 || this._pcid == 167 || this._pcid == 168 || this._pcid == 169 || this._pcid == 170)
      {
         this._di = 1;
      }
      else
      {
         this._di = di;
      }
      this._mcLoader.loadClip("cache/parts/" + pt + pid + ".swf",mc);
      mc._visible = false;
   }
   function onLoadError(target_mc, errorCode)
   {
      this._failNo = this._failNo + 1;
      if(this._failNo == 1)
      {
         if(this._di)
         {
            this._mcLoader.loadClip("cache/parts/" + this._pcid + "_" + this._di + ".swf",target_mc);
         }
         else
         {
            this._failNo = this._failNo + 1;
            this._mcLoader.loadClip("cache/partCategories/" + this._pcid + ".swf",target_mc);
         }
      }
      else if(this._failNo == 2)
      {
         this._mcLoader.loadClip("cache/partCategories/" + this._pcid + ".swf",target_mc);
      }
   }
   function onLoadComplete(target_mc)
   {
      target_mc._visible = true;
      this._mcLoader.removeListener(this);
      delete this._mcLoader;
   }
}
