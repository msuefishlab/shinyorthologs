$(function(){
    $("body").on('click', '.listitem', function(evt) {
        var val = $('#search-ortholist').val() + "\n" + evt.target.innerHTML;
        $('#search-ortholist').val(val)
        Shiny.onInputChange("search-ortholist", val);
    });
});
