(function() {
  if (window.TradingView && window.TradingView.host) {
    return;
  }
  /**
   * @file TradingView object allows adding charts from <a href="https://www.tradingview.com/">tradingview.com</a> to your website.
   * Grab it from <a href="https://s3.amazonaws.com/tradingview/tv.js">https://s3.amazonaws.com/tradingview/tv.js</a>
   * @name TradingView API
   * @example <b>Create chart widget:</b>
   * &lt;script type="text/javascript" src="https://s3.amazonaws.com/tradingview/tv.js"&gt;&lt;/script&gt;
   * &lt;script type="text/javascript"&gt;
   * var tradingview_widget_options = {};
   * tradingview_widget_options.width  = 986;
   * tradingview_widget_options.height = 500;
   * tradingview_widget_options.symbol = 'GOOG';
   * tradingview_widget_options.interval = 'D';
   * tradingview_widget_options.toolbar_bg = '#E4E8EB';
   * tradingview_widget_options.allow_symbol_change = true;
   * new TradingView.widget(tradingview_widget_options);
   * &lt;/script&gt;
   *
   * @example <b>Create published chart with id i5Rz7F6g:</b>
   * &lt;script type="text/javascript" src="https://s3.amazonaws.com/tradingview/tv.js"&gt;&lt;/script&gt;
   * &lt;script type="text/javascript"&gt;
   * var tradingview_embed_options = {};
   * tradingview_embed_options.width = 640;
   * tradingview_embed_options.height = 400;
   * tradingview_embed_options.chart = 'i5Rz7F6g';
   * new TradingView.chart(tradingview_embed_options);
   * &lt;/script&gt;
   */
  var TradingView = {
    host : 'https://www.tradingview.com',
    gEl : function(id) {
      return document.getElementById(id);
    },
    gId : function() {
      return 'tradingview_' + (((1+Math.random())*0x100000)|0).toString(16).substring(1);
    },
    onready : function(callback) {
      if (window.addEventListener) {
        window.addEventListener('DOMContentLoaded', callback, false);
      } else {
        window.attachEvent('onload', callback);
      }
    },
    css : function(css_content) {
      var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'), rules;

      style.type = 'text/css';
      if (style.styleSheet) {
        style.styleSheet.cssText = css_content;
      } else {
        rules = document.createTextNode(css_content);
        style.appendChild(rules);
      }
      head.appendChild(style);
    },
    bindEvent : function(o, ev, fn){
      if (o.addEventListener){
        o.addEventListener(ev, fn, false);
      } else if (o.attachEvent){
        o.attachEvent('on' + ev, fn);
      }
    },
    unbindEvent : function(o, ev, fn){
      if (o.removeEventListener){
        o.removeEventListener(ev, fn, false);
      } else if (o.detachEvent){
        o.detachEvent('on' + ev, fn);
      }
    },

    /**
     * Create new widget. Go to <a href="https://www.tradingview.com/widget/">https://www.tradingview.com/widget/</a>
     * for boilerplate code generator.
     * @param {object} options Can contain following fields: width, height, symbol, interval, autosize, hide_top_toolbar,
     * hide_side_toolbar, allow_symbol_change, save_image, container, toolbar_bg.
     * @constructor
     * @example
     * var widget = new TradingView.widget({
     * 	width: 900,
     * 	height: 400,
     * 	symbol: 'GOOG',
     * 	interval: 'D',
     * 	toolbar_bg: '#E4E8EB',
     * 	allow_symbol_change: true
     * });
     */
    widget : function(options) {
      this.id = TradingView.gId();
      this.options = {
        width : options.width || 800,
        height : options.height || 500,
        symbol : options.symbol || 'GOOG',
        interval : options.interval || '1',
        autosize : options.autosize,
        hide_top_toolbar : options.hide_top_toolbar,
        hide_side_toolbar : options.hide_side_toolbar !== undefined ? options.hide_side_toolbar : true,
        allow_symbol_change : options.allow_symbol_change,
        save_image : options.save_image !== undefined ? options.save_image : true,
        container : options.container_id || '',
        toolbar_bg : options.toolbar_bg || 'E4E8EB',
        watchlist : options.watchlist || [],
        details: !!options.details,
        news: !!options.news
      };

      this._ready_handlers = [];
      this.create();
    },

    /**
     * Create new embeded chart. Go to any chart on <a href="https://www.tradingview.com/">tradingview.com</a>,
     * then click Share button for boilerplate code generator.
     * @param {object} options Can contain following fields: width, height, container, chart.
     * @constructor
     * @example var chart = new TradingView.chart({
     * 	width: 640,
     * 	height: 400,
     * 	chart: 'i5Rz7F6g'
     * });
     */
    chart : function(options) {
      this.id = TradingView.gId();
      this.is_fullscreen = false;
      this.options = {
        width : options.width || 640,
        height : options.height || 500,
        container : options.container_id || '',
        realtime : options.realtime,
        chart : options.chart
      };

      this._ready_handlers = [];
      this.create();
    }
  };

  TradingView.widget.prototype = {
    create : function() {
      var widget_html = this.render(),
        self = this,
        c;
      if (this.options.container) {
        TradingView.gEl(this.options.container).innerHTML = widget_html;
      } else {
        document.write(widget_html);
      }

      c = TradingView.gEl(this.id);
      this.postMessage = TradingView.postMessageWrapper(c.contentWindow, this.id);
      TradingView.bindEvent(c, 'load', function() {
        self.postMessage.get('widgetReady', {}, function() {
          var i;
          self._ready = true;
          for (i = self._ready_handlers.length; i--;) {
            self._ready_handlers[i].call(self);
          }
        });
      });

    },

    /**
     * Fires specified callback when widget is fully loaded
     * @param {function} callback A callback
     * @method
     * @example
     * var widget = new TradingView.widget(<i>options</i>);
     * widget.ready(function() {
     * 	widget.getSymbolInfo(function(info) {
     * 		console.log('widget info: ', info);
     * 	});
     * });
     */
    ready : function(callback) {
      if (this._ready) {
        callback.call(this);
      } else {
        this._ready_handlers.push(callback);
      }
    },

    render : function() {
      var url = TradingView.host + '/widgetembed/' +
        '?symbol=' + this.options.symbol +
        '&interval=' + this.options.interval +
        (this.options.hide_top_toolbar ? '&hidetoptoolbar=1' : '') +
        ((! this.options.hide_side_toolbar) ? '&hidesidetoolbar=0' : '') +
        (this.options.allow_symbol_change ? '&symboledit=1' : '') +
        ((! this.options.save_image) ? '&saveimage=0' : '') +
        '&toolbarbg=' + this.options.toolbar_bg.replace('#', '') +
        ((this.options.watchlist && this.options.watchlist.length && this.options.watchlist.join) ? '&watchlist=' + encodeURIComponent(this.options.watchlist.join('\x1F')) : '') +
        (this.options.details ? '&details=1' : '') +
        (this.options.news ? '&news=1' : '');

      return '<iframe id="' + this.id + '"' +
        ' src="' + url + '"' +
        ( this.options.autosize ?
          ' style="width: 100%; height: 100%;"' :
          ' width="' + this.options.width + '"' +
            ' height="' + this.options.height + '"' ) +
        ' frameborder="0" allowTransparency="true" scrolling="no"></iframe>';
    },

    /**
     * Get a screenshot of current chart.
     * @param {function} callback Takes a link to screenshot.
     * @method
     * @example widget.image(function(link) {
     * 	console.log(link); // prints something like https://www.tradingview.com/x/3xjnWrCO/
     * });
     */
    image : function(callback) {
      this.postMessage.get('imageURL', {}, function(id) {
        var link = TradingView.host + '/x/' + id + '/';
        callback(link);
      });
    },

    /**
     * Save current view and get chart ID, which can be later embeded via TradingView.chart().
     * @param {function} callback Called when chart finished saving and takes chart ID.
     * @method
     * @see TradingView.chart()
     */
    saveChart : function(callback) {
      this.postMessage.get('chartID', {}, callback);
    },

    /**
     * Get information about selected instrument (symbol).
     * @param {function} callback Takes chart symbol info object. It has following fields: name, exchange, type, description, interval.
     * @method
     * @example widget.getSymbolInfo(function(info) {
     * 	// prints something like {"name":"GOOG","exchange":"NASDAQ","description":"Google Inc.","type":"stock","interval":"D"}
     * 	console.log(info);
     * });
     */
    getSymbolInfo : function(callback) {
      this.postMessage.get('symbolInfo', {}, callback);
    },

    remove : function() {
      var widget = TradingView.gEl(this.id);
      widget.parentNode.removeChild(widget);
    },

    // be careful with this one, may remove some of your page's contents
    reload : function() {
      var widget = TradingView.gEl(this.id),
        parent = widget.parentNode;

      parent.removeChild(widget);
      parent.innerHTML = this.render();
    }
  };

  TradingView.chart.prototype = {
    create : function() {
      var chart_html = this.render(),
        self = this,
        a, c, f, l;

      if (!TradingView.chartCssAttached) {
        TradingView.css(this.renderCss());
        TradingView.chartCssAttached = true;
      }
      if (this.options.container) {
        TradingView.gEl(this.options.container).innerHTML = chart_html;
      } else {
        document.write(chart_html);
      }

      c = TradingView.gEl(this.id);
      a = TradingView.gEl(this.id + '_actions');
      f = TradingView.gEl(this.id + '_fullscreen');
      TradingView.bindEvent(c, 'load', function() {
        var i;
        a.style.display = 'block';
        self._ready = true;
        for (i = self._ready_handlers.length; i--;) {
          self._ready_handlers[i].call(self);
        }
      });
      TradingView.bindEvent(f, 'click', function() {
        self.toggleFullscreen();
      });
      TradingView.onready(function() {
        var rf = false;
        if (document.querySelector) {
          if(document.querySelector('a[href$="/v/' + self.options.chart +'/"]')) {
            rf = true;
          }
        } else {
          var anchors = document.getElementsByTagName("a");
          var re = new RegExp('/v/' + self.options.chart + '/$');
          for (var i=0; i<anchors.length; i++) {
            if (re.test(anchors[i].href)) {
              rf = true;
              break;
            }
          }
        }
        if (rf) {
          c.src += '#nolinks';
          c.name = "nolinks";
        }
      });
      this.postMessage = TradingView.postMessageWrapper(c.contentWindow, this.id);
    },

    /**
     * Fires a callback when chart is fully loaded.
     * @param {function} callback
     * @method
     * @see TradingView.widget.ready()
     */
    ready : TradingView.widget.prototype.ready,

    renderCss : function() {
      var url = TradingView.host;
      return '.tradingview-widget {position: relative;}.tradingview-widget .chart-actions-float {display: none; position: absolute; z-index: 5; top: 0; right: 0; background: #fff; border: 1px solid #bfbfbf; border-radius: 0 3px 0 3px; padding: 3px 3px 3px 3px; height: 23px;}.tradingview-widget .chart-actions-float .tradingview-button {font-weight: normal; font-size: 11px; padding: 3px 5px;}.tradingview-widget .chart-actions-float .status-picture {margin: 4px 1px 0 3px; border: none !important; padding: 0 !important; background: none !important;}.tradingview-widget .chart-status-picture {position: absolute; z-index: 50;}.tradingview-widget .icon {display: inline-block; background: url(\''+ url + '/static/images/icons.png\') 0 0 no-repeat; position: relative;}.tradingview-widget .icon-action-realtime{background-position: -120px -80px; width: 15px; height: 15px; left: -1px; vertical-align: top;}.tradingview-widget .icon-action-zoom{background-position: -100px -80px; width: 15px; height: 15px; left: -1px; vertical-align: top;}.tradingview-widget .exit-fullscreen {z-index: 16; position: fixed; top: -1px; left: 50%; display: none; opacity: 0.6; background: #f9f9f9; color: #848487; border-radius: 0 0 3px 3px; border: 1px solid #b2b5b8; font-size: 11px; width: 116px; font-weight: bold; padding: 2px 4px; cursor: default; margin: 0 0 0 -62px;}.tradingview-widget .exit-fullscreen:hover {opacity: 1;}.tradingview-widget .tradingview-button {padding: 6px 10px 5px; height: 15px; display: inline-block; vertical-align: top; text-decoration: none !important;color: #6f7073; cursor: pointer;border: 1px solid #b2b5b8; font: bold 12px Calibri, Arial; background: url(\''+ url + '/static/images/button-bg.png\') 0 0 repeat-x; border-radius: 3px; -moz-border-radius: 3px; -webkit-user-select: none;-moz-user-select: none;-o-user-select: none;user-select: none; box-sizing: content-box; -moz-box-sizing: content-box; -webkit-box-sizing: content-box;}.tradingview-widget .tradingview-button:hover, .tv-button:active {background-position: 0 -26px; color: #68696b;}';
    },

    render : function() {
      var url = TradingView.host;

      return '<div class="tradingview-widget" style="width: '+this.options.width+'px; height: '+this.options.height+'px;">' +
        '<div id="'+this.id+'_actions" class="chart-actions-float">' +
        '<a id="'+this.id+'_fullscreen" class="tradingview-button"><span class="icon icon-action-zoom"></span> Full Screen</a> ' +
        '<a id="'+this.id+'_live" class="tradingview-button" target="_blank" href="'+ url + '/e/?clone=' + this.options.chart + '">' +
        '<span class="icon icon-action-realtime"></span> Make It Live' +
        '</a> ' +
        ( this.options.realtime ?
          '<img class="status-picture" src="'+ url + '/static/chart-client/css/images/status-realtime.png" alt=""/>' :
          '') +
        '</div>' +
        '<iframe id="' + this.id + '"' +
        ' src="' + url + '/embed/' + this.options.chart + '/?method=script"' +
        ' width="' + this.options.width + '"' +
        ' height="' + this.options.height + '"' +
        ' frameborder="0" allowTransparency="true" scrolling="no"></iframe>' +
        '</div>';
    },

    windowSize : function() {
      var w = 0, h = 0;
      if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
        w = document.documentElement.clientWidth;
        h = document.documentElement.clientHeight;
      } else if( typeof( window.innerWidth ) == 'number' ) {
        w = window.innerWidth;
        h = window.innerHeight;
      } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
        w = document.body.clientWidth;
        h = document.body.clientHeight;
      }
      return {width: w, height: h};
    },

    toggleFullscreen : function() {
      var frame = TradingView.gEl(this.id),
        actions = TradingView.gEl(this.id+'_actions'),
        ws = this.windowSize();

      if (this.is_fullscreen) {
        frame.style.position = 'static';
        frame.style.width = this.options.width+'px';
        frame.style.height = this.options.height+'px';
        frame.style.zIndex = 'auto';
        frame.style.backgroundColor = 'transparent';
        actions.style.position = 'absolute';
        actions.style.zIndex = 'auto';
        TradingView.unbindEvent(document, 'keydown', this.getKeyHandler());
      } else {
        frame.style.position = 'fixed';
        frame.style.width = ws.width+'px';
        frame.style.height = ws.height+'px';
        frame.style.left = '0px';
        frame.style.top = '0px';
        frame.style.zIndex = '1000000';
        frame.style.backgroundColor = '#fff';
        actions.style.position = 'fixed';
        actions.style.zIndex = '1000001';
        TradingView.bindEvent(document, 'keydown', this.getKeyHandler());
      }
      this.is_fullscreen = !this.is_fullscreen;
    },

    getKeyHandler : function() {
      var that = this;
      if (!this.keyHandler) {
        this.keyHandler = function(e) {
          if (e.keyCode == 27) {
            that.toggleFullscreen();
          }
        };
      }
      return this.keyHandler;
    },

    /**
     * Get symbol info for chart.
     * @param {function} callback
     * @method
     * @see TradingView.widget.getSymbolInfo()
     */
    getSymbolInfo : function(callback) {
      this.postMessage.get('symbolInfo', {}, callback);
    }
  };

  TradingView.postMessageWrapper = (function() {
    var get_handlers = {},
      on_handlers = {},
      client_targets = {},
      on_target,
      call_id = 0,
      provider_id = 'TradingView';

    window.addEventListener('message', function (e) {
      var msg, i;
      try {
        msg = JSON.parse(e.data);
      } catch (e) {
        return;
      }
      if (!msg.provider || msg.provider != provider_id) {
        return;
      }
      if (msg.type == 'get') {
        on_handlers[msg.name].call(msg, msg.data, function(result) {
          var reply = {
            id: msg.id,
            type: 'on',
            name: msg.name,
            client_id: msg.client_id,
            data: result,
            provider: provider_id
          };
          on_target.postMessage(JSON.stringify(reply), '*');
        });
      } else if (msg.type == 'on') {
        if (get_handlers[msg.client_id] && get_handlers[msg.client_id][msg.id]) {
          get_handlers[msg.client_id][msg.id].call(msg, msg.data);
          delete get_handlers[msg.client_id][msg.id];
        }
      }
    });

    return function(target, client_id) {
      get_handlers[client_id] = {};
      client_targets[client_id] = target;
      on_target = target;

      return {
        on : function(name, callback) {
          on_handlers[name] = callback;
        },

        get : function(name, data, callback) {
          var msg = {
            id: call_id++,
            type: 'get',
            name: name,
            client_id: client_id,
            data: data,
            provider: provider_id
          };
          get_handlers[client_id][msg.id] = callback;
          client_targets[client_id].postMessage(JSON.stringify(msg), '*');
        }
      };
    };
  })();

  if (window.TradingView && jQuery) {
    jQuery.extend(window.TradingView, TradingView);
  } else {
    window.TradingView = TradingView;
  }
})();