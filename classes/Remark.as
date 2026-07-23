class classes.Remark extends MovieClip
{
   var aryRemarks;
   var bgMC;
   var bodyMC;
   var txtFormat;
   var uID;
   var userTxtFormat;
   var _remarkWidth = 307;
   var _padding = 15;
   function Remark()
   {
      super();
      this.aryRemarks = new Array();
      this.bgMC = this.createEmptyMovieClip("bgMC",this.getNextHighestDepth());
      this.bodyMC = this.createEmptyMovieClip("bodyMC",this.getNextHighestDepth());
      this.bodyMC._x = this._padding;
      this.bodyMC._y = this._padding;
      this.userTxtFormat = new TextFormat();
      this.userTxtFormat.color = 16777215;
      this.userTxtFormat.font = "Arial";
      this.userTxtFormat.size = 9;
      this.txtFormat = new TextFormat();
      this.txtFormat.color = 0;
      this.txtFormat.font = "Arial";
      this.txtFormat.size = 12;
   }
   function drawAllRemark(rXML, showCtl)
   {
      if(!showCtl)
      {
         this._remarkWidth = 280;
      }
      trace("drawAllRemark: " + rXML.toString());
      this.bodyMC.clear();
      for(var _loc6_ in this.bodyMC)
      {
         this.bodyMC[_loc6_].removeMovieClip();
      }
      this.aryRemarks.length = 0;
      var _loc4_ = rXML.firstChild.childNodes.length;
      this._parent._parent.remarksHomeTop.txtCount = "You have " + _loc4_ + " remark" + (_loc4_ != 1 ? "s" : "");
      var _loc2_ = 0;
      while(_loc2_ < _loc4_)
      {
         this.addRemark(rXML.firstChild.childNodes[_loc2_].attributes.rid,rXML.firstChild.childNodes[_loc2_].attributes.fid,rXML.firstChild.childNodes[_loc2_].attributes.fu,rXML.firstChild.childNodes[_loc2_].attributes.dc,rXML.firstChild.childNodes[_loc2_].attributes.nd,rXML.firstChild.childNodes[_loc2_].firstChild.nodeValue,showCtl);
         _loc2_ = _loc2_ + 1;
      }
      this._parent._parent.scrollerObj.refreshScroller();
   }
   function addRemark(rid, fid, fu, dc, nd, rmk, showCtl)
   {
      var _loc2_ = this.bodyMC.createEmptyMovieClip("remarkItem" + this.aryRemarks.length,this.bodyMC.getNextHighestDepth());
      var _loc3_;
      if(this.aryRemarks.length > 0)
      {
         _loc3_ = this.bodyMC._height;
         this.bodyMC.beginFill(9145227,100);
         this.bodyMC.moveTo(0,_loc3_ + this._padding);
         this.bodyMC.lineTo(this._remarkWidth - this._padding * 3,_loc3_ + this._padding);
         this.bodyMC.lineTo(this._remarkWidth - this._padding * 3,_loc3_ + this._padding + 1);
         this.bodyMC.lineTo(0,_loc3_ + this._padding + 1);
         this.bodyMC.lineTo(0,_loc3_ + this._padding);
         this.bodyMC.endFill();
         _loc2_._y = this.bodyMC._height + this._padding;
      }
      else
      {
         _loc2_._y = 0;
      }
      _loc2_.createEmptyMovieClip("avatar",_loc2_.getNextHighestDepth());
      var _loc4_ = new classes.ImageIO();
      classes.Drawing.portrait(_loc2_.avatar,fid,2,0,0,2);
      _loc2_.avatar._xscale = _loc2_.avatar._yscale = 55;
      _loc2_.avatar.uID = fid;
      _loc2_.avatar.onRelease = function()
      {
         classes.Control.focusViewer(this.uID);
      };
      _loc2_.createTextField("uname",_loc2_.getNextHighestDepth(),0,42,60,10);
      _loc2_.uname.text = fu;
      _loc2_.uname.autoSize = true;
      _loc2_.uname.antiAliasType = "advanced";
      _loc2_.uname.setTextFormat(this.userTxtFormat);
      _loc2_.createTextField("rmkTxt",_loc2_.getNextHighestDepth(),70,0,this._remarkWidth - this._padding * 3 - 70,10);
      _loc2_.rmkTxt.multiline = true;
      _loc2_.rmkTxt.wordWrap = true;
      _loc2_.rmkTxt.autoSize = true;
      _loc2_.rmkTxt.text = dc + "\n" + rmk;
      _loc2_.rmkTxt.setTextFormat(this.txtFormat);
      if(showCtl)
      {
         _loc2_.attachMovie("RemarkControl","remarkCtl",_loc2_.getNextHighestDepth());
         _loc2_.remarkCtl.rid = rid;
         _loc2_.remarkCtl._y = _loc2_._height;
         _loc2_.remarkCtl.nonDelete = nd;
      }
      this.aryRemarks.push(_loc2_);
      this.drawRoundedRectangle(this.bgMC);
   }
   function drawRoundedRectangle(mv)
   {
      mv.clear();
      classes.Drawing.rect(mv,this._remarkWidth,this.bodyMC._height + this._padding * 2,16777215,30,0,0,10);
      classes.Drawing.rect(mv,this._remarkWidth,10,16711680,0,0,this.bodyMC._height + this._padding * 2);
   }
}
