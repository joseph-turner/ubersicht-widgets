moment = require('moment')

refreshFrequency: 5 * (60 * 1000)

command: (callback) ->
  # Gets location then gets weather
  self = this
  success = (pos) ->
    lat = pos.position.coords.latitude
    long = pos.position.coords.longitude
    self.address = pos.address

    # Count daily calls and prevent making too many
    today = moment().format('MM-DD-YYYY')
    count = localStorage.getItem('count') || 0

    # if saved today is today
    if localStorage.getItem('day') is today
      if count < 900
        localStorage.setItem('count', parseInt(count) + 1)
      else
        return
    else
      localStorage.setItem('day', today)
      localStorage.setItem('count', 1)

    $.ajax({
      url: 'http://127.0.0.1:41417/https://api.darksky.net/forecast/98b57de0bbdb70a6e461a1eab2e7b33a/' + lat + ',' + long,
      success: (data) ->
        callback null, data
      error: (error) ->
        console.error(error)
    });

  error = (err) ->
    if err
      console.warn(err)

  navigator.geolocation.getCurrentPosition(success, error)

update: (output, elem) ->
  # Updates DOM with data

  @$elem = $(elem);
  @$elem.find('.main').show()

  if output.alerts?.length
    @renderAlerts output.alerts

  currently = output.currently
  currently.hourlySummary = output.hourly?.summary
  currently.minutelySummary = output.minutely?.summary

  @renderCurrent currently
  @renderForecast output.daily
  @renderLocation @address


renderAlerts: (data) ->
  # console.log 'Alerts', data
  $alerts = @$elem.find('.alerts').empty()

  @renderAlert i, $alerts for i in data

renderAlert: (data, elem) ->
  # console.log 'Alert', data
  regions = data.regions.join(', ')
  expiration = moment.unix(data.expires).format('ddd, MMM DD [at] hh:mm')

  $(elem).append("""
    <li class="alert alert--#{data.severity}">
      <header class="alert__header">
        <h3 class="alert__title">
          <i class="alert__icon"><svg class="alert__icon__svg"><use id="alert" xlink:href="weather.widget/sprite.svg#alert-#{data.severity}"></use></svg></i>
          #{data.title}
        </h3>
        <p class="alert__regions">#{regions}</p>
        <p class="alert__expiration">Until #{expiration}</p>
      </header>
      <marquee class="alert__desc">#{data.description}</marquee>
    </li>
  """)


renderCurrent: (data) ->
  # console.log 'Currently', data

  @renderSVG data.icon, '#currentIcon'
  $current = @$elem.find('.current')
  # debugger;
  # console.log(data.minutelySummary)
  $current.find('.current__summary__title').text(data.minutelySummary)
  $current.find('.current__details__temp').text(Math.round(data.temperature) + '°')
  # $current.find('.current__details__title').text(data.summary)

renderLocation: (address) ->
  @$elem.find('.current__location').text(address.city + ', ' + address.state)

renderForecast: (data) ->
  # console.log 'Forecast', data
  $forecast = @$elem.find('.forecast')
  $forecast.find('.forecast__summary').text(data.summary)
  $('.forecast__daily').empty()

  @renderMoon data.data[0].moonPhase

  @renderSun data.data[0]
  @renderDaily data for data in data.data[0..4]

renderDaily: (data) ->
  # console.log('Daily:', data)
  dayName = @getDayName(data.time)
  $daily = $('.forecast__daily')
  $elem = $('#forecastDayTemplate').clone().attr('id', dayName).appendTo($daily)

  $elem.find('.forecast__day__name').text(dayName)
  $elem.find('.forecast__day__high').text(Math.round(data.apparentTemperatureHigh) + '°')
  $elem.find('.forecast__day__low').text(Math.round(data.apparentTemperatureLow) + '°')
  @renderSVG data.icon, "##{dayName} use", true

renderMoon: (data) ->
  # console.log 'Moon', data
  switch
    when data == 0
      moonPhase = 'moon-new'
    when data > 0 and data < .25
      moonPhase = 'moon-waxing-crescent'
    when data == .25
      moonPhase = 'moon-first-quarter'
    when data > .25 and data < .5
      moonPhase = 'moon-waxing-gibbous'
    when data == .5
      moonPhase = 'moon-full'
    when data > .5 and data < .75
      moonPhase = 'moon-waning-gibbous'
    when data == .75
      moonPhase = 'moon-last-quarter'
    when data > .75
      moonPhase = 'moon-waning-crescent'

  @renderSVG moonPhase, '#currentMoon'

renderSun: (data) ->
  sunriseTime = moment.unix(data.sunriseTime).format('hh:mm')
  sunsetTime = moment.unix(data.sunsetTime).format('hh:mm')
  # console.log 'Sun', sunriseTime, sunsetTime

  # debugger
  $('.sunrise__time').text(sunriseTime)
  $('.sunset__time').text(sunsetTime)

