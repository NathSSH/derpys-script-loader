/* DERPY'S SCRIPT LOADER: MAIN
	
	this is the entry point of the mod (DllMain)
	it's responsible for patching the game and controlling dsl.c
	
*/

#include <dsl/dsl.h>
#include <string.h>
#ifndef _WIN32
#include <time.h>
#include <pthread.h>
#endif

//#define W32_CUT_SLEEP 10 // if defined, Sleep time will be reduced by this time to account for the poor accuracy of Windows timing

// DSL CONTROLLER
dsl_state* openDsl(void *game,void *d3d9,void *data);
void closeDsl(dsl_state*);
void updateDslAfterScripts(dsl_state*);

// GLOBAL STATE
dsl_state *g_dsl = NULL;

// INPUT (WINDOWS)
#ifdef _WIN32
struct console_input{
	HANDLE thread;
	char *buffer;
};
static DWORD getInput(struct console_input *ci){
	size_t index,count;
	char *grow,c;
	
	// TODO: consider using WaitForSingleObject instead of threads?
	
	index = count = 0;
	while((c = getchar()) != EOF && c != '\r' && c != '\n'){
		if(++index >= count){
			count = count ? count * 2 : 256;
			grow = realloc(ci->buffer,count);
			if(!grow){
				if(ci->buffer)
					free(ci->buffer);
				ci->buffer = NULL;
				return 0;
			}
			ci->buffer = grow;
		}
		ci->buffer[index-1] = c;
	}
	if(ci->buffer)
		ci->buffer[index] = 0;
	return 0;
}
static int updateInput(struct console_input *ci){
	DWORD status;
	
	if(!ci->thread)
		ci->thread = CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)&getInput,ci,0,NULL);
	if(!ci->thread || !GetExitCodeThread(ci->thread,&status) || status)
		return 0;
	CloseHandle(ci->thread);
	ci->thread = NULL;
	return ci->buffer != NULL;
}
#endif

// INPUT (UNIX)
#ifndef _WIN32
struct console_input{
	int unsupported_for_now;
};
#endif

// TIMING
struct server_timer{
	DWORD started;
	DWORD ticks;
	DWORD hz;
};
#ifndef _WIN32
static DWORD getUnixClock(){
	struct timespec ts;
	
	if(clock_gettime(CLOCK_MONOTONIC,&ts))
		return 0; // TODO: add an actual error report
	return (DWORD)ts.tv_sec * 1000 + (DWORD)ts.tv_nsec / 1000000;
}
#endif
static void startServerTimer(struct server_timer *st,dsl_state *dsl){
	DWORD hz;
	
	hz = getConfigInteger(dsl->config,"server_hz");
	st->hz = hz ? hz : NET_DEFAULT_HZ;
	st->ticks = 0;
	#ifdef _WIN32
	st->started = GetTickCount();
	#else
	st->started = getUnixClock();
	#endif
}
static int updateServerTimer(struct server_timer *st,dsl_state *dsl){
	DWORD timer;
	DWORD goal;
	
	#ifdef _WIN32
	timer = GetTickCount() - st->started;
	#else
	timer = getUnixClock() - st->started;
	#endif
	goal = (timer * st->hz) / 1000 + 1;
	dsl->frame_time = timer - dsl->last_frame;
	dsl->last_frame = timer;
	if(goal == st->ticks){
		goal *= 1000;
		timer = goal / st->hz - timer;
		if(goal % st->hz)
			timer++;
		#ifdef _WIN32
		#ifdef W32_CUT_SLEEP
		if(timer > W32_CUT_SLEEP)
			Sleep(timer - W32_CUT_SLEEP);
		else
			Sleep(0);
		#else
		Sleep(timer);
		#endif
		#else
		if(timer >= 1000)
			sleep(timer);
		else
			usleep(timer*1000);
		#endif
		return 0;
	}
	if(timer = goal - st->ticks - 1)
		printConsoleWarning(dsl->console,"missed %u ticks",timer);
	if(goal < st->ticks){
		dsl->t_wrapped++;
		printConsoleWarning(dsl->console,"The server has been running for over %u days, consider restarting soon.",49*dsl->t_wrapped);
	}
	st->ticks = goal;
	return 1;
}

// MAIN
#ifdef _WIN32
static void setupTitle(){
	char buffer[32];
	
	sprintf(buffer,"derpy's script server %d",DSL_VERSION);
	SetConsoleTitle(buffer);
}
#endif
int main(int argc,char **argv){
	struct console_input ci;
	struct server_timer st;
	dsl_state *dsl;
	
	#ifdef _WIN32
	setupTitle();
	#endif
	dsl = openDsl(NULL,NULL,NULL);
	if(!dsl){
		printf("\r "); // remove the >
		#ifdef DSL_SYSTEM_PAUSE
		system(DSL_SYSTEM_PAUSE);
		#endif
		return 1;
	}
	g_dsl = dsl;
	memset(&ci,0,sizeof(struct console_input));
	startServerTimer(&st,dsl);
	for(;;)
		if(updateServerTimer(&st,dsl)){
			#ifdef _WIN32
			if(updateInput(&ci)){
				printf("> "); // just in case no console output replaces it
				if(*ci.buffer && !processScriptCommandLine(dsl->cmdlist,ci.buffer))
					printConsoleError(dsl->console,"command does not exist");
			}
			#endif
			updateNetworking(dsl,dsl->network);
			updateDslAfterScripts(dsl);
			updateNetworking2(dsl,dsl->network);
		}
	return 0;
}