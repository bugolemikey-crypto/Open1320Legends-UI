class classes.threeD
{
   function threeD()
   {
   }
   static function cPtToPoint(cPt, vanishPt)
   {
      var _loc3_ = new flash.geom.Point();
      var _loc4_;
      if(!vanishPt)
      {
         vanishPt = new Object();
         vanishPt.x = 400;
         vanishPt.y = 300;
         vanishPt.z = -1000;
      }
      _loc4_ = cPt.z / vanishPt.z;
      _loc3_.x = cPt.x + _loc4_ * (vanishPt.x - cPt.x);
      _loc3_.y = cPt.y + _loc4_ * (vanishPt.y - cPt.y);
      return _loc3_;
   }
}
