format = '%A, %B %d %H:%M'

command: "date +\"#{format}\""

# the refresh frequency in milliseconds
refreshFrequency: 30000

render: (output) -> """
  <h1>#{output}</h1>
"""

style: """
  color: #FFFFFF
  font-family: Helvetica Neue
  left: 20px
  bottom: 60px

  &::after
    content: ''
    position: absolute
    background: rgba(#000, .35)
    top: -80px
    left: -10px
    width: 705px
    height: 210px
    z-index: -1
    border-radius: 5px
    -webkit-backdrop-filter: blur(5px) contrast(100%) saturate(140%)

  h1
    font-size: 4em
    font-weight: 100
    margin: 0
    padding: 0
  """
