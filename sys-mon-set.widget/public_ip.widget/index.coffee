command: "curl -s ipinfo.io/ip"

refreshFrequency: 1200000

style: """
  bottom: 140px
  left: 90px
  color: #fff
  font-family: Helvetica Neue

  div
    display: block
    text-shadow: 0 0 1px rgba(#000, 0.5)
    font-size: 24px
    font-weight: 100

"""


render: -> """
  <div class='ip_address'></div>
"""

update: (output, domEl) ->
  $(domEl).find('.ip_address').html(output)

