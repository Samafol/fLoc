% Setup
Screen('Preference', 'SkipSyncTests', 1); % Disable for testing only
[window, rect] = Screen('OpenWindow', max(Screen('Screens')), [0 0 0]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
ifi = Screen('GetFlipInterval', window);
videoFolder = 'test_videos/';
videoFiles = dir(fullfile(videoFolder, '*.mp4'));
for i = 1:length(videoFiles)
    videoPath = fullfile(videoFolder, videoFiles(i).name);
    % Open movie
    [movie, ~, fps, duration, width, height] = Screen('OpenMovie', window, videoPath);
    Screen('PlayMovie', movie, 1); % Start playback
    tStart = GetSecs;
    while ~KbCheck && GetSecs - tStart < 2 % Max 2 seconds
        tex = Screen('GetMovieImage', window, movie);
        if tex <= 0
            break;
        end
        Screen('DrawTexture', window, tex);
        Screen('Flip', window);
        Screen('Close', tex);
    end
    Screen('PlayMovie', movie, 0); % Stop
    Screen('CloseMovie', movie);
end
sca; % Close all User/experimentaluser/Samuel/Toolboxes/fLoc/test-videos

User/experimentaluser/Samuel/Toolboxes/BCBLViennaSoft/Psychtoolbox-3/Psychtoolbox