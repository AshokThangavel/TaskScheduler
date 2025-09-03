Class TaskScheduler.Web.Scheduler Extends %CSP.Page
{
ClassMethod OnPage() As %Status
{
	Set serverUrl=..GetServerUrl()
	&HTML<
	<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Task Scheduler</title>
  <link rel="stylesheet" href="https://uicdn.toast.com/tui-calendar/latest/tui-calendar.css" />
  <link rel="stylesheet" href="https://uicdn.toast.com/tui.date-picker/latest/tui-date-picker.css" />
  <link rel="stylesheet" href="https://uicdn.toast.com/tui.time-picker/latest/tui-time-picker.css" />
  <style>
    body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
    .header {
      background: #0078d4;
      color: white;
      padding: 10px;
      text-align: center;
      font-size: 1.2em;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 10px;
    }
    #calendar { height: calc(100vh - 80px); }
    .tui-full-calendar-weekday-grid-date { font-weight: bold; }

    .btn-group button {
      background: #0078d4;
      color: white;
      border: none;
      padding: 6px 12px;
      cursor: pointer;
      font-weight: bold;
      border-radius: 3px;
    }
    .btn-group button:hover {
      background: #005ea0;
    }
    #currentDateLabel {
      font-weight: bold;
      font-size: 1.2em;
      color: white;
      user-select: none;
      min-width: 150px;
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="header">Task Scheduler</div>
  <div class="header">
    <div class="btn-group">
      <button id="prevBtn">&lt; Prev</button>
      <button id="nextBtn">Next &gt;</button>
    </div>
    <div id="currentDateLabel">Loading...</div>
    <div class="btn-group" style="margin-left: 20px;">
      <button onclick="calendar.changeView('month')">Month</button>
      <button onclick="calendar.changeView('week')">Week</button>
      <button onclick="calendar.changeView('day')">Day</button>
    </div>
  </div>

  <div id="calendar"></div>

  <script src="https://uicdn.toast.com/tui.code-snippet/v1.5.2/tui-code-snippet.min.js"></script>
  <script src="https://uicdn.toast.com/tui.time-picker/latest/tui-time-picker.min.js"></script>
  <script src="https://uicdn.toast.com/tui.date-picker/latest/tui-date-picker.min.js"></script>
  <script src="https://uicdn.toast.com/tui-calendar/latest/tui-calendar.js"></script>
  <script language="javascript">

  	const SERVER_URL = "#(serverUrl)#";

    const Calendar = tui.Calendar;

    const calendar = new Calendar('#calendar', {
      defaultView: 'month',
      taskView: true,
      scheduleView: true,
      useCreationPopup: false,
      useDetailPopup: false,
      week: { showTimezoneCollapseButton: true },
      month: { visibleWeeksCount: 6 },
      template: {
        time(event) {
          const hour = event.start.getHours().toString().padStart(2, '0');
          const minute = event.start.getMinutes().toString().padStart(2, '0');
          return `<strong>${event.title}</strong> (${hour}:${minute})`;
        }
      }
    });

    // Fetch calendar events from API and load them into calendar
    async function loadSchedules() {
      try {
        // Replace this URL with your real API endpoint for fetching events
        //`http://localhost/irishealth2025com/TaskScheduler/task/${schedule.id}/status`
        const response = await fetch(`${SERVER_URL}/task`);
        if (!response.ok) throw new Error('Failed to fetch events');
        const data = await response.json();

        // Map API response to schedule format (simulate with fake data structure)
        const schedules = data.map(item => ({
		  id: item.id,
		  calendarId: item.calendarId,
		  title: item.title,
		  category: item.category,
		  isAllDay: item.isAllDay,
		  start: item.start.includes('T') ? item.start : item.start + 'T10:00:00',  // add time if missing
		  end: item.end ? item.end : (item.start.includes('T') ? item.start : item.start + 'T11:00:00'), // default 1-hour duration
		  status: item.status,
		  color: '#ffffff',
		  bgColor: item.status === 'suspended' ? '#808080' : '#3a87ad',
		  borderColor: item.status === 'suspended' ? '#808080' : '#3a87ad'
		}));


        calendar.clear(); // Clear old schedules
        calendar.createSchedules(schedules);

      } catch (err) {
        alert('Error loading schedules: ' + err.message);
      }
    }

    // Initial load
    loadSchedules();

    // Update the current date label
    function updateDateLabel() {
      const viewName = calendar.getViewName();
      const rangeStart = calendar.getDateRangeStart();
      const rangeEnd = calendar.getDateRangeEnd();
      const currentDate = calendar.getDate();

      let label = '';

      if (viewName === 'month') {
        const monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        const month = rangeEnd.getMonth();
        const year = rangeStart.getFullYear();
		const currentMonth = currentDate.getMonth();
		const currentYear = currentDate.getFullYear();
        label = `${monthNames[currentMonth]} ${year}`;
      } else if (viewName === 'week' || viewName === 'day') {
        const formatDate = (d) => `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
        label = `${formatDate(rangeStart)} – ${formatDate(rangeEnd)}`;
      }

      document.getElementById('currentDateLabel').textContent = label;
    }

    updateDateLabel();

    calendar.on('afterRenderSchedule', updateDateLabel);
    calendar.on('afterRender', updateDateLabel);
    calendar.on('changeView', () => {
      setTimeout(updateDateLabel, 50);
    });
    calendar.on('moveSchedule', updateDateLabel);
    calendar.on('clickMore', updateDateLabel);
    calendar.on('beforeCreateSchedule', updateDateLabel);

    // Navigation buttons
    document.getElementById('prevBtn').addEventListener('click', () => {
      calendar.prev();
      updateDateLabel();
    });

    document.getElementById('nextBtn').addEventListener('click', () => {
      calendar.next();
      updateDateLabel();
    });

    // Override the detail popup to add "Suspend/Activate" button
    calendar.on('clickSchedule', function(event) {
      const schedule = event.schedule;

      // Create popup container
      const detailPopup = document.createElement('div');
      detailPopup.style.position = 'fixed';
      detailPopup.style.top = '50%';
      detailPopup.style.left = '50%';
      detailPopup.style.transform = 'translate(-50%, -50%)';
      detailPopup.style.background = 'white';
      detailPopup.style.border = '1px solid #ccc';
      detailPopup.style.borderRadius = '8px';
      detailPopup.style.padding = '20px';
      detailPopup.style.zIndex = 10000;
      detailPopup.style.width = '300px';
      detailPopup.style.boxShadow = '0 2px 8px rgba(0,0,0,0.26)';

      // Determine if suspended or active
      const isSuspended = schedule.bgColor === '#808080' || schedule.title.toLowerCase().includes('suspended');

      detailPopup.innerHTML = `
        <h3>${schedule.title}</h3>
        <!--p><b>Start:</b> ${schedule.start.toLocaleString()}</p>
       	<p><b>End:</b> ${schedule.end.toLocaleString()}</p-->
        <button id="toggleStatusBtn">${isSuspended ? 'Activate' : 'Suspend'}</button>
        <button id="closeBtn" style="margin-left:10px;">Close</button>
      `;

     document.body.appendChild(detailPopup);

      // Button to toggle suspend/activate with HTTP call
      document.getElementById('toggleStatusBtn').onclick = () => {
        const btn = document.getElementById('toggleStatusBtn');
        btn.disabled = true;
        btn.textContent = isSuspended ? 'Activating...' : 'Suspending...';

        // API URL - replace with your real endpoint
        //const apiUrl = `https://jsonplaceholder.typicode.com/posts/${schedule.id}`;
        const apiUrl = `${SERVER_URL}/task/${schedule.id}/status`;

        fetch(apiUrl, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ status: isSuspended ? 'active' : 'suspended' })
        })
        .then(response => {
          if (!response.ok) throw new Error('Network response was not ok');
          return response.json();
        })
        .then(() => {
          // Update schedule in calendar UI
          calendar.updateSchedule(schedule.id, schedule.calendarId, {
            color: '#ffffff',
            bgColor: isSuspended ? '#3a87ad' : '#808080',
            borderColor: isSuspended ? '#3a87ad' : '#808080',
            title: isSuspended
              ? schedule.title.replace(/\s*\(Suspended\)$/i, '')  // Remove suspended tag if exists
              : schedule.title + ' (Suspended)'
          });

          alert(`Task "${schedule.title}" ${isSuspended ? 'activated' : 'suspended'} successfully.`);
          document.body.removeChild(detailPopup);
          loadSchedules();
        })
        .catch(err => {
          alert('Failed to update task status: ' + err.message);
          btn.disabled = false;
          btn.textContent = isSuspended ? 'Activate' : 'Suspend';
        });
      };

      // Close button logic
      document.getElementById('closeBtn').onclick = () => {
        document.body.removeChild(detailPopup);
      };
    });
  </script>
</body>
</html>

	>
	q 1
}

ClassMethod GetServerUrl()
{
	Set webapp="TaskScheduler"
	If $Data(^TaskScheduler($P($SYSTEM,":",2),"Server"),data) {
		Set url = data
	}
	Else {
		Set sc=##class(%RoutineMgr).GetWebServerPort(.Port,.Server,.URLPrefix,.URL)
		Set url = $P(URL,"//")_"//localhost:"_Port_"/"_$P($SYSTEM,":",2)_"/"_webapp
	}
	Quit url
}

}