class classes.util.Tutorial
{
   static var _mc;
   static var _mcOverlay;
   static var arr;
   static var current;
   static var len;
   function Tutorial(_context, arrContent, useBGOverlay, overlayWidth, overlayHeight)
   {
      if(useBGOverlay && _context.tutorialBGOverlay == undefined)
      {
         if(!overlayWidth)
         {
            overlayWidth = 800;
         }
         if(!overlayHeight)
         {
            overlayHeight = 600;
         }
         classes.util.Tutorial._mcOverlay = _context.tutorialBGOverlay = _context.createEmptyMovieClip("tutorialBGOverlay",_context.getNextHighestDepth());
         with(_context.tutorialBGOverlay)
         {
            beginFill(0,40);
            lineTo(overlayWidth,0);
            lineTo(overlayWidth,overlayHeight);
            lineTo(0,overlayHeight);
            lineTo(0,0);
            endFill();
         }
         _context.tutorialBGOverlay.onRelease = function()
         {
         };
         _context.tutorialBGOverlay.useHandCursor = false;
      }
      if(_context.bubbleContent == undefined)
      {
         classes.util.Tutorial._mc = _context.attachMovie("bubble","bubbleContent",_context.getNextHighestDepth());
      }
      else
      {
         classes.util.Tutorial._mc = _context.bubbleContent;
      }
      classes.util.Tutorial.arr = arrContent;
      classes.util.Tutorial.len = classes.util.Tutorial.arr.length;
      classes.util.Tutorial.current = undefined;
      classes.util.Tutorial.goNext();
   }
   static function goNext()
   {
      if(classes.util.Tutorial.current == undefined)
      {
         classes.util.Tutorial.current = 0;
      }
      else
      {
         classes.util.Tutorial.current++;
      }
      classes.util.Tutorial._mc.createBubble(classes.util.Tutorial.arr[classes.util.Tutorial.current][0],classes.util.Tutorial.arr[classes.util.Tutorial.current][1],classes.util.Tutorial.arr[classes.util.Tutorial.current][2],classes.util.Tutorial.arr[classes.util.Tutorial.current][3],classes.util.Tutorial.arr[classes.util.Tutorial.current][4],classes.util.Tutorial.arr[classes.util.Tutorial.current][5],classes.util.Tutorial.arr[classes.util.Tutorial.current][6]);
      if(classes.util.Tutorial.current < classes.util.Tutorial.len - 1)
      {
         classes.util.Tutorial._mc.addNextButton();
         classes.util.Tutorial._mc.btnNext.onRelease = function()
         {
            classes.util.Tutorial.goNext();
         };
      }
   }
   function destroy()
   {
      if(classes.util.Tutorial._mc)
      {
         classes.util.Tutorial._mc.removeMovieClip();
         classes.util.Tutorial._mc = undefined;
      }
      if(classes.util.Tutorial._mcOverlay)
      {
         classes.util.Tutorial._mcOverlay.removeMovieClip();
         classes.util.Tutorial._mcOverlay = undefined;
      }
   }
}
