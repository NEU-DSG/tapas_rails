/*
 * TAPAS Javascript
 *
 * General events handling and functionality, useful across the website.
 */

// Set up namespace.
var tapas = tapas || {};
tapas.general = {};

// Create an anonymous function to hold functions to be namespaced.
( function() {
  /* Capture the current context so these functions can refer to themselves even when the context 
    changes. */
  var that = this;
  
  
  /**
      PRIVATE FUNCTIONS
   **/
  
  /*
    In response to some event, find all buttons for collapsing sections in `.tapas-container`, and close 
    their target elements.
   */
  let collapseAllDisclosures = function(event) {
    console.log("Collapsing containers");
    document.querySelectorAll('.tapas-container button[data-bs-toggle="collapse"][aria-expanded="true"]').forEach(element => {
      let myTarget = document.querySelector(element.dataset.bsTarget);
      bootstrap.Collapse.getOrCreateInstance(myTarget).hide();
    });
  }; // end collapseAllDisclosures()
  
  /*
    In response to some event, find all buttons for collapsing sections in `.tapas-container`, and open 
    their target elements.
   */
  let expandAllDisclosures = function(event) {
    console.log("Expanding containers");
    document.querySelectorAll('.tapas-container button[data-bs-toggle="collapse"][aria-expanded="false"]').forEach(element => {
      let myTarget = document.querySelector(element.dataset.bsTarget);
      bootstrap.Collapse.getOrCreateInstance(myTarget).show();
    });
  }; // end collapseAllDisclosures()
  
  /*
    Toggle the "tapas-container-collapsed" class on the wrapper `.tapas-container` element.
   */
  let toggleContainerCollapse = function(event) {
    let containerEl = event.target.parentElement,
        isCollapsed = event.type === 'hidden.bs.collapse';
    containerEl.classList.toggle('tapas-container-collapsed', isCollapsed);
  }; // end toggleContainerCollapse()
  
  
  /**
      PUBLIC FUNCTIONS
   **/
  
  /*
    Set up any event listeners that are necessary to the working of the page.
   */
  this.prepareTapas = function() {
    /* If there is a `.tapas-container` on this page, we need events to monitor the collapsible toggles, 
      and add the "tapas-container-collapsed" class when appropriate. */
    if ( document.querySelector('.tapas-container') !== null ) {
      console.log("Adding event listeners for collapsible containers.");
      document.querySelectorAll('.tapas-container .tapas-container-content').forEach(element => {
        // Trigger the event when Bootstrap's collapse animation has fully hidden content.
        element.addEventListener('hidden.bs.collapse', toggleContainerCollapse);
        // Also trigger the event when the user asks to show the content again.
        element.addEventListener('show.bs.collapse', toggleContainerCollapse);
      });
    }
    /* If there is a pair of "Expand all"/"Collapse all" controls, we need to add event listeners to 
      make those actions happen. */ // #control-expand
    let collapseAllButtons = document.querySelectorAll('button.control-collapse'),
        expandAllButtons = document.querySelectorAll('button.control-expand');
    if ( collapseAllButtons.length > 0 ) {
      collapseAllButtons.forEach(element => {
        element.addEventListener('click', collapseAllDisclosures);
      });
    }
    if ( expandAllButtons.length > 0 ) {
      expandAllButtons.forEach(element => {
        element.addEventListener('click', expandAllDisclosures);
      });
    }
  }; // end tapas.general.prepareTapas()
  
}).apply(tapas.general); // Apply the namespace to the anonymous function.


/* Ensure that the callback function above is run, whether or not the DOM has 
  already been loaded. Solution by Julian Kühnel: 
  https://www.sitepoint.com/jquery-document-ready-plain-javascript/ */
if ( document.readyState === 'complete' 
   || ( document.readyState !== 'loading' && !document.documentElement.doScroll ) 
   ) {
  tapas.general.prepareTapas();
} else {
  document.addEventListener('DOMContentLoaded', tapas.general.prepareTapas);
}
