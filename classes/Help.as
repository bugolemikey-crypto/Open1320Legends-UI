class classes.Help
{
   var _parent;
   var _width;
   var _x;
   var _y;
   var removeMovieClip;
   function Help()
   {
   }
   static function addAltTag(pTarget, pMsg)
   {
      if(pMsg.length)
      {
         pTarget.onRollOver = function()
         {
            _root.altTag.removeMovieClip();
            var _loc3_ = {x:this._x + this._width / 2,y:this._y - 14};
            this._parent.localToGlobal(_loc3_);
            _root.attachMovie("altTag","altTag",_root.getNextHighestDepth(),{_x:_loc3_.x,_y:_loc3_.y,txt:pMsg,caller:this});
            _root.altTag.onRollOut = function()
            {
               this.removeMovieClip();
            };
         };
         pTarget.onRollOut = function()
         {
            _root.altTag.removeMovieClip();
         };
      }
   }
   static function addAltTag2(pTarget, pName, pDesc)
   {
      if(pName.length)
      {
         pTarget.onRollOver = function()
         {
            _root.altTag2.removeMovieClip();
            var _loc3_ = {x:this._x,y:this._y - 14};
            this._parent.localToGlobal(_loc3_);
            _root.attachMovie("altTag2","altTag2",_root.getNextHighestDepth(),{_x:_loc3_.x,_y:_loc3_.y,txt:pName,txtDesc:pDesc,caller:this});
            _root.altTag2.onRollOut = function()
            {
               this.removeMovieClip();
            };
         };
         pTarget.onRollOut = function()
         {
            _root.altTag2.removeMovieClip();
         };
      }
   }
}
