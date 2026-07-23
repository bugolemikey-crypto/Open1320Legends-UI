class classes.SCDial
{
   function SCDial()
   {
   }
   static function setSCDial(target, uCred)
   {
      uCred = Number(uCred);
      if(uCred || uCred === 0)
      {
         target.ticks.txt = String(uCred);
      }
      else
      {
         target.ticks.txt = "";
      }
      var _loc4_ = _global.scLevelsXML.firstChild;
      var _loc2_ = 0;
      var _loc8_;
      var _loc6_;
      var _loc3_;
      while(_loc2_ < _loc4_.childNodes.length)
      {
         if(uCred < Number(_loc4_.childNodes[_loc2_].attributes.sc))
         {
            _loc8_ = new flash.filters.GlowFilter(Number("0x" + _loc4_.childNodes[_loc2_].attributes.c),75,3,3,3,3);
            _loc6_ = new Array();
            _loc6_.push(_loc8_);
            target.ticks.filters = _loc6_;
            target.txtLevel = _loc4_.childNodes[_loc2_].attributes.id;
            if(_loc2_ != 0)
            {
               if(_loc2_ != _loc4_.childNodes.length - 1)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc4_.childNodes[_loc2_].childNodes.length)
                  {
                     if(uCred < Number(_loc4_.childNodes[_loc2_].childNodes[_loc3_].attributes.sc))
                     {
                        target.ticks.gotoAndStop(_loc3_ + 2);
                        break;
                     }
                     _loc3_ = _loc3_ + 1;
                  }
               }
            }
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
}
