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
    Conditionally set the visibility of the "scroll to top" button, depending on where on the page the user is. This is a callback function for an IntersectionObserver.
   */
  let setScrollButtonVisibility = function (entries, observer) {
    entries.forEach( entry => {
      let scrollDiv = document.getElementById('jump-to-top').closest('div');
      console.log(scrollDiv);
      /* If the target entry (the header) is inside the viewport, make sure the button only appears in document order. */
      if ( entry.isIntersecting ) {
        scrollDiv.classList.remove('jump-sticky');
      /* If the target entry is NOT in view, use "fixed" position to show the button at the bottom of the screen. */
      } else {
        scrollDiv.classList.add('jump-sticky');
      }
    });
  };
  
  
  /**
      PUBLIC FUNCTIONS
   **/
  
  this.setUpScrollButton = function () {
    let observer = new IntersectionObserver(setScrollButtonVisibility),
        pgHeader = document.getElementById('header');
    observer.observe(pgHeader);
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
