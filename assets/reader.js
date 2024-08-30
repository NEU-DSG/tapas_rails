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
    let readerHeader = null,
        scrollDiv = document.getElementById('jump-to-top').closest('div');
    entries.forEach(entry => {
      let mainClass = entry.target.classList[0];
      visibilityByMainClass[mainClass] = entry.isIntersecting;
      if ( mainClass === 'reader-header' && entry.intersectionRatio < 1 ) {
        readerHeader = entry.target;
      }
    });
    //console.log(visibilityByMainClass);
    /* If every element referenced in `visibilityByMainClass` is indeed visible, the header is visible 
      and there's no need to show the "Return to top" button. */
    if ( Object.values(visibilityByMainClass).every(classEl => { return classEl; }) ) {
      scrollDiv.classList.remove('jump-sticky');
    /* If `readerHeader` isn't null, then it was set because 
      (1) an entry indicates an intersection change for the reader header, 
      (2) the reader header's intersection ratio says that part of the header is out of sight, meaning 
      (3) the reader header might be acting in a "sticky" fashion. 
      If we're at this conditional, we also know that any other observed upper-page structure is not 
      visible. Therefore, we can assume that it would be useful for the reader to see the "Return to 
      top" button on the page. */
    } else if ( readerHeader !== null ) {
      //entry.target.classList.add('is-sticking');
      scrollDiv.classList.add('jump-sticky');
    /* By default, don't make the "Return to top" button sticky. */
    } else {
      scrollDiv.classList.remove('jump-sticky');
    }
    // Test any outer structure entries for visibility
    // For the `.reader-header` specifically, add "is-sticking" if the intersection ratio is < 1 and the outer structures are 0
    // entries.forEach( entry => {
    //   let scrollDiv = document.getElementById('jump-to-top').closest('div');
    //   /* If the target entry (the reader header) isn't fully inside the viewport, make sure the button 
    //     only appears in document order. Also, add the `.is-sticking` class to the entry element. */
    //   if ( entry.intersectionRatio < 1 ) {
    //     entry.target.classList.add('is-sticking');
    //     scrollDiv.classList.add('jump-sticky');
    //   /* Otherwise, use "sticky" position to show the button at the bottom of the screen, and remove the 
    //     `.is-sticking` class from the entry element. */
    //   } else {
    //     entry.target.classList.remove('is-sticking');
    //     scrollDiv.classList.remove('jump-sticky');
    //   }
    // });
  };
  
  /* As the breadcrumbs move out of sight, adjust the height of the Reader description. */
  let setDescriptionVisibility = function (entries, observer) {
    entries.forEach( entry => {
      console.log(entry.intersectionRatio);
      let descEl = document.querySelector('.reader-header .reader-desc');
      if ( entry.intersectionRatio === 0 ) {
        descEl.style.display = 'none';
      } else if ( entry.intersectionRatio === 1 ) {
        descEl.style.removeProperty('display');
        descEl.style.removeProperty('height');
      } else {
        descEl.style.removeProperty('display');
        descEl.style.height = entry.intersectionRatio * 100 +'px';
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
    (https://css-tricks.com/how-to-make-an-unobtrusive-scroll-to-top-button/) and "How to Detect When a 
    Sticky Element Gets Pinned" by Chris Coyier 
    (https://css-tricks.com/how-to-detect-when-a-sticky-element-gets-pinned/).
   */
  this.setUpScrollButton = function () {
    /* We're only interested in tracking when the `.reader-header` intersection ratio changes to or from 
      1.0 (fully visible). When it's below 1, the header's "sticky" position is kicking in. (We know 
      this because `.reader-header` is set to `top: -1px;`, meaning that when the header is behaving 
      "stickily", a single pixel is out of the viewport — and the ratio is less than 1.0.) */
    let ratioThresholds = [ 0, 0.5, 0.75, 1 ],
        readerHeader = document.querySelector('.reader-header'),
        headerObserver = new IntersectionObserver(setScrollButtonVisibility, { threshold: [0, 1] }),
        breadcrumbObserver = new IntersectionObserver(
          setDescriptionVisibility, { threshold:
          ratioThresholds });
    headerObserver.observe(readerHeader);
    headerObserver.observe(document.querySelector('.breadcrumbs'));
    //breadcrumbObserver.observe(document.querySelector('nav.breadcrumbs'))
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
