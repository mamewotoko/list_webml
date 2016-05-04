
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
	var bros = item.next();
	audio.on("ended", function(){
	    play_item(bros)
	});
	// TODO: last item?
	audio[0].play();
    }
   
    $(".episode").click(function(){
	play_item($(this));
    });
    prepare_item($(".episode").first());
});
