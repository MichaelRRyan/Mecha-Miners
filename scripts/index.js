// Makes the scroll smoother for next section buttons.
$('.section-button').click(function(event) {
    var scrollTo = $($(this).attr('href')).offset().top;
    $('html, body').animate({ scrollTop:scrollTo }, 600);
    event.preventDefault();
});