renderSVG: (icon, selector, isForecast) ->
  # icon = 'clear-day' if isForecast and icon is 'partly-cloudy-night'
  @$elem.find(selector).attr('xlink:href', @svgPath + '#' + icon)

getDayName: (time) ->
  moment.unix(time).format('dddd')

svgPath: 'weather.widget/sprite.svg'

render: (output) -> """
  <ul class="alerts"></ul>
  <div class="main">
    <div class="current">
      <ul class="sun-times">
        <li class="sunrise">
          <div class="sunrise__icon">
            <svg class="sunrise__icon__svg"><use id="sunrise" xlink:href="#{@svgPath}#sunrise"></use></svg>
          </div>
          <span class="sunrise__time"></span>
        </li>
        <li class="sunset">
          <div class="sunset__icon">
            <svg class="sunset__svg"><use id="sunset" xlink:href="#{@svgPath}#sunset"></use></svg>
          </div>
          <span class="sunset__time"></span>
        </li>
      </ul>
      <div class="current__moon">
        <svg class="current__moon__icon__svg"><use id="currentMoon" xlink:href=""></use></svg>
      </div>
      <div class="current__icon">
        <svg class="current__icon__svg"><use id="currentIcon" xlink:href=""></use></svg>
      </div>
      <div class="current__details">
        <h1 class="current__details__text">
          <span class="current__details__temp"></span>
          <span class="current__details__title"></span>
        </h1>
        <h2 class="current__location"></h2>

      </div>
      <div class="current__summary">
        <h3 class="current__summary__title"></h3>
      </div>
    </div>
    <div class="forecast">
      <ul class="forecast__daily"></ul>
      <h2 class="forecast__summary"></h2>
    </div>
  </div>

  <ul style="display: none">
    <li id="forecastDayTemplate" class="forecast__day">
      <h3 class="forecast__day__name"></h3>
      <div class="forecast__icon">
        <svg class="forecast__icon_svg"><use xlink:href=""></use></svg>
      </div>
      <p class="forecast__day__temp">
        <span class="forecast__day__high"></span>
        <span class="forecast__day__low"></span>
      </p>
    </li>
  </ul>
"""

style: """
  *, *::before, *::after
    box-sizing border-box

  top 10px
  right 10px
  max-width 400px
  color white
  font-family 'Helvetica Neue'

  svg
    max-width 100%
    max-height 100%
    fill white

  .main
    display none
    padding 10px 15px 15px
    background rgba(black, .3)
    -webkit-backdrop-filter blur(5px)
    border-radius 5px

  // ====================================
  // Alert Styles
  .alerts
    margin 0
    padding 0
    list-style none

  .alert
    margin 0 0 10px
    padding 5px 0
    border-radius 5px
    -webkit-backdrop-filter blur(2px)

    &--advisory
      background-color rgba(255, 209, 26, 0.75)
    &--watch
      background-color rgba(245, 99, 15, 0.5)
    &--warning
      background-color rgba(230, 50, 10, 0.5)

    &__header
      position relative
      padding 0 15px
      font-weight 200
    &__title
      margin 0
      font-size 24px
    &__icon
      display inline-block
      vertical-align -1px
    &__icon__svg
      width 20px
      height 20px

    &__regions
      display block
      margin 0 0 3px
      font-size 14px
      font-weight 300

    &__expiration
      margin 0 0 5px
      font-size 10px
      font-weight 400
      text-transform uppercase

  // ====================================
  // Current Styles

  .current
    position relative
    margin-bottom 10px
    border-bottom 1px solid white
    text-align center
    font-size 0

    &__moon
      position absolute
      top 30px
      right 40px
      width 40px
      height 40px

    &__icon
      display inline-block
      vertical-align top
      width 100px
      height 100px
      padding 0 20px 0 0

    &__details
      display inline-block

      &__text
        margin 15px 0 0
        font-weight 200

      &__temp
        font-size 42px

      &__title
        font-size 16px
        font-weight 400

    &__location
      margin 0
      font-size 14px
      font-weight 200
      text-align left

    &__summary
      &__title
        margin 0 0 12px
        font-size 24px
        font-weight 200

  .sun-times
    position absolute
    top 5px
    left 5px
    margin 0
    padding 0
    list-style none

    .sunrise,
    .sunset
      font-size 12px

      &__icon
        width 25px
        height 25px
        margin 0 auto

    .sunrise
      margin-bottom 10px

  // ====================================
  // Forecast Styles

  .forecast
    &__summary
      margin 10px 0 0
      padding 10px 10px 0
      border-top 1px solid white
      font-size 18px
      font-weight 200

    &__daily
      display flex
      list-style none
      margin 0 0 10px
      padding 0 0 10px

    &__day
      flex 1 0 60px
      text-align center

      &__name
        margin-bottom 0
        font-size 12px
        font-weight 300

      &__temp
        margin 0
        font-size 12px

      &__high
        font-weight 400

      &__low
        font-weight 200

    &__icon
      height 60px
      padding 10px

"""
