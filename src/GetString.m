function [string,terminatorChar] = GetString(windowPtr, msg, x, y, textColor, bgColor, useKbCheck, varargin)
%
%
%
%
%

if nargin < 7
    useKbCheck = [];
end

if isempty(useKbCheck)
    useKbCheck = 0;
end

if nargin < 6
    bgColor = [];
end

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    if Screen('Preference', 'TextRenderer') >= 1
        oldalpha = Screen('Preference', 'TextAlphaBlending', 0);
    else
        oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux);
    end
end

if nargin < 5
    textColor = [];
end

if ~useKbCheck
    % Flush the keyboard buffer:
    FlushEvents;
end

string = '';
output = [msg, '', string];

% Write the initial message:
Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
Screen('Flip', windowPtr, 0, 1);

while true
    if useKbCheck
        char = GetKbChar(varargin{:});
    else
        char = GetChar;
    end
    
    if isempty(char)
        string = '';
        terminatorChar = 0;
        break;
    end
    
    switch abs(char)
        case {13, 3, 10, 27}
            % ctrl-C, enter, return, or escape
            terminatorChar = abs(char);
            break;
        case 8
            % backspace
            if ~isempty(string)
                
                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise
            string = [string, char]; %#ok<AGROW>
    end
    
    output = string;
    Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
    Screen('Flip', windowPtr);
end

% Restore text alpha blending state if it was altered:
if ~isempty(bgColor)
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end

return;
