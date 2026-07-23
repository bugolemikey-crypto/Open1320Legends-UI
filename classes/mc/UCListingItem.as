class classes.mc.UCListingItem extends MovieClip
{
   var hi;
   var id;
   var isSelected;
   function UCListingItem()
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
         classes.mc.UCListing._mc.setAllSelect(this._parent.id);
         classes.SectionClassified._mc.goDetail(this._parent.id);
      };
   }
   function setSelect(nid)
   {
      if(nid == this.id)
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
