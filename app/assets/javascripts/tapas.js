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
    Close all disclosures within a `.tapas-container`. Convenience function for 
    `toggleAllDisclosures(false)`.
   */
  let collapseAllDisclosures = function(event) {
    console.log("Collapsing containers");
    toggleAllDisclosures(false);
  }; // end collapseAllDisclosures()
  
  /*
    Open all disclosures within a `.tapas-container`. Convenience function for 
    `toggleAllDisclosures(true)`.
   */
  let expandAllDisclosures = function(event) {
    console.log("Expanding containers");
    toggleAllDisclosures(true);
  }; // end expandAllDisclosures()
  
  /*
    Find all buttons for collapsing sections in `.tapas-container`, and either open or close their 
    target elements.
   */
  let toggleAllDisclosures = function(show) {
    /* If the 'show' parameter isn't a Boolean, report it and do nothing. */
    if ( typeof show !== 'boolean' ) {
      console.warn("Unexpected value of 'show' parameter: ");
      console.warn(show);
      return;
    }
    document.querySelectorAll('.tapas-container button[data-bs-toggle="collapse"][aria-expanded="'+ !show +'"]')
      .forEach(element => { toggleThisDisclosure(element.dataset.bsTarget, show) });
  }; // end toggleAllDisclosures()
  
  /*
    Given a DOM selector target, toggle that disclosure open or closed.
    
    Bootstrap's Collapse methods are used to perform the action on request. Since Bootstrap 
    automatically toggles a single collapsible open or closed when the toggle button is pressed, this 
    function is really only useful for augmenting Bootstrap's behavior with additional controls. 
    (E.g. `toggleAllDisclosures()`.)
   */
  let toggleThisDisclosure = function(el, show) {
    let bsInstance,
        myTarget = document.querySelector(el);
    /* Do nothing if the target doesn't exist. */
    if ( myTarget === null ) {
      console.warn("Disclosure '" + el + "' doesn't exist");
      return;
    }
    bsInstance = bootstrap.Collapse.getOrCreateInstance(myTarget)
    if ( show === false ) {
      bsInstance.hide();
    } else {
      bsInstance.show();
    }
  }; // end toggleThisDisclosure()
  
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
    Set up event listeners for collapsible `.tapas-container`s.
   */
  this.setUpCollapsibles = function() {
    /* Make sure Bootstrap's Collapse is loaded before setting up anything. */
    if ( window.bootstrap === undefined || window.bootstrap.Collapse === undefined ) {
      console.error("Bootstrap isn't loaded. Cannot set up collapsible containers");
      return;
    }
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
      make those actions happen. */
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
  }; // end tapas.general.setUpCollapsibles()
  
}).apply(tapas.general); // Apply the namespace to the anonymous function.


/* Ensure that the callback function above is run, whether or not the DOM has 
  already been loaded. Solution by Julian Kühnel: 
  https://www.sitepoint.com/jquery-document-ready-plain-javascript/ */
if ( document.readyState === 'complete' 
   || ( document.readyState !== 'loading' && !document.documentElement.doScroll ) 
   ) {
  tapas.general.setUpCollapsibles();
} else {
  document.addEventListener('DOMContentLoaded', tapas.general.setUpCollapsibles);
}
