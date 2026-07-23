class classes.SectionClip extends MovieClip
{
   var clrOverlay;
   var image_bitmap;
   var img_mc;
   var myClr;
   function SectionClip()
   {
      super();
   }
   function getGridColorPoint(clr)
   {
      var _loc6_;
      var _loc7_ = 12;
      var _loc4_;
      var _loc3_;
      var _loc9_;
      var _loc5_ = 0;
      var _loc2_;
      while(_loc5_ < 16)
      {
         _loc2_ = 0;
         while(_loc2_ < 7)
         {
            _loc4_ = 1 + _loc5_ * _loc7_;
            _loc3_ = 1 + _loc2_ * _loc7_;
            _loc6_ = this.image_bitmap.getPixel(_loc4_,_loc3_);
            if(_loc6_ == clr)
            {
               _loc9_ = new flash.geom.Point(_loc4_ - 1,_loc3_ - 1);
               break;
            }
            _loc2_ = _loc2_ + 1;
         }
         if(_loc6_ == clr)
         {
            break;
         }
         _loc5_ = _loc5_ + 1;
      }
      return _loc9_;
   }
   function setGridColorHilite(pp)
   {
      if(pp != undefined)
      {
         this.img_mc.hilite._x = pp.x;
         this.img_mc.hilite._y = pp.y;
         this.img_mc.hilite._visible = true;
      }
      else
      {
         this.img_mc.hilite._visible = false;
      }
   }
   function paintOverlay(clr)
   {
      this.myClr.setRGB(Number("0x" + clr));
      this.clrOverlay._alpha = 80;
   }
}
