# SpatialTaskV2 - draft

# Requirements
- Eye tracker computer:
	- Linux (Ubuntu 16.10)
	- [Pupil labs hardware and software](https://github.com/pupil-labs/pupil) ([v0.8.7](https://github.com/pupil-labs/pupil/releases/tag/v0.8.7)).
	- Python 2.7
- Task computer
	- Windows 7
	- MATLAB 2013b
	- [PyscheToolBox-3](http://psychtoolbox.org/)
	- ASIO Soundcard 

# Instructions

1. Set up Linux/Python computer and eye tracker
2. Set up Windows/MATLAB computer and task
3. Introduce subject
4. Calibrate and start eye tracker recording
5. Start task
6. Monitor task
7. Save data and Shutdown

<br>

### 1. Set up Linux/Python computer
- Open terminal.
- Run Spyder (Python 2.7).
	- Set working directory - recorded files will be saved here.
	- Open collectAndStampSurface.py.
- Open eye tracker software.
	- Turn on detection of both eyes.
	- Find server port number under "Pupil Remote" menu.
- In collectAndStampSurface.py in Spyder:
	- Set port number.
	- Set filename name for pickle file (use subject ID).

### 2. Set up Windows/MATLAB computer.
- Check cable 7 is plugged in at back of MOTU and cable 16 isn't.
- Turn on MOTU.
- Turn on both amplifiers.
- Set up touch screen.
	- Check it's plugged in.
	- Check it's virtually located to the bottom right of the main monitor.
- Open MATLAB.
	- Set working directory to this repository (C:\SpatialTaskV2\).
	- Open run.m in editor.
	- Set temporary subject ID and click run.
	- Check touchscreen figure is aligned with monitor.
	- Check touchscreen figure calibration is correct (do the plotted dots align with the red dots?) If yes, enter 'y' and press enter.
		- If not:
			- Press crtl+c to stop the task.
			- dbquit if necessary.
			- Enable calibration in run.m's parameters.
			- Run run.m and re-calibrate.
	- Check the touchscreens touch calibration is correct (does pressing on the screen click in the correct place?).
		- If not, right click [] on taskbar and run screen calibration. 
	- Enter chamber and check stimuli are working.
	- End test by pressing ctrl+c.
		- Type dbquit if in debug mode (indicated by K>> in command window).
	- Set parameters for task in run.m.
		- Set subject ID.
		- Set nBlocks to ~8 (1 block = 100 trials = ~250 S).
		- Set nBreaks to ~4.


### 3. Introduce subject
- Give information sheet to subject to keep.
- Get subject to read and sign consent form.
- Explain eye tracker and basic task requirements. 
	- Keep gaze fixated on target.
 	- Respond on touchscreen.
- Explain paradigm.
	- Pre-training phase (<5 mins).
	- Actual task (~1 hour).
- Outside booth:
	- Place eyetracker on subject and position eye cameras.
- Move subject inside booth.
	- Check eye tracker camera pupil detection and adjust as required.
	- Check world camera alignment.
	- Show subject expected fixation LED location.
	- Raise/lower chair so subject's head is vertically level with fixation LED.
	- Hand subject touchscreen. Make sure the cables don't drop out.


### 4. Calibrate and start eye tracker recording.
- On the Linux computer select the eye tracker software. If it's already running, ***don't** click the taskbar shortcut again*.
- In the world window:
	- Ensure the target surface markers are detected (green boxes around markers). 
		- If not, adjust "min_marker_perimeter" in "Surface Tracker" menu.
	- Ensure surface is defined, detected, and named "Target".
		- If not defined, add and name in "Surface Tracker" menu.
		- If not detected, check markers are being detected.
	- In the "Calibration" menu select "Natural Features Calibration".
	- Begin calibration by clicking (C) in the top left.
	- Ask subject to look at each world marker in turn and click to make these in the world.
	- Click (C) again to end calibration.
	- Check calibration accuracy.
	- Press (R) to begin recording video/gaze data.
- In Spyder:
	- Click in collectAndStampSurface.py and press ctrl+enter to run.
	- Check Python connects to ZMQ server and begins collecting data when surface is detected in world camera.

### 5. Start task
- On the Windows/MATLAB computer:
	- Run run.m.
		- Respond 'y' to calibration question.

### 6. Monitor task
- Tell subject to press touchscreen when ready to start (twice).
- Monitor pre-training.
	- Check subject is looking at fixation light when trials start.
	- Subject should pass quickly, if not, re-explain task!
- Monitor task.
	- Check subject is returning gaze to fixation LED/Target surface before each trial starts.
	- Hope Windows computer doesn't bluescreen randomly.
- MATLAB task can be stopped with ctrl+c.
	- If task is stopped, or crashes for another reason, MATLAB enters debug mode.
	- If there is data that needs to be saved, save the workspace manually (data is only automatically saved during each break, not after every trial).
- When finished, untangle subject from cables and debrief.

### 7. Save data and shutdown
- On Windows computer:
	- When the task completes, MATLAB saves its data automatically.
	- In ...\[SubjectID]\[Datetime]\TeComplete.mat.
	- Copy ...\[SubjectID]\ directory to external backup.
	- Close MATLAB editor (to prevent open files automatically re-opening next time someone starts MATLAB).
	- Close MATLAB.
	- Turn off amplifiers.
	- Turn off MOTU soundcard.
- On Linux computer:
	- In world view click (R) in world window to stop recording.
	- In Python click stop to stop collection.
		- This raises an exception, which will be caught.
		- Python will then automatically convert the saved pickle file to a .mat file.
	- Copy the directory containing the eyetracker video from [] to external backup.
	- Copy the .p and .mat file for the subject from [] to external backup.
	- Close eye tracker software.
	- Unplug eye tracker.

# To do
 - Add live functionality
	- Need to either connect to ZMQ server (Linux PC) directly from MATLAB (Windows PC) via crossover cable. Or connect to Python (Linux PC) from MATLAB (Windows PC). If this isn't possible, Python (Linux) -> MATLAB (Linux) -> MATLAB (Windows) ???
	- Minor modification to MATLAB code also required to monitor and act on online eye data.

