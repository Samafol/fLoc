function draw_fixation(windowPtr, center, color, isGreenDot)
% Draws fixation marker in the center of the window.
% If isGreenDot is true, draws a green dot (for oddball video trials).
% Otherwise, draws a cross (standard fixation).
% Usage:
%   draw_fixation(windowPtr, center, color); % cross
%   draw_fixation(windowPtr, center, color, true); % green dot
% Written by KGS Lab, edited by AS 8/2014, updated for oddball dot

if nargin < 4
    isGreenDot = false;
end
center_x = center(1);
center_y = center(2);

if isGreenDot
    dotRadius = 8; % adjust as needed
    green = [0 255 0];
    Screen('FillOval', windowPtr, green, [center_x-dotRadius, center_y-dotRadius, center_x+dotRadius, center_y+dotRadius]);
else
    % draw horizontal bar
    Screen('FillRect', windowPtr, color, [center_x - 3 center_y - 2 center_x + 3 center_y + 2]);
    % draw vertical bar
    Screen('FillRect', windowPtr, color, [center_x - 2 center_y - 3 center_x + 2 center_y + 3]);
end

end



%{
function draw_fixation(windowPtr, center, color)
% Draws round fixation marker in the center of the window by superimposing
% vertical and horizontal bars.
% Written by KGS Lab
% Edited by AS 8/2014

% find center of window
center_x = center(1);
center_y = center(2);

% draw horizontal bar
Screen('FillRect', windowPtr, color, [center_x - 3 center_y - 2 center_x + 3 center_y + 2]);

% draw vertical bar
Screen('FillRect', windowPtr, color, [center_x - 2 center_y - 3 center_x + 2 center_y + 3]);

end
%}
