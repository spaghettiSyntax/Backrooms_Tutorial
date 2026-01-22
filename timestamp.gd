extends Label


# Start Date Settings (Editable in Inspector)
@export var year: int = 1989
@export var month: int = 12
@export var day: int = 31
@export var hour: int = 23
@export var minute: int = 59
@export var second: int = 55


# Internal time
var time_accumulator: float = 0.0


# Days in each month (Index 0 is January)
var days_in_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


func _ready():
	# Safety Check: Verify the inspector input before starting
	if not _is_input_valid():
		push_error("INVALID DATE ENTERED: " + str(day) + "/" + str(month) \
					+ " /" + str(year))
		print("Resetting Clock to Default: Dec 31st, 1989")
		
		# Default back to safe values
		year = 1989
		month = 12
		day = 31
		hour = 23
		minute = 59
		second = 55
		
	_update_label()
	
	
func _process(delta):
	time_accumulator += delta
	
	# Every 1 real-time second, tick the clock
	if time_accumulator >= 1.0:
		time_accumulator -= 1.0
		_tick_second()
		
	
func _tick_second():
	second += 1
	
	# Handle Time Rollovers
	if second >= 60:
		second = 0
		minute += 1
		
	if minute >= 60:
		minute = 0
		hour += 1
		
	if hour >= 24:
		hour = 0
		_tick_day()
		
	_update_label()
	
	
func _tick_day():
	day += 1
	
	# Check for Leap Year (Every 4 years, unless div by 100 but not 400)
	var is_leap = (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
	var max_days = days_in_months[month - 1] # Month is 1 - based index
	
	if month == 2 and is_leap:
		max_days = 29
		
	if day > max_days:
		day = 1
		month += 1
		
	if month > 12:
		month = 1
		year += 1
	
	
func _update_label():
	# Format: DD MM YYYY \n HH:MM:SS
	text = "%02d %02d %d\n%02d:%02d:%02d\n" % [day, month, year, \
											 hour, minute, second]
											

func _is_input_valid() -> bool:
	# Check simple ranges
	if year < 1900 or year > 2100: return false
	if month < 1 or month > 12: return false
	if hour < 0 or hour > 23: return false
	if minute < 0 or minute > 59: return false
	if second < 0 or second > 59: return false
	
	# Check for specific days in month
	var max_days = days_in_months[month - 1]
	var is_leap = (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
	
	if month == 2 and is_leap:
		max_days = 29
		
	if day < 1 or day > max_days: return false
	
	return true
