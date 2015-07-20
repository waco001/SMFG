/*
 * Url preview script 
 * powered by jQuery (http://www.jquery.com)
 * 
 * written by Alen Grakalic (http://cssglobe.com)
 * 
 * for more info visit http://cssglobe.com/post/1695/easiest-tooltip-and-image-preview-using-jquery
 *
 */
 
this.screenshotPreview = function(){    
    /* CONFIG */
        
        xOffset = 100;
        yOffset = 30;
        
        // these 2 variable determine popup's distance from the cursor
        // you might want to adjust to get the right result
        
    /* END CONFIG */
    $("a.screenshot").hover(function(e){
        this.t = this.title;
        this.title = "";    
        var c = (this.t != "") ? "<br/>" + this.t : "";
        $("body").append("<p id='screenshot'><img style='height:75%; width:75%;' src='"+ this.rel +"' alt='url preview' />"+ c +"</p>");                                
        $("#screenshot")
            .css("top",(e.pageY - xOffset) + "px")
            .css("left",(e.pageX + yOffset) + "px")
            .fadeIn("slow");                        
    },
    function(){
        this.title = this.t;    
        $("#screenshot").remove();
    }); 
            
};


// starting the script on page load
$(document).ready(function(){
    screenshotPreview();
});