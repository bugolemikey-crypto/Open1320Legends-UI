class classes.pmButton extends MovieClip
{
   var flashSI;
   var glow;
   static var _mc;
   var counter = 0;
   function pmButton()
   {
      super();
      classes.pmButton._mc = this;
   }
   function clearFlash()
   {
      classes.Debug.writeLn("clearFlash");
      clearInterval(this.flashSI);
      this.glow._visible = false;
      classes.Frame._MC.overlay.tabNim.hilite._visible = false;
   }
   function indicateNewMessage()
   {
      this.counter = 0;
      clearInterval(this.flashSI);
      if(classes.Console.panelNum != 1)
      {
         this.flashSI = setInterval(this.doFlash,600,this);
      }
      if(classes.Frame._MC.overlay.tabNim._visible)
      {
         classes.Frame._MC.overlay.tabNim.hilite._visible = true;
      }
   }
   function doFlash(_context)
   {
      if(_context.counter < 34)
      {
         if(_context.counter % 2 == 1)
         {
            _context.glow._visible = true;
            classes.Frame._MC.overlay.tabNim.hilite._visible = true;
         }
         else
         {
            _context.glow._visible = false;
            classes.Frame._MC.overlay.tabNim.hilite._visible = false;
         }
         _context.counter = _context.counter + 1;
      }
      else
      {
         clearInterval(_context.flashSI);
      }
   }
}
