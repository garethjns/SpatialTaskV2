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
	- cd anaconda2
- Run Spyder (Python 2.7).
	- Open EyeTracker/Run.py.
- Open eye tracker software.
	- Turn on detection of both eyes.
	- Check pupil remote plugin is loaded
	- Find server port number under "Pupil Remote" menu.
- In run.py in Spyder:
	- Set port number for the pupil remote server (**port**).
	- Set address and port of TCP server (**TCPAddr**, **TCPPort**). Address should be Linux computers adress on network.
	- Set filename name for pickle file (use subject ID).

### 2. Set up Windows/MATLAB computer.
- Check cable 7 is plugged in at back of MOTU and cable 16 isn't.
- Turn on MOTU. Check that sampling rate indicator light on front settles on a value. If it doesn't, restart the Windows computer.
- Turn on both amplifiers.
- Set up touch screen.
	- Check it's plugged in.
	- Check it's virtually located to the bottom right of the main monitor.
- Open MATLAB 2013b.
	- Set working directory to C:\Gareth\SpatialTaskV2\MATLABTask\.
	- Open run.m in editor.
	- Set temporary subject ID
	- Set TCP address and port (**params.TCPAddr**, **params.TCPPort**) to match Python values.
	- On Python computer click run in run.py
	- On MALAB computer click run for run.m
	- Check touchscreen figure is aligned with monitor.
	- Check touchscreen figure calibration is correct (do the plotted dots align with the red dots?) If yes, enter 'y' and press enter.
		- If not:
			- Press crtl+c to stop the task.
			- dbquit if necessary.
			- Enable calibration in run.m's parameters.
			- Run run.m and re-calibrate.
	- Check the touchscreen's touch calibration is correct (does pressing on the screen click in the correct place?).
		- If not, double click eGalaxTouch icon in system tray and run monitor mapping.
		- Check touchscreen again, if calibration is still wrong, right click eGalaxTouch icon and run 4 point calibration. 
	- Enter chamber and check stimuli are working.
	- End test by pressing ctrl+c.
		- Type dbquit if in debug mode (indicated by K>> in command window).
	- Set parameters for task in run.m.
		- Set subject ID.
		- Set nBlocks to ~8 (1 block = 100 trials = ~250 S).
		- Set nBreaks to ~4.
		- preTraining to 1.
	


### 3. Introduce subject
- Give information sheet to subject to keep.
- Get subject to read and sign consent form.
- Explain eye tracker and basic task requirements. 
	- Keep gaze fixated on target during stimulation.
 	- Respond on touchscreen.
- Explain paradigm.
	- Pre-training phase (<5 mins).
		- AV stimuli will come from same location, subject has to indicate loaction with one press on touchscreen.
		- They can look around after stimuli before responding to orientate themselves, but should look back to red fixation LED after responding. This will be tracked.
		- Pre-training will continue until a threshold of localisation accuray is reached.
		- When finished, a message will appear on touch screen saying ready to begin main task.
		- When ready, press screen again to continue.
	- Actual task (~1 hour).
		- Subject needs to keep eyes on fixation LED while stimuli are playing (~1s).
		- Subject needs to respond on touchscreen twice:
			- First to indicate auditory location.
			- Second to indicate visual location.
- Outside booth:
	- Place eyetracker on subject and position eye cameras.
	- Unplug eye tracker.
- Move subject inside booth.
	- Plug eyetracker in inside booth and re-enable eye detection.
	- Check eye tracker camera pupil detection and adjust as required. Make sure detect pupil 0 and 1 are both enabled in pupil app.
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
		- If not defined, add and name as "Target" in Surface Tracker menu.
		- If not detected, check markers are being detected.
	- In the "Calibration" menu select "Natural Features Calibration".
	- Begin calibration by clicking (C) in the top left.
	- Ask subject to look at each world marker in turn and click to make these in the world.
	- Press C key to end calibration.
	- Check calibration accuracy.
	- Press (R) to begin recording video/gaze data.
- In Spyder:
	- Click in run.py and click green run button.
	- Check Python connects to ZMQ server and waits for MATLAB to connect to TCP server.

### 5. Start task
- On the Windows/MATLAB computer:
	- Run run.m.
		- Respond 'y' to calibration question.
- On Linux computer 
	- Check MATLAB has successfully connected to TCP server and Python has begun collecting data from eyetracker.

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
	- If there is data that needs to be saved, save the workspace manually (data is only automatically saved during each break, but not after every trial).
- When finished, untangle subject from cables and debrief.

### 7. Save data and shutdown
- On Linux computer:
	- In world view click (R) in world window to stop recording.
	- In Python click stop to stop collection.
		- This raises an exception, which will be caught.
		- Python will then automatically convert the saved pickle file to a .mat file.
	- Copy the directory containing the eyetracker video from /Home/Gareth/Recordings/ to external backup.
	- Copy the .p and .mat file for the subject from SpatialTaskV2/EyeTracker/ to external backup.
	- Close eye tracker software.
	- Unplug eye tracker.
- On Windows computer:
	- When the task completes, MATLAB saves its data automatically.
	- In ...\Data\[SubjectID]\[Datetime]\TeComplete.mat.
	- Copy ...\Data\[SubjectID]\ directory to external backup.
	- Close MATLAB editor (to prevent open files automatically re-opening next time someone starts MATLAB).
	- Close MATLAB.
	- Turn off amplifiers.
	- Turn off MOTU soundcard.

# To do
 - Add live functionality
	- Via TCP server?
	- Minor modification to MATLAB code also required to monitor and act on online eye data.

