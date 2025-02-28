import MyCalendar from "@/components/Calendar/Calendar";
// import '../components/Calendar/calendar.css';

export default function Home() {
  return (
    <div className="flex justify-center items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="justify-center items-center sm:items-start w-1/2">
        <div className="justify-center items-center h-3/4">
          <MyCalendar/>
        </div>
      </main>
    </div>
  );
}
