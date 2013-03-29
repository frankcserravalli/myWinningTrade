class Adsense
  constructor: (@ad_client) ->
    if google?
      google.load 'ads', '1'
      google.setOnLoadCallback @initPage
      @ads = {}
      $(document).on 'page:fetch', =>
        @clearAds()
      $(document).on 'page:load', =>
        @initPage()

  initPage: =>
    ad.load() for id, ad of @ads

  clearAds: ->
    @ads = {}

  newAd: (container, options) ->
    id = 'ads_' + container.id
    @ads[id] = new Ad @, id, container, options

class Ad
  constructor: (@adsense, @id, @container, @options) ->

  load: ->
    if @ad_object? then @refresh() else @create()

  refresh: ->
    @ad_object.refresh()

  create: ->
    @ad_object = new google.ads.Ad @adsense.ad_client, @container, @options

window.MyAdsense = new Adsense "ca-pub-6411672013871167" # your google_ad_client id