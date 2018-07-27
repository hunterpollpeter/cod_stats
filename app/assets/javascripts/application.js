// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require_tree .

$(document).on('turbolinks:load', function() {

    $('.tab-content').each(function() {
        var $this = $(this);
        var $active_child = $this.children('.active');
        $active_child.removeClass('from-right from-left to-right to-left');
        $this.height($active_child.height());
    });

    $('.nav-tabs a').on('hidden.bs.tab', function(event) {
        var $target = $(event.target);
        var $relatedTarget = $(event.relatedTarget);
        var $toggle = $target.parents('.dropdown').find('.nav-select-toggle');
        var title = $relatedTarget.text();
        var target_href = $target.data('target');
        var relatedTarget_href = $relatedTarget.data('target');
        var $target_div = $(target_href);
        var $relatedTarget_div = $(relatedTarget_href);
        var $container = $relatedTarget_div.parents('.tab-content');
        var prev_i = $(target_href).index();
        var curr_i = $(relatedTarget_href).index();
        var from =  prev_i < curr_i ? 'right' : 'left';
        var to =    prev_i < curr_i ? 'left' : 'right';

        if(prev_i < 0) {
            prev_i = 0;
            $target_div = $relatedTarget_div.siblings(prev_i);
        }

        $container.height($relatedTarget_div.height());
        $toggle.html(title);
        $toggle.data('target', relatedTarget_href);
        $target_div.removeClass('from-left from-right');
        $target_div.addClass('was-active to-' + to);
        $relatedTarget_div.addClass('becoming-active from-' + from);
        setTimeout(function () {
            $target_div.removeClass('was-active to-' + to);
            $relatedTarget_div.removeClass('becoming-active');
        }, 250);
    });
});
