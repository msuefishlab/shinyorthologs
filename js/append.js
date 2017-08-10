$(function(){
        console.log('here2');
    $("body").on('click', '.listitem', function() {
        Shiny.onInputChange("search-ortholist",'blah');
    });
});
