class classes.RemarkControl extends MovieClip
{
   var _nonDelete;
   var _rid;
   var btnDelete;
   var btnSave;
   var btnUnlock;
   function RemarkControl()
   {
      super();
      this.btnUnlock.onRelease = function()
      {
         _root.setRemarkDeletes(this._parent._rid);
      };
      this.btnSave.onRelease = function()
      {
         _root.setRemarkNonDeletes(this._parent._rid);
      };
      this.btnDelete.onRelease = function()
      {
         _root.deleteRemark(this._parent._rid);
      };
   }
   function set rid(i)
   {
      this._rid = i;
   }
   function set nonDelete(nd)
   {
      trace(nd);
      this._nonDelete = nd;
      if(nd == 1)
      {
         this.btnUnlock._visible = true;
         this.btnSave._visible = false;
         this.btnDelete._visible = false;
      }
      else
      {
         this.btnUnlock._visible = false;
         this.btnSave._visible = true;
         this.btnDelete._visible = true;
      }
   }
}
