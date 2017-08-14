$(function(){
    $("body").on('click', '.listitem', function(evt) {
        var val = $('#search-ortholist').val() + "\n" + evt.target.id;
        $('#search-ortholist').val(val)
        Shiny.onInputChange("search-ortholist", val);
    });
});
