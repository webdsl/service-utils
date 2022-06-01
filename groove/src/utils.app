module utils

// returns the number of days inbetween the two dates, inclusive
// so daysBetween(today, today) = 1, daysBetween(today, tomorrow) = 2,...
// if end > start, then it will return 0
function daysBetween(start: Date, end: Date): Int {
	if(start.after(end)) {
		return 0;
	}
	if(start.getYear() == end.getYear()){
		return end.getDayOfYear() - start.getDayOfYear() + 1;
	} else { // if(end.getYear() > start.getYear()) { // is implied by not greater and not equal
		var y: Int := end.getYear() - 1;
		return end.getDayOfYear() + daysBetween(start, Date("31/12/~y"));
	}
}

// range of dates, inclusive end date
function dateRange(start: Date, end: Date): [Date] {
	var dates : [Date] := [start];
	for(i: Int from 1 to daysBetween(start, end)){
		dates.add(start.addDays(i));
	}
	return dates;
}

//test dateHelpersTest {
//	var t : Date := today();
//	var n : Int := 420; // something >365 to test year boundary as well
//	for(i:Int from 0 to n){
//		// should be end not start i guess
//		var start : Date := t.addDays(i);
//		assert(daysBetween(t, start) == i+1, "daysBetween");
//		assert(daysBetween(start, t) == i+1, "daysBetween");
//		var range : [Date] := dateRange(t, start);
//		assert(range.get(0) == t);
//		assert(range.get(range.length - 1) == start);
//	}
//}