
$(function(){
    var audio = $("#audio");
    function prepare_item(item){
	$(".episode").removeClass("active")
	item.addClass("active");
	var episode_src = item.attr("data-source");
	audio.attr("src", episode_src);
    }
    
    function play_item(item){
	prepare_item(item)
	var siblings = item.siblings();
	if (siblings.length > 0){
	    audio.bind("ended", function(){
		play_item(siblings[0])
	    });
	}
	audio[0].play();
    }
   
    $(".episode").click(function(){
	play_item($(this));
    });
    prepare_item($(".episode").first());
});
