% Always close any open screens first

Screen('CloseAll');

Screen('Preference', 'SkipSyncTests', 1); % Only for development

 

% Open a window on the main screen

screenNumber = max(Screen('Screens'));

[window, rect] = Screen('OpenWindow', screenNumber, [0 0 0]);

  q5

% Confirm the window is valid

disp(['Opened window with pointer: ', num2str(window)]);

 

% Set blend function (optional)

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

 

% Get flip interval (optional but good for timing)

ifi = Screen('GetFlipInterval', window);

 

% Full path to video

%videoPath = fullfile(pwd, 'test-videos', 'processed_videos-001.mp4');

videoPath = '/Users/experimentaluser/Samuel/Toolboxes/fLoc/test-videos/processed_videos-001.mp4';

disp(['Checking for video file at: ', videoPath]);

 

% Check if video file exists

if ~exist(videoPath, 'file')

    error('Video file not found: %s', videoPath);

end

 

% Open and play movie

[movie, ~, fps, duration, width, height] = Screen('OpenMovie', window, videoPath);

Screen('PlayMovie', movie, 1);

 

% Show video for 2 seconds or until key press

tStart = GetSecs;

while ~KbCheck && GetSecs - tStart < 2

    tex = Screen('GetMovieImage', window, movie);

    if tex <= 0

        break;

    end

    Screen('DrawTexture', window, tex);

    Screen('Flip', window);

    Screen('Close', tex);

end

 

% Stop and clean up

Screen('PlayMovie', movie, 0);

Screen('CloseMovie', movie);

Screen('CloseAll'); % Close window

	
