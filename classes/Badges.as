class classes.Badges
{
   function Badges()
   {
   }
   static function drawBadges(_mc, tArr, badgeAreaWidth, isReversed)
   {
      var _loc12_ = 0;
      var _loc20_ = 0;
      var _loc9_ = 37;
      for(var _loc16_ in _mc)
      {
         trace("children: " + _mc[_loc16_] + " " + _loc16_);
         trace("name: " + _mc[_loc16_].name.substr(0,3));
         trace("removing movie clip");
         trace(_mc[_loc16_]);
         _mc[_loc16_].removeMovieClip();
      }
      var _loc6_;
      var _loc10_;
      var _loc3_;
      var _loc8_;
      var _loc5_;
      var _loc17_;
      var _loc19_;
      var _loc11_;
      var _loc14_;
      var _loc7_;
      if(tArr.length)
      {
         _loc6_ = 0;
         while(_loc6_ < tArr.length)
         {
            _loc10_ = tArr[_loc6_].i;
            _loc3_ = _mc.createEmptyMovieClip("item" + _loc10_,_mc.getNextHighestDepth());
            _loc3_.attachBitmap(_root.badgesHolder.arrBmp[_loc10_],0);
            if(isReversed)
            {
               _loc12_ -= _loc3_._width - 4;
               _loc3_._x = _loc12_;
            }
            else
            {
               _loc3_._x = _loc12_;
               _loc12_ += _loc3_._width - 4;
            }
            _loc3_._y = (_loc9_ - _loc3_._height) / 2;
            if(Number(tArr[_loc6_].n) > 1)
            {
               _loc8_ = _loc3_.createTextField("count",2,0,23,24,20);
               _loc5_ = new TextFormat();
               _loc5_.font = "Arial";
               _loc5_.size = 10;
               _loc5_.color = 16777215;
               _loc5_.align = "right";
               _loc8_.embedFonts = true;
               _loc8_.autoSize = "right";
               _loc8_.setNewTextFormat(_loc5_);
               _loc8_.text = tArr[_loc6_].n;
            }
            classes.Help.addAltTag(_loc3_,classes.Lookup.badgeAltText(_loc10_));
            _loc6_ = _loc6_ + 1;
         }
         if(_mc._width > badgeAreaWidth)
         {
            _loc17_ = _mc._height;
            _loc19_ = Math.max(badgeAreaWidth / _mc._width,0.6);
            _mc._xscale *= _loc19_;
            _mc._yscale = _mc._xscale;
            _loc11_ = Math.ceil(badgeAreaWidth * 100 / _mc._xscale);
            _loc7_ = _loc11_;
            if(isReversed)
            {
               for(var _loc4_ in _mc)
               {
                  if(Math.abs(_mc[_loc4_]._x) > _loc11_)
                  {
                     _mc[_loc4_]._y = 23 + (_loc9_ - _loc3_._height) / 2;
                     _loc14_ = true;
                     _loc7_ = Math.min(Math.abs(_mc[_loc4_]._x) + _mc[_loc4_]._width,_loc7_);
                  }
               }
               if(_loc14_)
               {
                  for(_loc4_ in _mc)
                  {
                     if(_mc[_loc4_]._y > 0)
                     {
                        _mc[_loc4_]._y = 23 + (_loc9_ - _loc3_._height) / 2;
                        _mc[_loc4_]._x += _loc7_;
                        if(Math.abs(_mc[_loc4_]._x) > _loc11_)
                        {
                           _mc[_loc4_]._visible = false;
                        }
                     }
                  }
               }
            }
            else
            {
               for(_loc4_ in _mc)
               {
                  if(_mc[_loc4_]._x + _mc[_loc4_]._width > _loc11_)
                  {
                     _mc[_loc4_]._y = 23 + (_loc9_ - _loc3_._height) / 2;
                     _loc14_ = true;
                     _loc7_ = Math.min(_mc[_loc4_]._x,_loc7_);
                  }
               }
               if(_loc14_)
               {
                  for(_loc4_ in _mc)
                  {
                     if(_mc[_loc4_]._y > 0)
                     {
                        _mc[_loc4_]._y = 23 + (_loc9_ - _loc3_._height) / 2;
                        _mc[_loc4_]._x -= _loc7_;
                        if(_mc[_loc4_]._x + _mc[_loc4_]._width > _loc11_)
                        {
                           _mc[_loc4_]._visible = false;
                        }
                     }
                  }
               }
            }
            if(!_loc14_)
            {
               _mc._y += Math.round((_loc17_ - _mc._height) / 2);
            }
         }
      }
   }
}
