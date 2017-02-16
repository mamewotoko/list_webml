
$(function(){
    var audio = $("#audio");
    function prepare_item(item){
	//$(".episode").removeClass("active")
        //item.addClass("active");
        $(".podcast_row").removeClass("active")
        item.parent().parent().addClass("active");
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
    //TODO: handle space key: pause & play active item
    //TODO: up/down key to select item
    
    $(".episode").click(function(){
	console.log("class: " + $(this).hasClass("active"));
	if($(this).hasClass("active")){
	    if(audio[0].paused){
		audio[0].play();
	    }
	    else {
		audio[0].pause();
	    }
	}
	else {
	    play_item($(this));
	}
    });
    prepare_item($(".episode").first());
    $('#podcast_list').DataTable({'paging': false});
});
