class classes.RaceOpponent
{
   var arr;
   var iLast;
   var vv;
   function RaceOpponent()
   {
      this.arr = new Array();
      this.iLast = 0;
      this.vv = 0;
   }
   function addInt(tObj)
   {
      this.arr.push(tObj);
   }
   function getPos(t, lastTS)
   {
      var _loc8_ = 0.7;
      var _loc4_ = Math.max(0,t - _loc8_ * 1000);
      var _loc3_ = 0;
      var _loc5_ = this.arr.length;
      var _loc2_ = this.iLast;
      while(_loc2_ < _loc5_)
      {
         if(this.arr[_loc2_].t > _loc4_)
         {
            break;
         }
         _loc3_ = _loc2_;
         _loc2_ = _loc2_ + 1;
      }
      var _loc6_;
      var _loc7_;
      var _loc10_;
      var _loc9_;
      var _loc11_;
      var _loc12_;
      if(isNaN(this.arr[_loc3_ + 1].t))
      {
         _loc7_ = (t - this.arr[_loc3_].t) / 1000;
         if(!_loc7_)
         {
            _loc7_ = (new Date() - lastTS) / 1000;
            _loc6_ = this.arr[_loc3_].d + this.arr[_loc3_].v * _loc7_ + 0.5 * this.arr[_loc3_].a * _loc7_ * _loc7_;
         }
         else
         {
            _loc6_ = this.arr[_loc3_].d + this.arr[_loc3_].v * _loc7_ + 0.5 * this.arr[_loc3_].a * _loc7_ * _loc7_;
         }
      }
      else
      {
         _loc10_ = this.arr[_loc3_ + 1].t - this.arr[_loc3_].t;
         _loc7_ = _loc10_ / 1000;
         _loc9_ = (_loc4_ - this.arr[_loc3_].t) / _loc10_;
         _loc11_ = this.arr[_loc3_].d + (this.arr[_loc3_ + 1].d - this.arr[_loc3_].d) * _loc9_;
         _loc12_ = Math.max(0,this.arr[_loc3_].v + (this.arr[_loc3_ + 1].v - this.arr[_loc3_].v) * _loc9_ + 0.5 * this.arr[_loc3_ + 1].a * _loc7_ * _loc7_);
         _loc6_ = _loc11_ + _loc12_ * _loc8_;
      }
      if(isNaN(_loc6_))
      {
         return -13;
      }
      return _loc6_;
   }
}
