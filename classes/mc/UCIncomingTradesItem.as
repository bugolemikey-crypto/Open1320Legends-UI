class classes.mc.UCIncomingTradesItem extends MovieClip
{
   var hi;
   var id;
   var isSelected;
   function UCIncomingTradesItem()
   {
      super();
      this.hi._alpha = 0;
      this.hi.onRollOver = function()
      {
         this._alpha = 100;
      };
      this.hi.onRollOut = function()
      {
         if(!this._parent.isSelected)
         {
            this._alpha = 0;
         }
      };
      this.hi.onRelease = function()
      {
         classes.SectionClassified._mc.goIncomingTradesDetail(this._parent.nodeData);
      };
   }
   function setSelect(nid)
   {
      if(nid.length && nid == this.id)
      {
         this.isSelected = true;
      }
      else
      {
         this.isSelected = false;
         this.hi.onRollOut();
      }
   }
}
