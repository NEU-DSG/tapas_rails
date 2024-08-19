/*
 * TAPAS Reader Javascript
 */

// Set up namespace.
var tapas = tapas || {};
tapas.reader = {};

// Create an anonymous function to hold functions to be namespaced.
( function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  let that = this;
  
  /**
      PRIVATE FUNCTIONS
   **/
  
  /*
    Conditionally set the visibility of the "scroll to top" button, depending on where on the page the 
    user is. This is a callback function for an IntersectionObserver.
   */
  let setScrollButtonVisibility = function (entries, observer) {
    entries.forEach( entry => {
      let scrollDiv = document.getElementById('jump-to-top').closest('div');
      /* If the target entry (the header) is inside the viewport, make sure the button only appears in 
        document order. Also, add the `.is-sticking` class to the entry element. */
      if ( entry.intersectionRatio < 1 ) {
        entry.target.classList.add('is-sticking');
        scrollDiv.classList.add('jump-sticky');
      /* Otherwise, use "sticky" position to show the button at the bottom of the screen, and remove the 
        `.is-sticking` class from the entry element. */
      } else {
        entry.target.classList.remove('is-sticking');
        scrollDiv.classList.remove('jump-sticky');
      }
    });
  };
  
  
  /**
      PUBLIC FUNCTIONS
   **/
  
  /*
    Set up an Intersection Observer which will add the `.jump-sticky` class to the "Return to top" 
    container when `.header` scrolls out of view. This solution owes a great deal to "How to Make an 
    Unobtrusive Scroll-to-Top Button" by Marcel Rojas 
    (https://css-tricks.com/how-to-make-an-unobtrusive-scroll-to-top-button/).
   */
  this.setUpScrollButton = function () {
    /* We're only interested in tracking when the `.reader-header` intersection ratio changes to or from 
      1.0 (fully visible). When it's below 1, the header's "sticky" position is kicking in. (We know 
      this because `.reader-header` is set to `top: -1px;`, meaning that when the header is behaving 
      "stickily", a single pixel is out of the viewport — and the ratio is less than 1.0.) */
    let ratioThresholds = [ 1 ],
        observer = new IntersectionObserver(setScrollButtonVisibility, { threshold: ratioThresholds }),
        readerHeader = document.querySelector('.reader-header');
    observer.observe(readerHeader);
  }
  
}).apply(tapas.reader); // Apply the namespace to the anonymous function.


/* Ensure that the callback function above is run, whether or not the DOM has 
  already been loaded. Solution by Julian Kühnel: 
  https://www.sitepoint.com/jquery-document-ready-plain-javascript/ */
if ( document.readyState === 'complete' 
   || ( document.readyState !== 'loading' && !document.documentElement.doScroll ) 
   ) {
  tapas.reader.setUpScrollButton();
} else {
  document.addEventListener('DOMContentLoaded', tapas.reader.setUpScrollButton);
}
