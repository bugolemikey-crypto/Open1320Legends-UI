class classes.mc.ScrollingPaneGroup extends MovieClip
{
   var contentMC;
   var scrollerObj;
   function ScrollingPaneGroup()
   {
      super();
      this.contentMC = this.createEmptyMovieClip("contentMC",1);
      this.scrollerObj = new controls.ScrollPane(this.contentMC,300,200,null,null,300);
   }
}
