class classes.mc.UCMyListingsItem extends MovieClip
{
   var hi;
   var id;
   var isSelected;
   function UCMyListingsItem()
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
         classes.mc.UCMyListings._mc.setAllSelect(this._parent.id);
         classes.mc.UCMyTradesSent._mc.setAllSelect();
         classes.SectionClassified._mc.goMyListingsDetail(this._parent.id,this._parent.s);
      };
   }
   function setSelect(nid)
   {
      if(nid && nid == this.id)
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
