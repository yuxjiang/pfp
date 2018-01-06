function [ocol] = pfp_convcoli(icol, map, keep)
    %PFP_CONVCOLI Convert column (interactive)
    %
    % [ocol] = PFP_CONVCOLI(icol, map, keep);
    %
    %   Converts the column according to 'map' in the interactive mode.
    %
    % Input
    % -----
    % (required)
    % [cell]
    % icol: The input column.
    %
    % [cell]
    % map:  A n-by-2 cell of ID, with column 1 - maps to -> column 2
    %       <from> <to>
    %
    % (optional)
    % [logical]
    % keep: A toggle for keeping unmapped entry or not. If true, unmaped items
    %       will be left as they are, otherwise, they will be replaced as an
    %       empty string: ''.
    %       default: true
    %
    % Output
    % ------
    % [cell]
    % ocol: The (mapped) output column.

    % check inputs {{{
    if nargin < 2 || nargin > 3
        error('pfp_convcoli:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        keep = true;
    end

    % icol
    validateattributes(icol, {'cell'}, {'nonempty'}, '', 'icol', 1);

    % map
    validateattributes(map, {'cell'}, {'ncols', 2}, '', 'map', 2);

    % keep
    validateattributes(keep, {'logical'}, {'nonempty'}, '', 'keep', 3);
    % }}}

    % map and output {{{
    n = numel(icol);
    [found, index] = ismember(icol, map(:, 1));
    if keep
        ocol = icol; % unmapped will be kept as the same as the input
        ocol(found) = map(index(found), 2);
    else
        ocol = repmat({''}, length(icol), 1);
        ocol(found) = map(index(found), 2);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 01 Feb 2017 10:22:29 AM E
