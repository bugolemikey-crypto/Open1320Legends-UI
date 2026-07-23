class classes.Effects
{
   var _xscale;
   var _yscale;
   var icn;
   var si;
   function Effects()
   {
   }
   static function clearRO(subject)
   {
      subject.onRollOut();
      delete subject.onRollOver;
      delete subject.onRollOut;
   }
   static function roBounce(subject)
   {
      function zoom(tScale)
      {
         var _loc3_;
         if(Math.abs(tScale - subject._xscale) > 0.1)
         {
            _loc3_ = 0.2 * (tScale - subject._xscale) - 0.3 * v;
            v += _loc3_;
            subject._xscale += v;
            subject._yscale = subject._xscale;
         }
         else
         {
            subject._xscale = tScale;
            subject._yscale = tScale;
            clearInterval(this.si);
         }
      }
      var v;
      subject.onRollOver = function()
      {
         var _loc2_ = 115;
         clearInterval(this.si);
         v = 20;
         this.si = setInterval(zoom,20,_loc2_);
         if(subject._parent.rptMisconductBubble && subject._name == "tog_reportMisconduct")
         {
            subject._parent.rptMisconductBubble._visible = true;
         }
      };
      subject.onRollOut = function()
      {
         var _loc2_ = 100;
         clearInterval(this.si);
         v = -20;
         this.si = setInterval(zoom,20,_loc2_);
         if(subject._parent.rptMisconductBubble && subject._name == "tog_reportMisconduct")
         {
            subject._parent.rptMisconductBubble._visible = false;
         }
      };
   }
   static function roBump(subject)
   {
      subject.zoomStep = function(tScale)
      {
         if(Math.abs(tScale - this._xscale) > 0.1)
         {
            this._xscale += (tScale - this._xscale) / 2;
            this._yscale = this._xscale;
            this.si = _global.setTimeout(this,"zoomStep",30,tScale);
         }
         else
         {
            this._xscale = tScale;
            this._yscale = tScale;
         }
      };
      subject.onRollOver = function()
      {
         var _loc3_ = 115;
         _global.clearTimeout(this.si);
         this.si = _global.setTimeout(this,"zoomStep",30,_loc3_);
      };
      subject.onRollOut = function()
      {
         var _loc3_ = 100;
         _global.clearTimeout(this.si);
         this.si = _global.setTimeout(this,"zoomStep",30,_loc3_);
      };
   }
   static function bump(subject, targetScale)
   {
      function zoom(tScale)
      {
         if(Math.abs(tScale - subject._xscale) > 0.1)
         {
            subject._xscale += (tScale - subject._xscale) / 2;
            subject._yscale = subject._xscale;
         }
         else
         {
            subject._xscale = tScale;
            subject._yscale = tScale;
            clearInterval(subject.si);
         }
      }
      clearInterval(subject.si);
      subject.si = setInterval(zoom,20,targetScale);
   }
   static function bounce(subject, targetScale)
   {
      function zoom(tScale)
      {
         var _loc2_;
         if(Math.abs(tScale - subject._xscale) > 0.1)
         {
            _loc2_ = 0.2 * (tScale - subject._xscale) - 0.3 * v;
            v += _loc2_;
            subject._xscale += v;
            subject._yscale = subject._xscale;
         }
         else
         {
            subject._xscale = tScale;
            subject._yscale = tScale;
            clearInterval(subject.si);
         }
      }
      clearInterval(subject.si);
      var v = 20;
      if(targetScale < subject._xscale)
      {
         v *= -1;
      }
      subject.si = setInterval(zoom,20,targetScale);
   }
   static function bounceY(subject, targetY, v)
   {
      function step(tY)
      {
         var _loc3_;
         if(Math.abs(tY - subject._y) > 0.1)
         {
            _loc3_ = 0.2 * (tY - subject._y) - 0.3 * v;
            v += _loc3_;
            subject._y += v;
            _global.setTimeout(step,20,targetY);
         }
         else
         {
            subject._y = tY;
         }
      }
      if(!v)
      {
         v = 20;
      }
      if(targetY < subject._y)
      {
         v *= -1;
      }
      _global.setTimeout(step,20,targetY);
   }
   static function getEasePoint(pCurrent, pTarget, maxStep, easeFactor)
   {
      maxStep = Math.abs(maxStep);
      if(!easeFactor)
      {
         easeFactor = 3;
      }
      var _loc1_ = (pTarget - pCurrent) / easeFactor;
      if(Math.abs(_loc1_) > maxStep)
      {
         _loc1_ = maxStep * _loc1_ / Math.abs(_loc1_);
      }
      return pCurrent + _loc1_;
   }
   static function icnStandardRO(subject)
   {
      subject.onRollOver = function()
      {
         this.icn._xscale = this.icn._yscale = 115;
      };
      subject.onRollOut = function()
      {
         this.icn._xscale = this.icn._yscale = 100;
      };
   }
}
