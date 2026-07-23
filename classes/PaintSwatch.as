class classes.PaintSwatch extends MovieClip
{
   var clr;
   var hexColor;
   var swatchColorMC;
   function PaintSwatch()
   {
      super();
      this.clr = new Color(this.swatchColorMC);
   }
   function set HexColor(v)
   {
      this.hexColor = v;
      this.clr.setRGB(Number("0x" + v));
   }
   function get HexColor()
   {
      return this.hexColor;
   }
}
