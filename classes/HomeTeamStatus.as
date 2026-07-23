class classes.HomeTeamStatus extends MovieClip
{
   var btnCreate;
   function HomeTeamStatus()
   {
      super();
      trace("class HomeTeamStatus");
      var _loc5_ = function(d)
      {
         _global.appXML = new XML(d);
         this.drawMyApplications(_global.appXML.firstChild);
      };
      classes.Lookup.addCallback("teamGetMyApps",this,_loc5_,"");
      _root.teamGetMyApps();
      this.btnCreate.onRelease = function()
      {
         _root.abc.closeMe();
         _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamCreateContent"});
      };
   }
   function drawMyApplications(txml)
   {
      var _loc6_ = 0;
      var _loc7_ = 50;
      var _loc8_ = new TextFormat();
      _loc8_.color = 16777215;
      _loc8_.font = "Arial";
      _loc8_.bold = true;
      _loc8_.size = 12;
      var _loc5_ = this.createTextField("appsTitle",this.getNextHighestDepth(),_loc7_,_loc6_,210,36);
      _loc5_.embedFonts = true;
      _loc5_.selectable = false;
      _loc5_.setNewTextFormat(_loc8_);
      _loc6_ += 30;
      if(txml.childNodes.length)
      {
         _loc5_.text = "Outgoing Applications";
      }
      else
      {
         _loc5_.text = "You have no outgoing applications";
         _loc5_ = this.createTextField("appsNone",this.getNextHighestDepth(),_loc7_,_loc6_,210,36);
         _loc5_.embedFonts = true;
         _loc5_.multiline = true;
         _loc5_.autoSize = true;
         _loc5_.wordWrap = true;
         _loc5_.selectable = false;
         _loc8_.size = 10;
         _loc5_.setNewTextFormat(_loc8_);
         _loc5_.text = "You can apply to teams by finding them in the Viewer and clicking the \'Join\' button.\r\rYou can apply to as many teams as you like at a time.  More than one team may offer you membership, but you can only join one of them.\r\rThe statuses of all your team applications will appear here.";
         _loc6_ += 100;
      }
      _loc8_.font = "ArialBmp9";
      _loc8_.bold = false;
      _loc8_.size = 9;
      var _loc4_;
      var _loc3_ = 0;
      while(_loc3_ < txml.childNodes.length)
      {
         _loc4_ = txml.childNodes[_loc3_].attributes;
         this.attachMovie("teamInfo50","application" + _loc3_,this.getNextHighestDepth(),{_x:_loc7_,_y:_loc6_,scale:50,tID:_loc4_.ti,tName:_loc4_.tn,tCred:_loc4_.sc,teamXML:_global.txml});
         this.attachMovie("applicationOptions","options" + _loc3_,this.getNextHighestDepth(),{tID:_loc4_.ti,_x:_loc7_,_y:_loc6_ + 42});
         if(_loc4_.s == "Accepted")
         {
            this["options" + _loc3_].gotoAndPlay("accepted");
         }
         else if(_loc4_.s == "Declined")
         {
            this["options" + _loc3_].gotoAndPlay("declined");
         }
         this.createTextField("comment" + _loc3_,this.getNextHighestDepth(),_loc7_ + 219,_loc6_ + 4,160,70);
         _loc5_ = this["comment" + _loc3_];
         _loc5_.embedFonts = true;
         _loc5_.multiline = true;
         _loc5_.selectable = false;
         _loc5_.wordWrap = true;
         _loc5_.setNewTextFormat(_loc8_);
         _loc5_.text = !_loc4_.n.length ? "" : _loc4_.n;
         _loc6_ += 83;
         _loc3_ = _loc3_ + 1;
      }
      this._parent._parent.scrollerObj.refreshScroller();
   }
}
