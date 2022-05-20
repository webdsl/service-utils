module daterange

imports src/utils

entity DateRange {
	start: Date
	end: Date
	length: Int := daysBetween(start, end)
	cached function dates(): [Date]{
		return dateRange(start, end);
	}
}