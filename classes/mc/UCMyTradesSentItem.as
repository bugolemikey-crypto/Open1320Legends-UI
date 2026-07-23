class classes.mc.UCMyTradesSentItem extends MovieClip
{
   var hi;
   var id;
   var isSelected;
   function UCMyTradesSentItem()
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
         classes.mc.UCMyListings._mc.setAllSelect();
         classes.mc.UCMyTradesSent._mc.setAllSelect(this._parent.id);
         classes.SectionClassified._mc.goTradesDetail(this._parent.nodeData);
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
