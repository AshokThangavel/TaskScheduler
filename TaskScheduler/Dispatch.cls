Class TaskScheduler.Dispatch Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/task" Method="GET" Cors="true" Call="GetTaskDetails"/>
	<Route Url="/task/:id/status" Method="PUT" Cors="true" Call="SuspendOrActiveTask"/>
	</Routes>
}

ClassMethod GetTaskDetails(StartDate As %String = 90)
{
	Set result = ##class(%SYS.Task).UpcomingTasksFilterFunc(,"2029-09-06",,,10000)
	Set tasks = []
	While result.%Next() {
		Set task = {"id":(result.ID),
					"calendarId":(result.ID),
					"title":(result.Name),
					"category": "time",
					"isAllDay": false,
					"start":($TR($ZDT(result.Date_","_result.Time,3,7),"Z")),
					"end":($TR($ZDT(result.Date_","_result.Time,3,7),"Z")),
					"status":($Select(result.Suspended:"suspended",1:"active"))
				}
		Do tasks.%Push(task)
	}
	Do ##class(%REST.Impl).%WriteResponse(tasks)
	Return $$$OK
}

ClassMethod SuspendOrActiveTask(TaskId As %String)
{
	Set payload = {}.%FromJSON(%request.Content)
	If payload."status"="suspended" {
		Set status = 2
	}
	else {
		Set status = 0
	}
	&SQL(UPDATE %SYS.TASK SET Suspended=:status WHERE Id=:TaskId)
	Do ##class(%REST.Impl).%WriteResponse( {"status": "ok","id":(TaskId)})
	Return $$$OK
}
ClassMethod OnHandleCorsRequest(pUrl) As %Status
{
	#dim %request As %CSP.Request
	#dim %response As %CSP.Response

	Set tOrigin = $Get(%request.CgiEnvs("HTTP_ORIGIN"))
    Do %response.SetHeader("Access-Control-Allow-Origin",tOrigin)
    Do %response.SetHeader("Access-Control-Allow-Methods","GET,POST,PUT,OPTIONS")
    ;Do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Credentials","true")
    Set tHeaders=$Get(%request.CgiEnvs("HTTP_ACCESS_CONTROL_REQUEST_HEADERS"))
    Do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Headers",tHeaders)
    Quit $$$OK
}

}
