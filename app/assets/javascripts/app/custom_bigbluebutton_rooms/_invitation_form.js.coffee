usersSelector = '#invite_users'
searchUsersUrl = '/users/select?limit=7'
startsOnSelector = '#invite_starts_on'
endsOnSelector = '#invite_ends_on'
durationSelector = '#invite_duration .duration'
defaultDuration = 60*60 # 1h in secs
previousDuration = null

mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.Invitation

  @bind: ->
    bindUsers()
    bindDates()

  @unbind: ->
    # TODO: can it be done?

bindUsers = ->
  $(usersSelector).select2
    minimumInputLength: 1
    width: 'resolve'
    multiple: true
    formatSearching: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.searching')
    formatInputTooShort: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.hint')
    formatNoMatches: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.no_results')
    tags: true
    tokenSeparators: [",", ";"]
    createSearchChoice: (term, data) ->
      if mconf.Base.validateEmail(term)
        { id: term, text: term }
    formatSelection: (object, container) ->
      if object.name?
        object.name
      else
        object.text
    ajax:
      url: searchUsersUrl
      dataType: "json"
      data: (term, page) ->
        q: term # search term
      results: (data, page) -> # parse the results into the format expected by Select2.
        results: data

# TODO: make this a method in the class, and the inputs class variables
bindDates = ->

  # TODO: find these inputs automatically by putting attrs on them
  inputStartDate = $(startsOnSelector)[0]
  inputStartTime = $(".invite_starts_on_time")[0]
  inputEndDate = $(endsOnSelector)[0]
  inputEndTime = $(".invite_ends_on_time")[0]

  startInput = new mconf.DateTimeInput(inputStartDate, inputStartTime)
  endInput = new mconf.DateTimeInput(inputEndDate, inputEndTime)

  initializeDates(startInput, endInput)

  startInput.on "change", ->
    adjustEndOnStartChange(startInput, endInput)
    endInput.setMinDate(startInput.getDate())
    storeDuration(startInput, endInput)
    updateDuration()

  endInput.on "change", ->
    adjustEndOnEndChange(startInput, endInput)
    storeDuration(startInput, endInput)
    updateDuration()

# Initialize the dates with default values
initializeDates = (startInput, endInput) ->
  start = new Date()

  # start at the current time
  startInput.setDate(start)

  # ends at the current time plus a standard duration
  end = addDuration(start, defaultDuration)
  endInput.setDate(end)

  # the end can never be before the start
  endInput.setMinDate(startInput.getDate())

  # store the initial duration and update the label
  storeDuration(startInput, endInput)
  updateDuration()

# Stores the current duration in seconds
storeDuration = (startInput, endInput) ->
  previousDuration = (endInput.getDate() - startInput.getDate()) / 1000 # in secs

# Updates the text in the label with the duration using the start and end dates
# set in the inputs.
updateDuration = ->
  duration = previousDuration
  duration = ignoreSeconds(new Date(duration * 1000)).getTime()
  if _.isFinite(duration)
    duration = moment.duration(Math.abs(duration))
    text = "#{Math.floor(duration.as("hours"))}h"
    text = text + " #{duration.minutes()}m" unless duration.minutes() is 0
    $(durationSelector).text("#{text}")
    $(durationSelector).removeClass("error")
  else
    $(durationSelector).text("?")

# Adjusts the end date according to the start date when the start date is changed
# by the user. The end can never be lower than the start date, and will also sometimes
# be automatically set to maintain the duration previously specified.
adjustEndOnStartChange = (startInput, endInput) ->

  # setting a start to be after the end, makes the end jump forward and
  # keeps the previous duration (if any)
  if endInput.getDate() < startInput.getDate()
    if previousDuration?
      endInput.setDate(addDuration(startInput.getDate(), previousDuration))
    else
      endInput.setDate(addDuration(startInput.getDate(), defaultDuration))

  # always keep the previous duration if it is set
  else if previousDuration?
    endInput.setDate(addDuration(startInput.getDate(), previousDuration))

  # no previous duration, use the default
  else
    endInput.setDate(addDuration(startInput.getDate(), defaultDuration))

# Adjusts the end date according when the end date input is changed by the user.
adjustEndOnEndChange = (startInput, endInput) ->

  # don't ever let the end be before the start
  if endInput.getDate() < startInput.getDate()
    endInput.setDate(startInput.getDate())


# Adds 'duration' seconds to a Date object 'date'.
addDuration = (date, duration) ->
  moment(date).add(duration, 'seconds').toDate()

# Nullifies the seconds and milliseconds on a Date object
ignoreSeconds = (date) ->
  time = Math.floor(date.getTime() / 60000) * 60000
  new Date(time)

# Nullifies the minutes, seconds and milliseconds on a Date object
ignoreMinutes = (date) ->
  time = Math.floor(date.getTime() / 3600000) * 3600000
  new Date(time)

getEndDateTimePicker = ->
  $(endsOnSelector).data("DateTimePicker")

getStartDateTimePicker = ->
  $(startsOnSelector).data("DateTimePicker")