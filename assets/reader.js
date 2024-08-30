/*
 * TAPAS Reader Javascript
 */

// Set up namespace.
var tapas = tapas || {};
tapas.reader = {};

// Create an anonymous function to hold functions to be namespaced.
( function() {
  /* Capture the current context so these functions can refer to themselves even when the context 
    changes. */
  var that = this;
  
  /* An object for storing information about which classes of elements are currently visible (or not). */
  var visibilityByMainClass = { };
  
  
  /**
      PRIVATE FUNCTIONS
   **/
  
  /*
    Conditionally set the visibility of the "scroll to top" button, depending on where on the page the 
    user is. This is a callback function for an IntersectionObserver.
   */
  let setScrollButtonVisibility = function (entries, observer) {
    let allVisible,
        isFirstInit = Object.keys(visibilityByMainClass).length === 0,
        readerHeader = null,
        readerHeaderMayBeSticking = false,
        scrollDiv = document.getElementById('jump-to-top').closest('div');
    /* Each entry marks a change in an observed element. Here, each entry indicates that its 
      corresponding element has become hidden, partially visible, or fully visible. We want to track 
      which elements are currently visible in the visibilityByMainClass object defined above. */
    entries.forEach(entry => {
      let mainClass = entry.target.classList[0];
      visibilityByMainClass[mainClass] = entry.isIntersecting;
      /* If the main class of this entry's target is "reader-header", we also want to check if this 
        element might be sticking to the top of the page. If so, its intersection ratio will be below 1, 
        because `.reader-header` is set to `top: -1px`. */
      if ( mainClass === 'reader-header' ) {
        readerHeader = entry.target;
        readerHeaderMayBeSticking = entry.intersectionRatio < 1;
      }
    });
    /* Check if all observed elements are currently visible. */
    allVisible = Object.values(visibilityByMainClass).every(classEl => classEl);
    /* If `readerHeaderMayBeSticking` is true, then it was set because 
      (1) an entry indicates an intersection change for the reader header, 
      (2) the reader header's intersection ratio says that part of the header is out of sight, meaning 
      (3) the reader header might be acting in a "sticky" fashion. 
      If it's ALSO true that some other observed upper-page structure is not visible, we can assume that 
      the reader header is not just too big to fit in the window; it's likely sticking to the top of the 
      screen. In that case, it would be useful for the reader to see the "Return to top" button on the 
      page, and for us to hide any document description. Note that if this is the first state in which 
      the page is loaded, nothing should be done, in order to prevent the description from loading and 
      quickly disappearing. */
    if ( readerHeaderMayBeSticking && !allVisible ) {
      scrollDiv.classList.add('jump-sticky');
      /* When the reader header is sticking and this is not the initial observation, toggle the reader 
        description closed (if it exists). It is not reopened automatically. */
      if ( !isFirstInit && document.querySelector('.reader-desc') !== null ) {
        document.querySelector('.reader-desc').toggleAttribute('open', false);
      }
    /* By default, remove the class that makes the "Return to top" button sticky. */
    } else {
      scrollDiv.classList.remove('jump-sticky');
    }
  };
  
  
  /**
      PUBLIC FUNCTIONS
   **/
  
  /*
    Set up an Intersection Observer which will add the `.jump-sticky` class to the "Return to top" 
    container when `.reader-header` scrolls out of view. This solution owes a great deal to "How to Make 
    an Unobtrusive Scroll-to-Top Button" by Marcel Rojas 
    (https://css-tricks.com/how-to-make-an-unobtrusive-scroll-to-top-button/) and "How to Detect When a 
    Sticky Element Gets Pinned" by Chris Coyier 
    (https://css-tricks.com/how-to-detect-when-a-sticky-element-gets-pinned/).
   */
  this.setUpScrollButton = function () {
    /* We're only interested in tracking when the intersection ratio changes to or from 0 (fully hidden) 
      and 1.0 (fully visible). */
    let headerObserver = new IntersectionObserver(setScrollButtonVisibility, { threshold: [0, 1] });
    /* When `.reader-header` is below 1, the header's "sticky" position might be kicking in. We can 
      guess at this because `.reader-header` is set to `top: -1px;`, meaning that when the header is 
      sticking to the top of the viewport, a single pixel is out of sight — and the header's 
      intersection ratio is less than 1.0. */
    headerObserver.observe(document.querySelector('.reader-header'));
    /* We also need to watch the `.breadcrumbs` component just above the reader header. If the document 
      title and/or description are especially long, and the screen is especially small, `.reader-header`
      may be too tall to fit entirely in the viewport. In such a case, the header's intersection ratio 
      would _also_ be over 0 but less than 1. To ensure that the "Return to top" button only shows up 
      when it's possible to scroll up to the top, we have the headerObserver keep track of the 
      visibility of `.breadcrumbs` as well. */
    headerObserver.observe(document.querySelector('.breadcrumbs'));
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
