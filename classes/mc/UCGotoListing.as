class classes.mc.UCGotoListing extends MovieClip
{
   var btnGo;
   var fldID;
   static var _mc;
   function UCGotoListing()
   {
      super();
      classes.mc.UCGotoListing._mc = this;
      var kListener = new Object();
      kListener.onKeyDown = function()
      {
         if(Key.getCode() == 13)
         {
            classes.mc.UCGotoListing._mc.btnGo.onRelease();
            Key.removeListener(kListener);
         }
      };
      this.fldID.onSetFocus = function()
      {
         Key.addListener(kListener);
      };
      this.fldID.onKillFocus = function()
      {
         Key.removeListener(kListener);
      };
      this.fldID.restrict = "0-9";
      this.btnGo.onRelease = function()
      {
         trace("is " + this._parent.id);
         if(this._parent.id.length)
         {
            classes.SectionClassified._mc.goDetail(Number(this._parent.id));
         }
      };
   }
}
