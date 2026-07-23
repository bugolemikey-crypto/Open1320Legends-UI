class classes.SectionClassified extends MovieClip
{
   var detail;
   var gotoGroup;
   var listingGroup;
   var myListingsGroup;
   var myTradesGroup;
   static var _mc;
   static var classifiedStatus;
   function SectionClassified()
   {
      super();
      classes.SectionClassified._mc = this;
   }
   function closeDetail()
   {
      this.gotoGroup._visible = true;
      this.detail.removeMovieClip();
      this.listingGroup.setAllSelect();
      this.myListingsGroup.setAllSelect();
      this.myTradesGroup.setAllSelect();
   }
   function goDetail(id, incomingTradeNodeData, outgoingTradeNodeData)
   {
      trace("goDetail: " + id);
      this.gotoGroup._visible = false;
      this.detail.removeMovieClip();
      this.detail = this.attachMovie("ucListingDetail","detail",this.getNextHighestDepth(),{_x:543,_y:172,id:id,incomingTradeNodeData:incomingTradeNodeData,outgoingTradeNodeData:outgoingTradeNodeData});
   }
   function goMyListingsDetail(id, s, incomingTradeNodeData, outgoingTradeNodeData)
   {
      trace("goMyListingsDetail: " + id + ", " + s);
      this.detail.removeMovieClip();
      this.detail = this.attachMovie("ucMyListingsDetail","detail",this.getNextHighestDepth(),{_x:543,_y:172,id:id,s:s,incomingTradeNodeData:incomingTradeNodeData,outgoingTradeNodeData:outgoingTradeNodeData});
   }
   function goTradesDetail(tNode)
   {
      trace("goTradesDetail: " + tNode);
      this.detail.removeMovieClip();
      var _loc4_;
      var _loc2_;
      if(tNode.attributes.s == 1)
      {
         this.detail = this.attachMovie("ucMyTradesSentDetail","detail",this.getNextHighestDepth(),{_x:543,_y:172,nodeData:tNode});
      }
      else
      {
         _loc4_ = "Trade Offer Detail";
         _loc2_ = classes.mc.UCMyTradesSent.tradeStatusName(Number(tNode.attributes.s));
         switch(_loc2_)
         {
            case "Traded":
               _loc2_ = "This trade offer has expired.\r\rThe other car is no longer available because it has been traded.";
               break;
            case "Sold":
               _loc2_ = "This trade offer has expired.\r\rThe other car is no longer available because it has been sold.";
               break;
            default:
               _loc2_ = "This trade offer is no longer active.\r\rStatus: " + _loc2_;
         }
         this.detail = this.attachMovie("ucGenericDetail","detail",this.getNextHighestDepth(),{_x:543,_y:172,title:_loc4_,msg:_loc2_});
      }
   }
   function goIncomingTrades(cid)
   {
      trace("goIncomingTrades: " + cid);
      this.detail.removeMovieClip();
      this.detail = this.attachMovie("ucIncomingTrades","detail",this.getNextHighestDepth(),{_x:543,_y:172,cid:cid});
   }
   function goIncomingTradesDetail(tNode)
   {
      trace("goIncomingTradesDetail: " + tNode);
      this.detail.removeMovieClip();
      this.detail = this.attachMovie("ucIncomingTradesDetail","detail",this.getNextHighestDepth(),{_x:543,_y:172,nodeData:tNode});
   }
   function goSearchPage(pid)
   {
      trace("goSearchPage: " + pid);
      classes.SectionClassified._mc.searchPage = Number(pid);
      classes.SectionClassified._mc.gotoAndPlay("browse");
   }
}
