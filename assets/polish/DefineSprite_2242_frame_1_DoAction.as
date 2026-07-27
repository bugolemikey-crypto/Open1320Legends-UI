btnActivatePoints.onRelease = function()
{
   if(pointsCode.length > 0)
   {
      trace("pointsCode: " + pointsCode);
      _root.activatePoints(pointsCode);
   }
};
btnWhatsPoints.onRelease = function()
{
   _root.displayAlert("helmet","Activating Purchase","Activate your Points or Membership order by typing your activation code here.  Points allow you to purchase new and exclusive items in the game, while membership offers many benefits such as discounted parts, exclusive items, and more!");
};
function skinPurchaseActivation()
{
   if(modernPurchaseSkin == undefined)
   {
      createEmptyMovieClip("modernPurchaseSkin",0);
   }
   modernPurchaseSkin.clear();
   with(modernPurchaseSkin)
   {
      beginFill(0,72);
      lineTo(240,0);
      lineTo(240,72);
      lineTo(0,72);
      lineTo(0,0);
      endFill();
      lineStyle(1,3791848,65);
      moveTo(0,0);
      lineTo(240,0);
      lineStyle(2,16726051,95);
      moveTo(0,70);
      lineTo(240,70);
   }
   modernPurchaseSkin.filters = [new flash.filters.GlowFilter(3791848,0.25,10,10,1,2,false,false)];
   skinPurchaseText(txtPoints,16777215);
   skinPurchaseText(pointsCode,16777215);
   // Give the code entry actual field chrome. It was styled identically to the
   // label beside it - white bold text on the panel - so there was nothing to say
   // it could be typed into, and blanking the panel art behind it left it with no
   // backdrop at all. A dark well plus the red accent border reads as an input.
   // TextField.background/border rather than a drawn box: the field owns its own
   // bounds, so the chrome tracks it without hardcoding a rectangle that would
   // drift if the field ever moves.
   pointsCode.background = true;
   pointsCode.backgroundColor = 1315352;
   pointsCode.border = true;
   pointsCode.borderColor = 14826036;
   var c1 = new Color(btnActivatePoints);
   c1.setTransform({ra:72,ga:72,ba:72,aa:100,rb:0,gb:8,bb:10,ab:0});
   var c2 = new Color(btnWhatsPoints);
   c2.setTransform({ra:72,ga:72,ba:72,aa:100,rb:0,gb:8,bb:10,ab:0});
}
function skinPurchaseText(field, col)
{
   if(field == undefined)
   {
      return undefined;
   }
   var tf = field.getTextFormat();
   tf.color = col;
   tf.bold = true;
   field.setTextFormat(tf);
   field.setNewTextFormat(tf);
   field.filters = [new flash.filters.GlowFilter(0,0.75,4,4,1,2,false,false)];
}
skinPurchaseActivation();
