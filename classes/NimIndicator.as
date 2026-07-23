class classes.NimIndicator extends MovieClip
{
   var flashSI;
   var yellow;
   var counter = 0;
   function NimIndicator()
   {
      super();
   }
   function clearStatus()
   {
      clearInterval(this.flashSI);
      for(var _loc2_ in this)
      {
         if(_loc2_ != "pointer")
         {
            this[_loc2_]._visible = false;
         }
      }
   }
   function indicateNewMessage()
   {
      this.yellow._visible = true;
      this.counter = 0;
      this.flashSI = setInterval(this.doFlash,600,this);
   }
   function doFlash(_context)
   {
      if(_context.counter < 34)
      {
         if(_context.counter % 2 == 1)
         {
            _context.yellow._visible = true;
            _context.light._visible = false;
         }
         else
         {
            _context.yellow._visible = false;
            _context.light._visible = true;
         }
         _context.counter = _context.counter + 1;
      }
      else
      {
         clearInterval(_context.flashSI);
      }
   }
}
