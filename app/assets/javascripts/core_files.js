const LOADING_SPINNER = document.getElementById('reading-interface-loading-spinner')

function hideLoadingSpinner() {
  if (!LOADING_SPINNER) return;

  LOADING_SPINNER.classList.add('hidden')
}

function showLoadingSpinner() {
  if (!LOADING_SPINNER) return;

  LOADING_SPINNER.classList.remove('hidden')
}

class ReadingEnvironment {
  rawXml;
  teiBp;
  tapasGeneric;

  constructor(url, selectionEl, readerNode) {
    this.url = url
    this.selectionEl = selectionEl
    this.readerNode = readerNode

    this.selectionEl.addEventListener('change', this.updateXml.bind(this))

    this.updateXml()
  }

  async handleRawXml() {
    if (!this.rawXml) {
      const resp = await fetch(this.url)
      const xml = await resp.text()
      const pre = document.createElement('pre')
      pre.innerText = xml;
      this.rawXml = pre
    }

    return this.rawXml
  }

  // [["TAPAS", 'tei2html'], ["Raw XML", 'raw'], ['TEI', 'teibp']]
  async handleSelection(selection = 'tei2html') {
    if (selection === 'raw') {
      return this.handleRawXml()
    } else if (selection === 'tei2html') {
      return this.handleTapas()
    } else if (selection === 'teibp') {
      return this.handleTeiBoilerplate()
    }
  }

  async handleTapas() {
    if (!this.tapasGeneric) {
      const doc = await SaxonJS.transform({
        sourceLocation: this.url,
        // TODO: (charles) Maybe don't hardcode as many of these locations?
        stylesheetLocation: '/view_packages/tapas-generic/tei2html.sef.json',
        stylesheetParams: {
          'Q{}assets-base': '/view_packages/tapas-generic/',
          tapasHome: window.location,
        }
      }, 'async')

      this.tapasGeneric = doc.principalResult
    }

    return this.tapasGeneric
  }

  async handleTeiBoilerplate() {
    if (!this.teiBp) {
      const doc = await SaxonJS.transform({
        sourceLocation: this.url,
        stylesheetLocation: '/view_packages/teibp/teibp.sef.json',
      }, 'async')

      this.teiBp = doc.principalResult
    }

    return this.teiBp
  }

  async updateXml() {
    showLoadingSpinner()

    const selectedValue = (this.selectionEl.selectedOptions && this.selectionEl.selectedOptions[0] || {}).value
    const contents = await this.handleSelection(selectedValue)

    this.updateReadingInterface(contents)

    hideLoadingSpinner()
  }

  updateReadingInterface(contents) {
    if (this.readerNode.firstChild) {
      this.readerNode.replaceChild(contents, this.readerNode.firstChild)
    } else {
      this.readerNode.appendChild(contents)
    }
  }
}

function initializeReadingEnv() {
  const url = document.getElementById('core-file-url').dataset.url
  const selectionEl = document.getElementById('reading_selector')
  const readerNode = document.getElementById('reader-node')

  window.TAPAS_READING_ENVIRONMENT = new ReadingEnvironment(url, selectionEl, readerNode)
}

(function($) {
  $(document).ready(initializeReadingEnv);
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
