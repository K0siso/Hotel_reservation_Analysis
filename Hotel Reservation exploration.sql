-- 0. View data
Select *
From hotelreservations;

-- 1. I WANT TO CREATE A COPY OF THE MAIN TABLE

-- 1.1 Copying the columns
Create Table reservationscopy
Like hotelreservations;

-- 1.2 Copying the rows
Insert reservationscopy
Select *
From hotelreservations;

Select *
From reservationscopy;

												-- A LITTLE DATA INTEGRITY CHECK

-- 2. I CHECK FOR DUPLICATE ROWS

Select Booking_ID, Count(*) Count
From reservationscopy
Group By Booking_ID
Having Count(*) > 1;	-- No duplicates.
						-- No Nulls.
						-- Data is standard.
									
													-- DATA EXPLORATION!
                                                    
-- CONTENTS.
-- 1. What factors influence the likelihood of a booking being canceled?
-- 2. What are the characteristics of bookings with special requests?
-- 3. How do market segments influence booking behaviors and outcomes?
-- 4. What are the trends in booking patterns over time?
-- 5. What are the financial implications of different booking characteristics?


-- 1. What factors influence the likelihood of a booking being canceled?

	-- 1.1 How does the lead time (number of days between booking and arrival) affect the cancellation rate?
	SELECT lead_time, Count(*) Count,
		Sum(Case When booking_status = 'Canceled' Then 1 Else 0 End) Cancellations,
		(Sum(Case When booking_status = 'Canceled' Then 1 Else 0 End)/Count(*)) Cancellation_rate
	FROM reservationscopy
	GROUP BY lead_time
	ORDER BY 1 Desc;	-- RESULT: A higher lead_time leads to a higher cancellation rate

	-- 1.2 Is there a correlation between the average price per room and booking cancellations?
    
		-- Average price per room for canceled and not canceled bookings:
		SELECT booking_status, AVG(avg_price_per_room) Avg_price
		FROM reservationscopy
		GROUP BY booking_status;	-- RESULT: On average, the price for canceled booking is higher than Not_canceled
		
		-- Check if the average price per room correlates with booking status:
		SELECT avg_price_per_room, count(*) AS Total_bookings,
			Sum(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) as Cancellations,
			(Sum(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END))/COUNT(*) cancellation_rate
		FROM reservationscopy
		GROUP BY avg_price_per_room
		ORDER BY 1 Desc;			-- RESULT: Found no correlation between room price and cancellations

	-- 1.3 Do the number of special requests have any impact on the cancellation rate?
	SELECT no_of_special_requests, COUNT(*) AS total_bookings,
		SUM(Case When booking_status = 'Canceled' Then 1 ELSE 0 END) cancellations,
		(SUM(CASE WHEN booking_status = 'Canceled' Then 1 ELSE 0 END) * 1.0 / COUNT(*)) cancellation_rate
	FROM reservationscopy
	GROUP BY no_of_special_requests
	ORDER BY no_of_special_requests;	-- RESULT: The cancellation rate drops as the no_of_special_requests increases

	-- 1.4 How do market segment types compare in terms of cancellation rates?
	SELECT market_segment_type, COUNT(*) total_bookings,
		SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END) as cancellations ,
		(SUM(CASE WHEN booking_status = 'Canceled' THEN 1 ELSE 0 END)/COUNT(*)) as cancellation_rate
	FROM reservationscopy
	GROUP BY market_segment_type;	-- RESULT: The online segment has a cancellation rate of 42.5% while the offline is ~ 4%


-- 2. What are the characteristics of bookings with special requests?

	-- 2.1 Are bookings with special requests more likely to be made by repeated guests?
	SELECT no_of_special_requests, COUNT(*) Total_bookings,
		Sum(CASE WHEN repeated_guest = 1 THEN 1 ELSE 0 END) as repeated_guests,
		(SUM(CASE WHEN repeated_guest = 1 THEN 1 ELSE 0 END))/COUNT(*) as repeated_guest_rate
	FROM reservationscopy
	GROUP BY no_of_special_requests
	ORDER BY 1;						-- RESULT: Yes, bookings with special requests are more likely to be made by repeated guests

	-- 2.2 What is the average lead time for bookings with special requests compared to those without?
	SELECT no_of_special_requests, AVG(lead_time)
	FROM reservationscopy
	GROUP BY no_of_special_requests;	-- RESULT: The average lead time is greater when there is 0 special requests

	-- 2.3 Do special requests affect the average price per room?
	SELECT no_of_special_requests, AVG(avg_price_per_room)
	FROM reservationscopy
	GROUP BY no_of_special_requests;		-- RESULT: Yes. The higher the number of special requests, the higher the average price per room

	-- 2.4 How does the number of special requests correlate with the number of weekend and week nights booked?
	SELECT no_of_special_requests, AVG(no_of_weekend_nights) Avg_weekend_nights, AVG(no_of_week_nights) Avg_week_nights
	FROM reservationscopy
	GROUP BY no_of_special_requests
	ORDER BY 1;						-- RESULT: The average number of weekend and week nights booked increases with the no_of_special_request


