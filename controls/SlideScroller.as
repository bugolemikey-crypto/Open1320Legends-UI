class controls.SlideScroller
{
   var _currentItem;
   var _currentPageID;
   var _mainClip;
   var _numItems;
   var _pageClips;
   var _scrollClip;
   var _scrollLeft;
   var _scrollMask;
   var _scrollPageLeft;
   var _scrollPageRight;
   var _scrollRight;
   static var _itemSelectedCallback;
   function SlideScroller()
   {
   }
   function init(mainClip, currentItem, numItems, scrollLeft, scrollRight, scrollPageLeft, scrollPageRight, maskX, maskY, maskWidth, maskHeight, itemSelectedCallback)
   {
      trace("SlideScroller::init");
      this._mainClip = mainClip;
      this._numItems = numItems;
      this._scrollLeft = scrollLeft;
      this._scrollRight = scrollRight;
      this._scrollPageLeft = scrollPageLeft;
      this._scrollPageRight = scrollPageRight;
      this._pageClips = new Array();
      controls.SlideScroller._itemSelectedCallback = itemSelectedCallback;
      this._currentItem = currentItem;
      this._scrollClip = mainClip.createEmptyMovieClip("scrollClip",mainClip.getNextHighestDepth());
      this._scrollClip._x = maskX;
      this._scrollClip._y = maskY;
      this._scrollMask = mainClip.createEmptyMovieClip("scrollMask",mainClip.getNextHighestDepth());
      classes.Drawing.rect(this._scrollMask,maskWidth,maskHeight);
      if(maskX)
      {
         this._scrollMask._x = maskX;
      }
      if(maskY)
      {
         this._scrollMask._y = maskY;
      }
      this._scrollClip.setMask(this._scrollMask);
      this._scrollLeft.onRelease = mx.utils.Delegate.create(this,this.scrollLeftPushed);
      this._scrollRight.onRelease = mx.utils.Delegate.create(this,this.scrollRightPushed);
      this._scrollPageLeft.onRelease = mx.utils.Delegate.create(this,this.scrollPageLeftPushed);
      this._scrollPageRight.onRelease = mx.utils.Delegate.create(this,this.scrollPageRightPushed);
      this.createPages();
   }
   function createPages()
   {
      trace("yeah...");
      var _loc6_ = new TextFormat();
      _loc6_.font = "Arial";
      _loc6_.size = 10.7;
      _loc6_.bold = true;
      _loc6_.color = 16777215;
      var _loc3_ = 0;
      this._pageClips[_loc3_] = this._scrollClip.createEmptyMovieClip("pageClip0",this._scrollClip.getNextHighestDepth());
      classes.Drawing.standardText(this._pageClips[_loc3_],"fld","",0,0,100,"left",_loc6_);
      this._pageClips[_loc3_].fld.html = true;
      this._pageClips[_loc3_].fld.styleSheet = _global.newsCSS;
      var _loc5_;
      if(this._currentItem == 1)
      {
         this._scrollLeft.enabled = false;
      }
      else
      {
         this._scrollLeft.enabled = true;
      }
      if(this._currentItem == this._numItems)
      {
         this._scrollRight.enabled = false;
      }
      else
      {
         this._scrollRight.enabled = true;
      }
      var _loc4_ = 1;
      while(_loc4_ <= this._numItems)
      {
         if(_loc4_ == this._currentItem)
         {
            this._currentPageID = _loc3_;
            _loc5_ = String(_loc4_ + " ");
         }
         else
         {
            _loc5_ = String("<a href=\"asfunction:controls.SlideScroller.scrollItemPushed," + _loc4_ + "\"><u>" + _loc4_ + "</u></a> ");
         }
         this._pageClips[_loc3_].fld.htmlText += _loc5_;
         if(this._pageClips[_loc3_]._width > this._scrollMask._width)
         {
            trace("next page");
            this._pageClips[_loc3_].fld.htmlText = this._pageClips[_loc3_].fld.htmlText.substr(0,this._pageClips[_loc3_].fld.htmlText.length - _loc5_.length);
            _loc3_ = _loc3_ + 1;
            if(_loc4_ == this._currentItem)
            {
               this._currentPageID = _loc3_;
            }
            this._pageClips[_loc3_] = this._scrollClip.createEmptyMovieClip("pageClip" + _loc3_,this._scrollClip.getNextHighestDepth());
            classes.Drawing.standardText(this._pageClips[_loc3_],"fld","",0,0,100,"left",_loc6_);
            this._pageClips[_loc3_].fld.html = true;
            this._pageClips[_loc3_].fld.htmlText += _loc5_;
            this._pageClips[_loc3_].fld.styleSheet = _global.newsCSS;
         }
         _loc4_ = _loc4_ + 1;
      }
      this.setPage(this._currentPageID);
   }
   function setPage(newPageID)
   {
      if(newPageID == 0)
      {
         this._scrollPageLeft.enabled = false;
      }
      else
      {
         this._scrollPageLeft.enabled = true;
      }
      if(newPageID == this._pageClips.length - 1)
      {
         this._scrollPageRight.enabled = false;
      }
      else
      {
         this._scrollPageRight.enabled = true;
      }
      if(this._currentPageID == newPageID)
      {
         this.showThisPage(newPageID);
      }
      else
      {
         this.transitionToNewPage(newPageID);
      }
   }
   function showThisPage(pageID)
   {
      trace("showThisPage: " + pageID);
      var _loc2_ = 0;
      while(_loc2_ < this._pageClips.length)
      {
         this._pageClips[_loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      this._pageClips[pageID]._visible = true;
   }
   function transitionToNewPage(newPageID)
   {
      this.showThisPage(newPageID);
   }
   function scrollLeftPushed()
   {
      trace("in scrollLeftPushed");
      controls.SlideScroller.scrollItemPushed(--this._currentItem);
   }
   function scrollRightPushed()
   {
      trace("in scrollRightPushed");
      controls.SlideScroller.scrollItemPushed(++this._currentItem);
   }
   function scrollPageLeftPushed()
   {
      trace("in scrollPageLeftPushed");
      this.setPage(--this._currentPageID);
   }
   function scrollPageRightPushed()
   {
      trace("in scrollPageRightPushed");
      this.setPage(++this._currentPageID);
   }
   static function scrollItemPushed(itemPushed)
   {
      trace("in scrollItemPushed");
      controls.SlideScroller._itemSelectedCallback(itemPushed);
   }
}
