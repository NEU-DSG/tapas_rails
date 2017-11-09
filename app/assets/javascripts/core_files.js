(function($) {
  $(document).ready(function() {
    var editor;

    $(".reading").each(function(){
      if (!$(this).find("#reader_css_1").length){
        $(this).prepend("<link rel='stylesheet' type='text/css' id='reader_css_1' href=''></link><link rel='stylesheet' type='text/css' id='reader_css_2' href=''></link><link rel='stylesheet' type='text/css' id='reader_css_3' href=''></link>");
      }
      var style = $(this).parents(".node").find("select[name='reading_selector']").val();
      console.log(style);
      var pane = $(this);
      show_style(pane, style);
    });

    $("select[name='reading_selector']").on("change", function(e){
      e.preventDefault();
      var style = $(this).val()
      console.log(style);
      var pane = $(this).parents(".node").find(".reading");
      show_style(pane, style);
    });

    make_clickable($("body"));

    function make_clickable(body){
      body.find(" select[name='reading_selector']").on("change", function(e){
        e.preventDefault();
        var style = $(this).val();
        console.log(style);
        var pane = $(this).parents(".node").find(".reading");
        show_style(pane, style);
      });

      $('#toggle_word_wrap').on('change', function(){
        if ($('#toggle_word_wrap').is(':checked')){
          editor.getSession().setUseWrapMode(false);
        } else {
          editor.getSession().setUseWrapMode(true);
        }
      });

      $('#toggle_invisibles').on('change', function(){
        if ($('#toggle_invisibles').is(':checked')){
          editor.setShowInvisibles(false);
        } else {
          editor.setShowInvisibles(true);
        }
      });
    }

    function show_style(pane, style){
      console.log(style);
      console.log(pane);
      style_class = "reader_"+style;
      pane.find('[class^="reader_"]').hide();
      pane.find("link[id^='reader_css_']").each(function(){
        $(this).attr('href','');
      });
      pane.find("."+style_class).show();
      // THIS SECTION NEEDS A SERIOUS REFACTOR TO PULL THE CSS FILE LOCATIONS FROM THE API
      // AND TO GET THE JS FILE FROM THE API AND ADD THEM DYNAMICALLY
      $.getScript("/view_packages/common/jquery/jquery-3.2.1.min.js");
      $.getScript("/view_packages/common/jquery-ui-1.12.1/jquery-ui.min.js");
      $.getScript("/view_packages/common/jquery/plugins/jquery.blockUI.min.js");
      if (style == 'teibp'){
        pane.find(".teibp").addClass("default");
        console.log("going to teibp");
        $.getScript("/view_packages/teibp/js/teibp.js");
        pane.find("#reader_css_1").attr("href", "/view_packages/teibp/css/teibp.css");
        pane.find("#reader_css_2").attr("href", "/view_packages/teibp/css/sleepy.css");
        pane.find("#reader_css_3").attr("href", "/view_packages/teibp/css/terminal.css");
      }
      if (style == 'tapas_generic'){
        console.log("going to tapas G");
        $.getScript("/view_packages/tapas-generic/js/contextualItems.js");
        $.getScript("/view_packages/tapas-generic/js/tapas-generic.js");
        pane.find("#reader_css_1").attr("href", "/view_packages/tapas-generic/css/tapasGnormal.css");
        pane.find("#reader_css_2").attr("href", "/view_packages/tapas-generic/css/tapasGdiplo.css");
      }
      if (style == 'hieractivity'){
        $.getScript("/view_packages/common/d3/d3.v4.min.js");
        $.getScript("/view_packages/hieractivity/js/hieractivity.js");
        pane.find("#reader_css_1").attr("href", "/view_packages/hieractivity/../common/jquery-ui-1.12.1/jquery-ui.min.css");
        pane.find("#reader_css_2").attr("href", "/view_packages/hieractivity/css/hieractivity.css");
      }
      if (style == 'tei'){
        $(".reader_tei pre").attr("id", "ace");
        editor = ace.edit("ace");
        editor.setTheme("ace/theme/chrome");
        editor.getSession().setMode("ace/mode/xml");
        editor.getSession().setUseWrapMode(true);
        editor.setOptions({
          minLines: 20,
          useSoftTabs: true,
          showInvisibles: true,
          readOnly: true,
        });
        $(".reader_tei").resizable({
          resize: function( event, ui ) {
            editor.resize();
          }
        });
      }
    }

    if ($(".view-compare").length){
      var left = $(".view-compare .left");
      var left_nid = left.find("article").attr("id");
      if (left_nid){
        left_nid = left_nid.split("-")[1];
      } else {
        left_nid = null;
      }
      var right = $(".view_compare .right");
      var right_nid = right.find("article").attr("id");
      if (right_nid){
        right_nid = right_nid.split("-")[1];
      } else {
        right_nid = null;
      }
      left.find(".ctools-jump-menu-select option[value*='"+left_nid+"']").prop('selected', true);
      right.find(".ctools-jump-menu-select option[value*='"+right_nid+"']").prop('selected', true);
      $(".ctools-jump-menu-select").on("change", function(e){
        e.preventDefault();
        var nid = $(this).val();
        nid = nid.split("::/");
        nid = nid[nid.length -1];
        if ($(this).parents(".left").length){
          get_reader_view(nid, "left");
        }
        if ($(this).parents(".right").length){
          get_reader_view(nid, "right");
        }
      });
    }

    function get_reader_view(nid, side){
      pathArray = location.href.split( '/' );
      protocol = pathArray[0];
      host = pathArray[2];
      url = protocol + '//' + host;
      var side = $(".view-compare ."+side);
      side.append("<span class='fa fa-spinner fa-spin fa-4x'></span>");
      $.ajax({
        url: url + '/views/ajax',
        type: 'post',
        data: {
          view_name: 'test_reader_pane',
          view_display_id: 'block_2', //your display id
          view_args: nid, // your views arguments
        },
        dataType: 'json',
        success: function (response) {
          side.find(".view-test-reader-pane").remove();
          side.find(".fa-spinner").remove();
          if (response[1] !== undefined) {
            side.append(response[1].data);
            var pane = side.find(".reading");
            pane.prepend("<link rel='stylesheet' type='text/css' id='reader_css_1'></link><link rel='stylesheet' type='text/css' id='reader_css_2'></link><link rel='stylesheet' type='text/css' id='reader_css_3'></link>");
            var style = side.find("select[name='reading_selector']").val();
            make_clickable($("body"));
            show_style(pane, style);
          }
        }
      });
    }

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