-- 3. How do market segments influence booking behaviors and outcomes?

	-- 3.1 What is the average lead time for online bookings compared to offline bookings?
	SELECT market_segment_type, AVG(lead_time) as Avg_lead_time
	FROM reservationscopy
	GROUP BY market_segment_type;		-- RESULT: The average lead time for online and offline bookings is roughly the same. ~ 89.5 and 90.8

	-- 3.2 How does the average price per room differ between online and offline bookings?
	SELECT market_segment_type, AVG(avg_price_per_room) as Avg_price
	FROM reservationscopy
	GROUP BY market_segment_type;		-- RESULT: The average price per room for offline is lesser ($88.4) than online ($111)


-- 4. What are the trends in booking patterns over time?

	-- 4.1 How do booking patterns vary by arrival month and year?
	SELECT arrival_year, arrival_month, COUNT(*) as Total_bookings
	FROM reservationscopy
	GROUP BY arrival_month, arrival_year
	ORDER BY 1,2;				-- RESULT: There's a general increase across the years (2017 & 2018). A dip occurs in November.

	-- 4.2 Are there any noticeable trends in the number of adults and children per booking over time?
	SELECT arrival_year, arrival_month, AVG(no_of_adults) as Avg_adult, AVG(no_of_children) as Avg_children
    FROM reservationscopy
    GROUP BY arrival_year, arrival_month
    ORDER BY 1;			-- RESULT: The average no of adults/children per booking appears to be approx. 2 and 0 respectively, across the months and years
    
	-- 4.3 What is the trend in average price per room over different months and years?
    SELECT arrival_year, arrival_month, AVG(avg_price_per_room) as Avg_room_price
    FROM reservationscopy
    GROUP BY arrival_year, arrival_month
    ORDER BY 1;					-- RESULT: The average price picks at September and declines from October through December

	-- 4.4 How do the types of meal plans selected change over time?
    SELECT arrival_year, arrival_month, type_of_meal_plan, COUNT(*) as meal_plan_count
    FROM reservationscopy
    GROUP BY type_of_meal_plan, arrival_year, arrival_month
    ORDER BY 1,2;		-- RESULT: The highest recorded meal plan over time is meal plan 1. A significant number of people did 'not select' in 2018
    
    
-- 5. What are the financial implications of different booking characteristics?
    
    -- 5.1 How does the average price per room impact the overall revenue from different market segments?
    SELECT market_segment_type, SUM(avg_price_per_room) as Total_revenue, AVG(avg_price_per_room) as Avg_revenue_per_booking, COUNT(*) as Total_bookings
    FROM reservationscopy
    GROUP BY market_segment_type
    ORDER BY 2 DESC;		-- RESULT: Generally, Total revenue decreased as average room price decreases. Online segment generates highest revenue
    
    -- 5.2 What is the revenue contribution from repeated guests versus non-repeated guests?
    SELECT repeated_guest, SUM(avg_price_per_room) as Total_revenue, AVG(avg_price_per_room) as Avg_revenue_per_booking, COUNT(*) as Total_bookings
    FROM reservationscopy
    GROUP BY repeated_guest;		-- RESULT: repeated guests = $14,658. Non-repeated guests = $858,082
    
    -- 5.3 How do special requests influence the revenue from bookings?
    SELECT no_of_special_requests, SUM(avg_price_per_room) as Total_revenue, AVG(avg_price_per_room) as Avg_revenue_per_booking, COUNT(*) as Total_bookings
    FROM reservationscopy
    GROUP BY no_of_special_requests
    ORDER BY 2 DESC;		-- RESULT: The bookings with less number of special request makes the highest total booking in order, and brought the highest revenue
    
    	-- 5.4 What is the total revenue generated from bookings based on their status (canceled vs. not canceled)?
    SELECT booking_status, SUM(avg_price_per_room) as Total_revenue, AVG(avg_price_per_room) as Avg_revenue_per_booking, COUNT(*) as Total_bookings
    FROM reservationscopy
    GROUP BY booking_status;	-- RESULT: Canceled = $300,260. Not canceled = $572,479
    
    -- END.