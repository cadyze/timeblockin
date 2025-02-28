'use client';
import React, { useState } from "react";
import { Calendar, momentLocalizer, Event, Views } from "react-big-calendar";
import moment from "moment";
import "react-big-calendar/lib/css/react-big-calendar.css";

const localizer = momentLocalizer(moment);

// Define event type
interface CalendarEvent extends Event {
  id: number;
  title: string;
  start: Date;
  end: Date;
  allDay?: boolean;
}

const MyCalendar: React.FC = () => {
  // Sample events
  const [events] = useState<CalendarEvent[]>([
    {
      id: 1,
      title: "Team Meeting",
      start: new Date(2025, 1, 28, 10, 0), // Year, Month (0-based), Day, Hour, Minute
      end: new Date(2025, 1, 28, 11, 0),
      allDay: false,
    },
    {
      id: 2,
      title: "Lunch Break",
      start: new Date(2025, 1, 29, 12, 0),
      end: new Date(2025, 1, 29, 13, 0),
      allDay: false,
    },
  ]);

  return (
    <div style={{ height: "600px" }}>
      <Calendar
        localizer={localizer}
        events={events}
        startAccessor="start"
        endAccessor="end"
        style={{ height: 600 }}
        views={["month", "week", "day", "agenda"]}
        defaultView={Views.MONTH}
      />
    </div>
  );
};

export default MyCalendar;
