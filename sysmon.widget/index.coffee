moment = require 'moment'

command: ""

refreshFrequency: 1000

render: -> """
  <div class="row">
    <div class="col">
      <div id="netstat" class="netstat">
        <p>In: <span id="netstatIn"></span></p>
        <p>Out: <span id="netstatOut"></span></p>
      </div>
      <div class="row">
        <div class="col">
          <div id="battery" class="battery"></div>
        </div>
        <div class="col">
          <div id="ipAddress" class="ip-address"></div>
        </div>
      </div>
    </div>
    <div class="col">
      <div id="clock" class="clock"></div>
    </div>
  </div>
  <div class="row">
    <div class="col">
      <table id="cpu" class="cpu">
        <tr>
          <td id="cpu1"></td>
          <td id="cpu2"></td>
          <td id="cpu3"></td>
        </tr>
      </table>
    </div>
    <div class="col">
      <table id="ram" class="ram">
        <tr>
          <td class="col-1"></td>
          <td class="col-2"></td>
          <td class="col-3"></td>
          <td class="col-4"></td>
        </tr>
      </table>
    </div>
    <div class="col">
      <table id="mem" class="mem">
        <tr class="row-1"></tr>
        <tr class="row-2"></tr>
        <tr class="row-3"></tr>
      </table>
    </div>
  </div>
"""

style: """
  bottom 10px
  left 10px
  padding 10px
  background rgba(0,0,0,.3)
  color: #fff
  font-family "Helvetica Neue"
  font-weight 200
  line-height 1
  -webkit-backdrop-filter blur(5px) contrast(100%) saturate(140%)
  border-radius 5px

  p
    margin 0
    padding 0

  .row
    display flex
    position relative
    margin 0 -10px

    & > .col
      padding 0 10px
      flex 1 0 auto

  .netstat
    margin-bottom 10px
    span
      font-weight 300

  .battery,
  .ip-address
    font-size 25px


  .clock
    text-align right
    font-size 75px
    font-weight 100
    line-height 1

  .cpu, .ram
    .amount
      font-weight 100
      font-size 45px
    .name
      display block
      text-overflow ellipsis

  .cpu
    td
      width 140px
  
  .ram
    td
      width 120px
  
  .mem
    width 130px

    td:last-of-type
      text-align right

"""

netstat: () ->
  command = 'sysmon.widget/scripts/netst'
  bytesToSize = (bytes) ->
    return "0 Byte" if parseInt(bytes) is 0
    k = 1024
    sizes = [
      "b/s"
      "kb/s"
      "mb/s"
      "gb/s"
      "gb/s"
      "pb/s"
      "eb/s"
      "zb/s"
      "yb/s"
    ]
    i = Math.floor(Math.log(bytes) / Math.log(k))
    (bytes / Math.pow(k, i)).toPrecision(3) + " " + sizes[i]

  @run command, (err, output) ->
    values = output.split(' ')
    document.getElementById('netstatIn').innerHTML = bytesToSize(values?[0])
    document.getElementById('netstatOut').innerHTML = bytesToSize(values?[1])
    return
  return

ipAddress: () ->
  self = this
  command = 'curl -s ipinfo.io/ip'
  el = document.getElementById('ipAddress')
  now = moment().format('x')

  renderIpAddress = () ->
    self.ipTime = now

    self.run command, (err, output) ->
      el.innerHTML = output
      return
    return

  if @ipTime
    if @ipTime <= now - 1200000
      renderIpAddress()
  else
    renderIpAddress()

battery: () ->
  self = this
  command = "pmset -g batt | grep -o '[0-9]*%'"
  el = document.getElementById('battery')
  now = moment().format('x')

  renderBattery = () ->
    self.batteryTime = now

    self.run command, (err, output) ->
      el.innerHTML = output
      return
    return

  if @batteryTime
    if @batteryTime <= now - 60000
      renderBattery()
  else
    renderBattery()

clock: () ->
  el = document.getElementById('clock')
  now = moment().format('dddd, MMMM D HH:mm')
  el.innerHTML = now
  return

cpu: () ->
  command = "ps axro \"pid, %cpu, ucomm\" | awk 'FNR>1' | head -n 3 | awk '{ printf \"%5.1f%%,%s,%s\\n\", $2, $3, $1}'"
  renderProcess = (cpu, name, id) -> """
      <span class="amount">#{cpu}</span>
      <span class="name">#{name}</span>
  """

  @run command, (err, output) ->
    processes = output.split('\n')

    for process, i in processes
      if !!process
        args = process.split(',')
        document.getElementById("cpu#{i + 1}").innerHTML = renderProcess(args...)
      # debugger

  return

ram: () ->
  command = "vm_stat | awk 'NR==2 {print \"Free,\"($3 / 256) / 1024} NR==3 {print \"Active,\"($3 / 256) / 1024} NR==4 {print \"Inactive,\"($3 / 256) / 1024} NR==7 {print \"Wired,\"($4 / 256) / 1024}'"
  el = document.getElementById('ram');

  renderProcess = (type, mem) -> """
    <span class="amount">#{Math.round(mem * 100) / 100}</span>
    <span class="name">#{type}</span>
  """

  @run command, (err, output) ->
    processes = output.split('\n')

    for process, i in processes
      if !!process
        args = process.split(',')
        el.querySelector(".col-#{i + 1}").innerHTML = renderProcess(args...)
  return

mem: () ->
  command = "ps axo \"rss,pid,ucomm\" | sort -nr | head -n3 | awk '{printf \"%8.0f,%s,%s\\n\", $1/1024, $3, $2}'"
  el = document.getElementById('mem')

  renderProcess = (mem, name) ->
    "<td>#{name}</td><td>#{mem}</td>"
  
  @run command, (err, output) ->
    processes = output.split('\n')
    for process, i in processes
      if !!process
        args = process.split(',')
        el.querySelector(".row-#{i+1}").innerHTML = renderProcess(args...)

  return

update: (output, domEl) ->

  @ipAddress()
  @netstat()
  @battery()
  @clock()
  @cpu()
  @ram()
  @mem()

