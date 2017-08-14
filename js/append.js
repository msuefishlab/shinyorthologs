$(function(){
    $("body").on('click', '.listitem', function(evt) {
        var t = $('#search-ortholist').val();
        t +=  (t == "") ? "" : "\n";
        t += evt.target.id;
        $('#search-ortholist').val(t)
        Shiny.onInputChange("search-ortholist", t);
    });
});
