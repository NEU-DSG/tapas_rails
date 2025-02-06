// Javascript to simulate website functionality in a wireframe

// Set up namespace.
var tapas = tapas || {};
tapas.wire = {};

// Create an anonymous function to hold functions to be namespaced.
( function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  /*** Private functions ***/
  
  //var getSurrogate = function (htmlid) { };
  
  
  /*** Public functions ***/
  
  this.isAuthenticated = function () {
    let storedValue = sessionStorage.getItem('tapas-auth');
    console.log("Stored value is: "+storedValue);
    return storedValue !== null ? storedValue : false;
  };
  
  this.login = function () {
    sessionStorage.setItem('tapas-auth', true);
    document.documentElement.dataset['tapasAuth'] = true;
  };
  
  this.logout = function () {
    sessionStorage.setItem('tapas-auth', false);
    document.documentElement.dataset['tapasAuth'] = false;
  };
  
  this.logToggle = function (event) {
    event.stopPropagation();
    if ( that.isAuthenticated() === 'true' ) {
      console.log("Logging out");
      that.logout();
    } else {
      console.log("Signing in");
      that.login();
    }
  };
  
  
  /*** Class definitions ***/
  
  /*this.MenuOption = class {
    constructor () { }
  };*/
}).apply(tapas.wire); // Apply the namespace to the anonymous function.


// Create a callback function to be run when the entire document has loaded.
var onLoad = function() {
  var loggedIn = tapas.wire.isAuthenticated();
  console.log("Logged in on page load? "+loggedIn);
  // Reproduce the user authentication state saved to sessionStorage.
  if ( loggedIn ) {
    tapas.wire.login();
  } else {
    tapas.wire.logout();
  }
  // Toggle the authentication state when requested.
  document.getElementById('btn-auth').addEventListener('click', tapas.wire.login);
  document.getElementById('btn-auth-out').addEventListener('click', tapas.wire.logout);
};

/* Ensure that the callback function above is run, whether or not the DOM has 
  already been loaded. Solution by Julian Kühnel: 
  https://www.sitepoint.com/jquery-document-ready-plain-javascript/ */
if ( document.readyState === 'complete' 
   || ( document.readyState !== 'loading' && !document.documentElement.doScroll ) 
   ) {
  onLoad();
} else {
  document.addEventListener('DOMContentLoaded', onLoad);
}
