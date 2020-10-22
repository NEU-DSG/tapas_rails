const LOADING_SPINNER = document.getElementById('reading-interface-loading-spinner')

function hideLoadingSpinner() {
  if (!LOADING_SPINNER) return;

  LOADING_SPINNER.classList.add('hidden')
}

function showLoadingSpinner() {
  if (!LOADING_SPINNER) return;

  LOADING_SPINNER.classList.remove('hidden')
}

function updateReadingInterface(contents) {
  const readerNode = document.getElementById('reader-node')

  if (readerNode.firstChild) {
    readerNode.replaceChild(contents, readerNode.firstChild)
  } else {
    readerNode.appendChild(contents)
  }

  hideLoadingSpinner()
}

function readingEnvAfterLoad() {
  let rawXml = ''
  let styledTei = ''

  const canonicalObjectUrl = document.getElementById('core-file-url').dataset.url
  const selectionEl = document.getElementById('reading_selector') || {}

  async function updateXml() {
    showLoadingSpinner()

    const selectedOption = selectionEl.selectedOptions && selectionEl.selectedOptions[0] || {}
    const selectedValue = selectedOption.value || 'tei2html'

    if (selectedValue === 'teibp') {
      if (rawXml === '') {
        const resp = await fetch(canonicalObjectUrl)
        const xml = await resp.text()

        rawXml = xml
      }

      const pre = document.createElement('pre')
      pre.innerText = rawXml
      return updateReadingInterface(pre)
    }

    if (styledTei === '') {
      const doc = await SaxonJS.transform({
        sourceLocation: canonicalObjectUrl,
        stylesheetLocation: `/assets/${selectedValue}.sef.json`
      }, 'async')

      styledTei = doc.principalResult
    }

    updateReadingInterface(styledTei)
  }

  selectionEl.addEventListener('change', updateXml);
  updateXml();
}

(function($) {
  $(document).ready(function() {
    readingEnvAfterLoad()
  });
})(jQuery);

jQuery.browser = {};
(function () {
    jQuery.browser.msie = false;
    jQuery.browser.version = 0;
    if (navigator.userAgent.match(/MSIE ([0-9]+)\./)) {
        jQuery.browser.msie = true;
        jQuery.browser.version = RegExp.$1;
    }
})();
