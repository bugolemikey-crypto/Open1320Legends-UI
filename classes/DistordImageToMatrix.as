class classes.DistordImageToMatrix
{
   var _h;
   var _hsLen;
   var _hseg;
   var _mc;
   var _mtx;
   var _p;
   var _sMat;
   var _tMat;
   var _texture;
   var _tri;
   var _vsLen;
   var _vseg;
   var _w;
   var _xMax;
   var _xMin;
   var _yMax;
   var _yMin;
   function DistordImageToMatrix(mc, bmp, mtx)
   {
      this._mc = mc;
      this._texture = bmp;
      this._mtx = mtx;
      this._vseg = this._mtx.length - 1;
      this._hseg = this._mtx[0].length - 1;
      this._w = this._texture.width;
      this._h = this._texture.height;
      this.__init();
   }
   function __init(Void)
   {
      this._p = new Array();
      this._tri = new Array();
      var _loc9_ = this._w / 2;
      var _loc8_ = this._h / 2;
      this._xMin = this._yMin = 0;
      this._xMax = this._w;
      this._yMax = this._h;
      this._hsLen = this._w / this._hseg;
      this._vsLen = this._h / this._vseg;
      var _loc7_;
      var _loc6_;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this._vseg + 1)
      {
         _loc2_ = 0;
         while(_loc2_ < this._hseg + 1)
         {
            _loc7_ = _loc2_ * this._hsLen;
            _loc6_ = _loc3_ * this._vsLen;
            this._p.push({x:_loc7_,y:_loc6_,sx:this._mtx[_loc3_][_loc2_][0],sy:this._mtx[_loc3_][_loc2_][1]});
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
      _loc3_ = 0;
      while(_loc3_ < this._vseg)
      {
         _loc2_ = 0;
         while(_loc2_ < this._hseg)
         {
            this._tri.push([this._p[_loc2_ + _loc3_ * (this._hseg + 1)],this._p[_loc2_ + _loc3_ * (this._hseg + 1) + 1],this._p[_loc2_ + (_loc3_ + 1) * (this._hseg + 1)]]);
            this._tri.push([this._p[_loc2_ + (_loc3_ + 1) * (this._hseg + 1) + 1],this._p[_loc2_ + (_loc3_ + 1) * (this._hseg + 1)],this._p[_loc2_ + _loc3_ * (this._hseg + 1) + 1]]);
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.__render();
   }
   function setTransform(x0, y0, x1, y1, x2, y2, x3, y3)
   {
      var _loc26_ = this._w;
      var _loc25_ = this._h;
      var _loc21_ = x3 - x0;
      var _loc23_ = y3 - y0;
      var _loc22_ = x2 - x1;
      var _loc24_ = y2 - y1;
      var _loc16_ = this._p.length;
      var _loc4_;
      var _loc3_;
      var _loc2_;
      var _loc6_;
      var _loc7_;
      var _loc12_;
      var _loc15_;
      var _loc14_;
      var _loc8_;
      var _loc5_;
      var _loc11_;
      var _loc13_;
      var _loc10_;
      var _loc9_;
      while((_loc16_ = _loc16_ - 1) > -1)
      {
         _loc4_ = this._p[_loc16_];
         _loc3_ = (_loc4_.x - this._xMin) / _loc26_;
         _loc2_ = (_loc4_.y - this._yMin) / _loc25_;
         _loc6_ = y3 - y0;
         _loc7_ = y2 - y1;
         if(_loc6_ <= _loc7_)
         {
            _loc12_ = _loc6_ / _loc7_;
            _loc15_ = Math.pow(1 - _loc3_,0.65);
            _loc14_ = Math.pow(_loc12_,_loc15_);
            _loc3_ *= _loc14_;
         }
         else
         {
            _loc12_ = _loc7_ / _loc6_;
            _loc15_ = Math.pow(_loc3_,0.65);
            _loc14_ = Math.pow(_loc12_,_loc15_);
            _loc3_ = 1 - (1 - _loc3_) * _loc14_;
         }
         _loc8_ = x1 - x0;
         _loc5_ = x2 - x3;
         if(_loc8_ < _loc5_)
         {
            _loc11_ = _loc8_ / _loc5_;
            _loc15_ = Math.pow(1 - _loc2_,1.4);
            _loc13_ = Math.pow(_loc11_,_loc15_);
            _loc2_ *= _loc13_;
         }
         else
         {
            _loc11_ = _loc8_ / _loc5_;
            _loc15_ = Math.pow(1 - _loc2_,0.9);
            _loc13_ = Math.pow(_loc11_,_loc15_);
            _loc2_ *= _loc13_;
         }
         _loc10_ = x0 + _loc2_ * _loc21_;
         _loc9_ = y0 + _loc2_ * _loc23_;
         _loc4_.sx = _loc10_ + _loc3_ * (x1 + _loc2_ * _loc22_ - _loc10_);
         _loc4_.sy = _loc9_ + _loc3_ * (y1 + _loc2_ * _loc24_ - _loc9_);
      }
      this.__render();
   }
   function __render(Void)
   {
      var _loc20_;
      var _loc21_;
      var _loc7_;
      var _loc6_;
      var _loc5_;
      var _loc4_ = this._mc;
      var _loc10_;
      _loc4_.clear();
      this._sMat = new flash.geom.Matrix();
      this._tMat = new flash.geom.Matrix();
      var _loc19_ = this._tri.length;
      var _loc3_;
      var _loc2_;
      var _loc14_;
      var _loc12_;
      var _loc13_;
      var _loc11_;
      var _loc9_;
      var _loc8_;
      var _loc18_;
      var _loc16_;
      var _loc17_;
      var _loc15_;
      while((_loc19_ = _loc19_ - 1) > -1)
      {
         _loc10_ = this._tri[_loc19_];
         _loc7_ = _loc10_[0];
         _loc6_ = _loc10_[1];
         _loc5_ = _loc10_[2];
         _loc3_ = _loc7_.sx;
         _loc2_ = _loc7_.sy;
         _loc14_ = _loc6_.sx;
         _loc12_ = _loc6_.sy;
         _loc13_ = _loc5_.sx;
         _loc11_ = _loc5_.sy;
         _loc9_ = _loc7_.x;
         _loc8_ = _loc7_.y;
         _loc18_ = _loc6_.x;
         _loc16_ = _loc6_.y;
         _loc17_ = _loc5_.x;
         _loc15_ = _loc5_.y;
         this._tMat.tx = _loc9_;
         this._tMat.ty = _loc8_;
         this._tMat.a = (_loc18_ - _loc9_) / this._w;
         this._tMat.b = (_loc16_ - _loc8_) / this._w;
         this._tMat.c = (_loc17_ - _loc9_) / this._h;
         this._tMat.d = (_loc15_ - _loc8_) / this._h;
         this._sMat.a = (_loc14_ - _loc3_) / this._w;
         this._sMat.b = (_loc12_ - _loc2_) / this._w;
         this._sMat.c = (_loc13_ - _loc3_) / this._h;
         this._sMat.d = (_loc11_ - _loc2_) / this._h;
         this._sMat.tx = _loc3_;
         this._sMat.ty = _loc2_;
         this._tMat.invert();
         this._tMat.concat(this._sMat);
         _loc4_.beginBitmapFill(this._texture,this._tMat,false,true,true);
         _loc4_.moveTo(_loc3_,_loc2_);
         _loc4_.lineTo(_loc14_,_loc12_);
         _loc4_.lineTo(_loc13_,_loc11_);
         _loc4_.endFill();
      }
   }
}
