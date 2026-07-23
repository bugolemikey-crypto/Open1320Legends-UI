class classes.ClipFuncs
{
   function ClipFuncs()
   {
   }
   static function removeAllClips(_context)
   {
      for(var _loc2_ in _context)
      {
         if(typeof _context[_loc2_] == "movieclip")
         {
            _context[_loc2_].removeMovieClip();
            delete _context[_loc2_];
         }
      }
   }
   static function newClip(_context, clipName, px, py, pScale, depth)
   {
      if(!_context || !clipName)
      {
         return null;
      }
      if(!depth && depth !== 0)
      {
         depth = _context.getNextHighestDepth();
      }
      if(!depth)
      {
         depth = _context.getNextHighestDepth();
      }
      _context.createEmptyMovieClip(clipName,depth);
      if(px)
      {
         _context[clipName]._x = px;
      }
      if(py)
      {
         _context[clipName]._y = py;
      }
      if(pScale)
      {
         _context[clipName]._xscale = pScale;
         _context[clipName]._yscale = pScale;
      }
   }
}
