function [ocol] = pfp_convcoli(icol, map, keep)
    %PPF_CONVCOLI Convert column (interactive)
    %
    % [ocol] = PFP_MAPCOL(icol, map, keep);
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
    % keep: A toggle for keeping unmapped entry or not.
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
        ocol = map(index(found), 2);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 02:27:44 PM E
