function play_movie(file_path, stim_dur, window_ptr)
    % Load and play a movie for a fixed duration using Psychtoolbox

    [moviePtr, ~, ~, ~] = Screen('OpenMovie', window_ptr, file_path);
    Screen('PlayMovie', moviePtr, 1);  % Start playing

    startTime = GetSecs;
    tex = [];
    
    while (GetSecs - startTime) < stim_dur
        [tex, ~] = Screen('GetMovieImage', window_ptr, moviePtr);

        if tex <= 0
            break;  % End of video or error
        end

        Screen('DrawTexture', window_ptr, tex);
        Screen('Flip', window_ptr);
        Screen('Close', tex);
    end

    Screen('PlayMovie', moviePtr, 0);  % Stop movie
    Screen('CloseMovie', moviePtr);   % Release memory
end
