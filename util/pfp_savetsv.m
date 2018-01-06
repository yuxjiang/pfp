function [] = pfp_savetsv(ofile, data, fmt)
    %PFP_SAVETSV Save tab-splitted-value
    %
    % [] = PFP_SAVETSV(ofile, data);
    % [] = PFP_SAVETSV(ofile, data, fmt);
    %
    %   Saves data to a file in tab-splitted format.
    %
    % Note
    % ----
    % Use csvwrite.m for outputing a matrix with pure numbers.
    %
    % Input
    % -----
    % (required)
    % [char]
    % ofile:    The data file name.
    %
    % [cell]
    % data:     An n-by-m data cell array to save.
    %
    % (optional)
    % [cell]
    % fmt:  A cell of strings specify the output format for each column. Note
    %       that the length of this cell should match the number of columns in
    %       the data cell (i.e., length(fmt) = m)
    %       default: repmat({'s'}, 1, m)
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_savetsv:InputCount', 'Expected 2 or 3 inputs.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fid = fopen(ofile, 'w');
    if fid == -1
        error('pfp_savetsv:FileErr', 'Cannot open [%s].', ofile);
    end

    % data
    validateattributes(data, {'cell'}, {}, '', 'data', 2);
    [n, m] = size(data);

    if nargin == 2
        fmt = repmat({'%s'}, 1, m);
    end

    % fmt
    validateattributes(fmt, {'cell'}, {'numel', m}, '', 'fmt', 3);
    % }}}

    % print out {{{
    for j = 2 : m
        fmt{j} = strcat('\t', fmt{j});
    end
    fmt{end} = strcat(fmt{end}, '\n');

    for i = 1 : n
        fprintf(fid, fmt{1}, data{i, 1});
        for j = 2 : m
            fprintf(fid, fmt{j}, data{i, j});
        end
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Mon 18 Dec 2017 02:50:29 PM E
