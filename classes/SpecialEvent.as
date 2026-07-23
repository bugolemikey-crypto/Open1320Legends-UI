class classes.SpecialEvent
{
   var currentEvent;
   var description;
   var endDate;
   var id;
   var startDate;
   var teamID;
   var teams;
   var title;
   static var DECLINED = 0;
   static var UNDECIDED = -1;
   function SpecialEvent(eventXML)
   {
      var _loc2_;
      if(!eventXML)
      {
         this.currentEvent = false;
      }
      else
      {
         this.currentEvent = true;
         this.teamID = -1;
         this.id = Number(eventXML.attributes.eid);
         this.title = String(eventXML.attributes.t);
         this.description = String(eventXML.attributes.d);
         this.startDate = Date(eventXML.attributes.s);
         this.endDate = Date(eventXML.attributes.e);
         this.teams = new Array();
         _loc2_ = 0;
         while(_loc2_ < eventXML.childNodes.length)
         {
            if(eventXML.childNodes[_loc2_].attributes.id == "specialEventTeam")
            {
               this.teams[_loc2_] = new classes.SpecialEventTeam();
               this.teams[_loc2_].id = Number(eventXML.childNodes[_loc2_].attributes.tid);
               this.teams[_loc2_].subTeamID = Number(eventXML.childNodes[_loc2_].attributes.stid);
               this.teams[_loc2_].name = String(eventXML.childNodes[_loc2_].attributes.id);
               this.teams[_loc2_].description = String(eventXML.childNodes[_loc2_].attributes.d);
            }
            else
            {
               this.teamID = eventXML.childNodes[_loc2_].attributes.tid;
            }
            _loc2_ = _loc2_ + 1;
         }
         trace("teamID");
         trace(this.teamID);
      }
   }
   function loadTeamIcon(teamID, target, height, width)
   {
      trace("loadTeamIcon");
      trace(_root.introHolder);
      target.attachBitmap(_root.introHolder.arrLogo[teamID],0);
      target._height = height;
      target._width = width;
   }
   function loadLogo(target)
   {
      target.attachBitmap(_root.introHolder.logo,0);
   }
}
