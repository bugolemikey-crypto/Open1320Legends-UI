class classes.SelectionController
{
   static var holdObj;
   static var holdPos;
   static var arrWatch = new Array("tfInbox");
   function SelectionController()
   {
   }
   static function checkFocus()
   {
      var objPath = Selection.getFocus();
      var objName = objPath.substr(1 + objPath.lastIndexOf("."));
      trace("checkFocus objName: " + objName);
      var found;
      var i = 0;
      while(i < classes.SelectionController.arrWatch.length)
      {
         if(classes.SelectionController.arrWatch[i] == objName)
         {
            found = true;
            break;
         }
         i++;
      }
      if(found)
      {
         classes.SelectionController.holdObj = eval(objPath);
         classes.SelectionController.holdPos = Selection.getCaretIndex();
         trace("checkFocus set: " + objPath + ", " + classes.SelectionController.holdPos);
      }
      else
      {
         classes.SelectionController.holdObj = null;
         classes.SelectionController.holdPos = -1;
      }
   }
   static function restoreFocus()
   {
      trace("restoreFocus");
      if(classes.SelectionController.holdObj)
      {
         trace("restoreFocus obj: " + classes.SelectionController.holdObj);
         Selection.setFocus(classes.SelectionController.holdObj);
         if(classes.SelectionController.holdPos >= 0)
         {
            trace("restoreFocus pos: " + classes.SelectionController.holdPos);
            Selection.setSelection(classes.SelectionController.holdPos,classes.SelectionController.holdPos);
         }
         else
         {
            Selection.setSelection(0,0);
         }
      }
   }
}
